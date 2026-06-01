import 'dart:async';
import 'dart:io';
import 'dart:math' as math;

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import 'package:m_gaz/core/common/words.dart';
import 'package:m_gaz/core/extension/message_extension.dart';
import 'package:m_gaz/core/utils/colors.dart';
import 'package:m_gaz/global_widget/app_tools.dart';

import '../../../core/utils/services/in_app_camera_service.dart';
import '../../home/home_screen.dart';
import 'bloc/attendance_bloc.dart';
import 'bloc/attendance_event.dart';
import 'bloc/attendance_state.dart';

const Map<DeviceOrientation, int> _orientationDegrees = {
  DeviceOrientation.portraitUp: 0,
  DeviceOrientation.landscapeLeft: 90,
  DeviceOrientation.portraitDown: 180,
  DeviceOrientation.landscapeRight: 270,
};

@visibleForTesting
int? attendanceRotationCompensation({
  required int sensorOrientation,
  required DeviceOrientation deviceOrientation,
  required CameraLensDirection lensDirection,
  required bool isAndroid,
  required bool isIOS,
}) {
  if (isIOS) return sensorOrientation;
  if (!isAndroid) return null;

  final rotationCompensation = _orientationDegrees[deviceOrientation];
  if (rotationCompensation == null) return null;

  if (lensDirection == CameraLensDirection.front) {
    return (sensorOrientation + rotationCompensation) % 360;
  }

  return (sensorOrientation - rotationCompensation + 360) % 360;
}

@visibleForTesting
Face? attendanceLargestFace(List<Face> faces) {
  if (faces.isEmpty) return null;

  return faces.reduce((largest, face) {
    final largestArea = largest.boundingBox.width * largest.boundingBox.height;
    final faceArea = face.boundingBox.width * face.boundingBox.height;
    return faceArea > largestArea ? face : largest;
  });
}

@visibleForTesting
bool attendanceHasOpenEyes(Face face, {double threshold = 0.8}) {
  final leftEye = face.leftEyeOpenProbability;
  final rightEye = face.rightEyeOpenProbability;
  if (leftEye == null || rightEye == null) return false;

  return leftEye > threshold && rightEye > threshold;
}

enum _AttendanceCameraPhase { intro, initializing, camera, error }

class CameraScreen extends StatefulWidget {
  const CameraScreen({super.key});

  @override
  State<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  final FaceDetector _faceDetector = FaceDetector(
    options: FaceDetectorOptions(
      enableClassification: true,
      enableTracking: true,
      performanceMode: FaceDetectorMode.accurate,
    ),
  );

  _AttendanceCameraPhase _phase = _AttendanceCameraPhase.intro;
  bool _sending = false;
  bool _processingFrame = false;
  bool _faceDetected = false;
  bool _eyesOpen = false;

  Future<void> _initializeCamera() async {
    setState(() {
      _phase = _AttendanceCameraPhase.initializing;
      _sending = false;
      _faceDetected = false;
      _eyesOpen = false;
    });

    final initialized = await InAppCameraService.initialize();
    if (!mounted) return;

    if (!initialized) {
      setState(() => _phase = _AttendanceCameraPhase.error);
      return;
    }

    _startImageStream();
    setState(() => _phase = _AttendanceCameraPhase.camera);
  }

  void _startImageStream() {
    final controller = InAppCameraService.controller;
    if (controller == null ||
        !controller.value.isInitialized ||
        controller.value.isStreamingImages) {
      return;
    }

    controller.startImageStream(_processCameraImage);
  }

  Future<void> _processCameraImage(CameraImage image) async {
    if (_sending || _processingFrame) return;
    _processingFrame = true;

    try {
      final inputImage = _inputImageFromCameraImage(image);
      if (inputImage == null) return;

      final faces = await _faceDetector.processImage(inputImage);
      if (!mounted) return;

      if (faces.isEmpty) {
        setState(() {
          _faceDetected = false;
          _eyesOpen = false;
        });
        return;
      }

      final face = attendanceLargestFace(faces);
      final eyesOpen = face != null && attendanceHasOpenEyes(face);

      setState(() {
        _faceDetected = true;
        _eyesOpen = eyesOpen;
      });

      if (eyesOpen) {
        await _autoTakePicture();
      }
    } finally {
      _processingFrame = false;
    }
  }

  InputImage? _inputImageFromCameraImage(CameraImage image) {
    final controller = InAppCameraService.controller;
    final camera = InAppCameraService.selectedCamera;
    if (controller == null || camera == null) return null;

    final rotationDegrees = attendanceRotationCompensation(
      sensorOrientation: camera.sensorOrientation,
      deviceOrientation: controller.value.deviceOrientation,
      lensDirection: camera.lensDirection,
      isAndroid: Platform.isAndroid,
      isIOS: Platform.isIOS,
    );
    if (rotationDegrees == null) return null;

    final rotation = InputImageRotationValue.fromRawValue(rotationDegrees);
    if (rotation == null) return null;

    final format = InputImageFormatValue.fromRawValue(image.format.raw);
    if (format == null) return null;
    if (Platform.isAndroid && format != InputImageFormat.nv21) return null;
    if (Platform.isIOS && format != InputImageFormat.bgra8888) return null;
    if (image.planes.length != 1) return null;

    final plane = image.planes.first;
    return InputImage.fromBytes(
      bytes: plane.bytes,
      metadata: InputImageMetadata(
        size: Size(image.width.toDouble(), image.height.toDouble()),
        rotation: rotation,
        format: format,
        bytesPerRow: plane.bytesPerRow,
      ),
    );
  }

  Future<void> _autoTakePicture() async {
    if (_sending) return;

    setState(() => _sending = true);

    if (InAppCameraService.controller?.value.isStreamingImages ?? false) {
      await InAppCameraService.controller?.stopImageStream();
    }

    final hasPermission = await _checkLocationPermission();
    if (!mounted) return;

    if (!hasPermission) {
      setState(() => _sending = false);
      _startImageStream();
      return;
    }

    final xFile = await InAppCameraService.takePicture();
    if (!mounted) return;

    if (xFile == null) {
      showToast(context, Words.selfieFailed.tr());
      setState(() => _sending = false);
      _startImageStream();
      return;
    }

    final photo = File(xFile.path);
    final pos = await Geolocator.getCurrentPosition();

    if (!mounted) return;
    context.read<AttendanceBloc>().add(
      AttendanceSubmit(
        photo: photo,
        data: {'lat': pos.latitude.toString(), 'lng': pos.longitude.toString()},
      ),
    );
  }

  Future<bool> _checkLocationPermission() async {
    var permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    if (!mounted) return false;

    if (permission == LocationPermission.deniedForever) {
      showToast(context, Words.gpsPermissionRequired.tr());
      return false;
    }

    return permission == LocationPermission.always ||
        permission == LocationPermission.whileInUse;
  }

  @override
  void dispose() {
    if (InAppCameraService.controller?.value.isStreamingImages ?? false) {
      InAppCameraService.controller?.stopImageStream();
    }
    unawaited(_faceDetector.close().catchError((_) {}));
    InAppCameraService.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    switch (_phase) {
      case _AttendanceCameraPhase.intro:
        return _AttendanceIntroView(
          onBack: () => Navigator.maybePop(context),
          onStart: _initializeCamera,
        );
      case _AttendanceCameraPhase.initializing:
        return const Scaffold(
          backgroundColor: _AttendanceCameraColors.background,
          body: Center(child: CircularProgressIndicator()),
        );
      case _AttendanceCameraPhase.error:
        return _CameraErrorView(onRetry: _initializeCamera);
      case _AttendanceCameraPhase.camera:
        return _CameraAttendanceView(
          isValidFace: _faceDetected && _eyesOpen,
          preview: _CameraPreviewFill(
            controller: InAppCameraService.controller!,
          ),
          onSubmitFailed: _startImageStream,
          onSuccessResetSending: () {
            if (mounted) setState(() => _sending = false);
          },
          onFailResetSending: () {
            if (mounted) setState(() => _sending = false);
          },
          isSending: _sending,
        );
    }
  }
}

class _CameraAttendanceView extends StatelessWidget {
  const _CameraAttendanceView({
    required this.isValidFace,
    required this.preview,
    required this.onSubmitFailed,
    required this.onSuccessResetSending,
    required this.onFailResetSending,
    required this.isSending,
  });

  final bool isValidFace;
  final Widget preview;
  final VoidCallback onSubmitFailed;
  final VoidCallback onSuccessResetSending;
  final VoidCallback onFailResetSending;
  final bool isSending;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocConsumer<AttendanceBloc, AttendanceState>(
        listener: (context, state) {
          if (state.status == AttendanceStatus.success) {
            showToast(
              context,
              Words.attendanceAllowed.tr(),
              backgroundColor: AppColors.c17B26A,
            );
            onSuccessResetSending();

            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (_) => const HomeScreen()),
              (route) => false,
            );
          }

          if (state.status == AttendanceStatus.fail) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.error ?? Words.errorOccurred.tr())),
            );
            onFailResetSending();
            onSubmitFailed();
          }
        },
        builder: (context, state) {
          return _CameraScannerView(
            isValidFace: isValidFace,
            isSubmitting:
                isSending || state.status == AttendanceStatus.uploading,
            preview: preview,
          );
        },
      ),
    );
  }
}

class _CameraErrorView extends StatelessWidget {
  const _CameraErrorView({required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _AttendanceCameraColors.background,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(Words.cameraFailed.tr()),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: onRetry,
              child: Text(Words.tryAgain.tr()),
            ),
          ],
        ),
      ),
    );
  }
}

class _AttendanceCameraColors {
  const _AttendanceCameraColors._();

  static const background = Color(0xFFFCFCFC);
  static const primary = Color(0xFF314692);
  static const soft = Color(0xFFF0F0F0);
  static const textStrong = Color(0xFF1A1D2E);
  static const scannerWhite = Color(0xFFFCFCFC);
  static const error = Color(0xFFF04438);
  static const success = Color(0xFF17B26A);
}

class _AttendanceIntroView extends StatelessWidget {
  const _AttendanceIntroView({required this.onBack, required this.onStart});

  final VoidCallback onBack;
  final VoidCallback onStart;

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.paddingOf(context).bottom;

    return Scaffold(
      backgroundColor: _AttendanceCameraColors.background,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 390),
            child: LayoutBuilder(
              builder: (context, constraints) {
                final compact = constraints.maxHeight < 760;
                final graphicHeight =
                    (constraints.maxHeight * (compact ? 0.28 : 0.37)).clamp(
                      150.0,
                      308.0,
                    );

                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: compact ? 0 : 4),
                      SizedBox(
                        height: compact ? 40 : 48,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            IconButton(
                              key: const Key('attendance-intro-back'),
                              onPressed: onBack,
                              icon: const Icon(
                                Icons.chevron_left,
                                color: Colors.black,
                                size: 28,
                              ),
                              padding: EdgeInsets.zero,
                              alignment: Alignment.centerLeft,
                            ),
                            const SizedBox(width: 24),
                          ],
                        ),
                      ),
                      SizedBox(height: compact ? 12 : 28),
                      Text(
                        Words.faceIntroTitle.tr(),
                        key: const Key('attendance-intro-title'),
                        style: GoogleFonts.manrope(
                          color: _AttendanceCameraColors.textStrong,
                          fontSize: 28,
                          fontWeight: FontWeight.w800,
                          height: 32 / 28,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        Words.faceIntroDescription.tr(),
                        key: const Key('attendance-intro-description'),
                        style: GoogleFonts.manrope(
                          color: _AttendanceCameraColors.textStrong,
                          fontSize: 17,
                          fontWeight: FontWeight.w500,
                          height: 28 / 17,
                        ),
                      ),
                      SizedBox(height: compact ? 16 : 28),
                      _FaceIntroGraphic(height: graphicHeight),
                      SizedBox(height: compact ? 14 : 22),
                      const _FaceGuidanceRow(),
                      const Spacer(),
                      SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: ElevatedButton(
                          key: const Key('attendance-intro-start'),
                          onPressed: onStart,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _AttendanceCameraColors.primary,
                            foregroundColor:
                                _AttendanceCameraColors.scannerWhite,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: Text(
                            Words.start.tr(),
                            style: GoogleFonts.manrope(
                              fontSize: 15,
                              fontWeight: FontWeight.w800,
                              height: 24 / 15,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(
                        height: compact ? 12 : (bottomPadding > 0 ? 16 : 28),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}

class _FaceIntroGraphic extends StatelessWidget {
  const _FaceIntroGraphic({required this.height});

  final double height;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: height,
      child: Container(
        key: const Key('attendance-intro-graphic'),
        decoration: BoxDecoration(
          color: _AttendanceCameraColors.soft,
          borderRadius: BorderRadius.circular(28),
        ),
        child: Center(
          child: SizedBox.square(
            dimension: 228,
            child: AppTools.svg(AppTools.icCheckUser) /*CustomPaint(
              painter: const _IntroScanIconPainter(),
              child: const Center(
                child: Icon(
                  Icons.person_outline,
                  size: 84,
                  color: Color(0xFFBDBDBD),
                ),
              ),
            )*/,
          ),
        ),
      ),
    );
  }
}

class _FaceGuidanceRow extends StatelessWidget {
  const _FaceGuidanceRow();

  @override
  Widget build(BuildContext context) {
    final textStyle = GoogleFonts.manrope(
      color: const Color(0xFF202020),
      fontSize: 15,
      fontWeight: FontWeight.w500,
      height: 24 / 15,
    );

    return Row(
      children: [
        Expanded(
          child: _GuidanceItem(
            key: const Key('attendance-guidance-open-face'),
            icon: AppTools.svg(AppTools.icSmile),
            label: Words.faceOpenFace.tr(),
            textStyle: textStyle,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _GuidanceItem(
            key: const Key('attendance-guidance-lighting'),
            icon: AppTools.svg(AppTools.icSun),
            label: Words.faceGoodLighting.tr(),
            textStyle: textStyle,
          ),
        ),
      ],
    );
  }
}

class _GuidanceItem extends StatelessWidget {
  const _GuidanceItem({
    super.key,
    required this.icon,
    required this.label,
    required this.textStyle,
  });

  final Widget icon;
  final String label;
  final TextStyle textStyle;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SizedBox.square(dimension: 24, child: icon),
        const SizedBox(width: 8),
        Flexible(
          child: Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: textStyle,
          ),
        ),
      ],
    );
  }
}

class _CameraPreviewFill extends StatelessWidget {
  const _CameraPreviewFill({required this.controller});

  final CameraController controller;

  @override
  Widget build(BuildContext context) {
    final previewSize = controller.value.previewSize;
    if (previewSize == null) {
      return const ColoredBox(color: Colors.black);
    }

    return FittedBox(
      fit: BoxFit.cover,
      child: SizedBox(
        width: previewSize.height,
        height: previewSize.width,
        child: CameraPreview(controller),
      ),
    );
  }
}

class _CameraScannerView extends StatelessWidget {
  const _CameraScannerView({
    required this.isValidFace,
    required this.preview,
    required this.isSubmitting,
  });

  final bool isValidFace;
  final Widget preview;
  final bool isSubmitting;

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context);

    return Stack(
      fit: StackFit.expand,
      children: [
        preview,
        LayoutBuilder(
          builder: (context, constraints) {
            final width = constraints.maxWidth;
            final height = constraints.maxHeight;
            final frameLeft = width * 20 / 390;
            final frameTop = media.padding.top + 4;
            final frameWidth = width - (frameLeft * 2);
            final frameBottom = media.padding.bottom + (height * 73 / 844);
            final frameHeight = height - frameTop - frameBottom;
            final frameRect = Rect.fromLTWH(
              frameLeft,
              frameTop,
              frameWidth,
              frameHeight,
            );

            return Stack(
              fit: StackFit.expand,
              children: [
                CustomPaint(
                  painter: _ScannerOverlayPainter(frameRect: frameRect),
                ),
                Positioned.fromRect(
                  rect: frameRect,
                  child: IgnorePointer(
                    child: CustomPaint(painter: const _ScannerFramePainter()),
                  ),
                ),
                Positioned(
                  top: frameRect.bottom - 46,
                  left: 0,
                  right: 0,
                  child: Center(
                    child: AttendanceScannerStatusBadge(
                      isValidFace: isValidFace,
                      isSubmitting: isSubmitting,
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ],
    );
  }
}

@visibleForTesting
class AttendanceScannerStatusBadge extends StatelessWidget {
  const AttendanceScannerStatusBadge({
    super.key,
    required this.isValidFace,
    this.isSubmitting = false,
  });

  final bool isValidFace;
  final bool isSubmitting;

  @override
  Widget build(BuildContext context) {
    final color = isValidFace
        ? _AttendanceCameraColors.success
        : _AttendanceCameraColors.error;
    final icon = isValidFace
        ? Icons.check_circle_outline
        : Icons.cancel_outlined;
    final label = isValidFace
        ? Words.faceConfirmed.tr()
        : Words.faceNotFound.tr();

    return AnimatedOpacity(
      duration: const Duration(milliseconds: 150),
      opacity: isSubmitting ? 0.72 : 1,
      child: Row(
        key: Key(
          isValidFace
              ? 'attendance-scanner-confirmed'
              : 'attendance-scanner-not-found',
        ),
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 24, color: color),
          const SizedBox(width: 8),
          Text(
            label,
            style: GoogleFonts.manrope(
              color: _AttendanceCameraColors.scannerWhite,
              fontSize: 15,
              fontWeight: FontWeight.w800,
              height: 24 / 15,
            ),
          ),
        ],
      ),
    );
  }
}

class _ScannerOverlayPainter extends CustomPainter {
  const _ScannerOverlayPainter({required this.frameRect});

  final Rect frameRect;

  @override
  void paint(Canvas canvas, Size size) {
    final overlayPath = Path()
      ..fillType = PathFillType.evenOdd
      ..addRect(Offset.zero & size)
      ..addRRect(RRect.fromRectAndRadius(frameRect, const Radius.circular(16)));

    canvas.drawPath(overlayPath, Paint()..color = const Color(0x990F0A05));
  }

  @override
  bool shouldRepaint(covariant _ScannerOverlayPainter oldDelegate) {
    return oldDelegate.frameRect != frameRect;
  }
}

class _ScannerFramePainter extends CustomPainter {
  const _ScannerFramePainter();

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = _AttendanceCameraColors.scannerWhite
      ..strokeWidth = 6
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final rect = Rect.fromLTWH(3, 3, size.width - 6, size.height - 6);
    const radius = 16.0;
    const segment = 56.0;
    const centerSegment = 90.0;
    const sideSegment = 96.0;

    void line(Offset from, Offset to) => canvas.drawLine(from, to, paint);
    void arc(Rect arcRect, double startAngle, double sweepAngle) {
      canvas.drawArc(arcRect, startAngle, sweepAngle, false, paint);
    }

    const corner = radius * 2;
    arc(
      Rect.fromLTWH(rect.left, rect.top, corner, corner),
      math.pi,
      math.pi / 2,
    );
    line(
      Offset(rect.left + radius, rect.top),
      Offset(rect.left + segment, rect.top),
    );
    line(
      Offset(rect.left, rect.top + radius),
      Offset(rect.left, rect.top + segment),
    );

    arc(
      Rect.fromLTWH(rect.right - corner, rect.top, corner, corner),
      -math.pi / 2,
      math.pi / 2,
    );
    line(
      Offset(rect.right - segment, rect.top),
      Offset(rect.right - radius, rect.top),
    );
    line(
      Offset(rect.right, rect.top + radius),
      Offset(rect.right, rect.top + segment),
    );

    arc(
      Rect.fromLTWH(rect.right - corner, rect.bottom - corner, corner, corner),
      0,
      math.pi / 2,
    );
    line(
      Offset(rect.right, rect.bottom - segment),
      Offset(rect.right, rect.bottom - radius),
    );
    line(
      Offset(rect.right - segment, rect.bottom),
      Offset(rect.right - radius, rect.bottom),
    );

    arc(
      Rect.fromLTWH(rect.left, rect.bottom - corner, corner, corner),
      math.pi / 2,
      math.pi / 2,
    );
    line(
      Offset(rect.left, rect.bottom - segment),
      Offset(rect.left, rect.bottom - radius),
    );
    line(
      Offset(rect.left + radius, rect.bottom),
      Offset(rect.left + segment, rect.bottom),
    );

    final centerX = rect.center.dx;
    line(
      Offset(centerX - centerSegment / 2, rect.top),
      Offset(centerX + centerSegment / 2, rect.top),
    );
    line(
      Offset(centerX - centerSegment / 2, rect.bottom),
      Offset(centerX + centerSegment / 2, rect.bottom),
    );

    final centerY = rect.center.dy;
    line(
      Offset(rect.left, centerY - sideSegment / 2),
      Offset(rect.left, centerY + sideSegment / 2),
    );
    line(
      Offset(rect.right, centerY - sideSegment / 2),
      Offset(rect.right, centerY + sideSegment / 2),
    );
  }

  @override
  bool shouldRepaint(covariant _ScannerFramePainter oldDelegate) => false;
}
