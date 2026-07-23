import 'dart:async';
import 'dart:io';
import 'dart:math' as math;

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import 'package:m_gaz/core/common/words.dart';
import 'package:m_gaz/core/constants/session_constants.dart';
import 'package:m_gaz/core/extension/message_extension.dart';
import 'package:m_gaz/core/hive/api_hive.dart';
import 'package:m_gaz/core/utils/colors.dart';
import 'package:m_gaz/di.dart';
import 'package:m_gaz/features/auth/domain/entities/user.dart';
import 'package:m_gaz/features/auth/presentation/bloc/login_bloc.dart';
import 'package:m_gaz/features/auth/presentation/widgets/profile_photo_required_sheet.dart';
import 'package:m_gaz/global_widget/app_tools.dart';

import '../../../core/utils/services/in_app_camera_service.dart';
import '../../../features/auth/presentation/pages/login_screen.dart';
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

/// Yuz kameraga to'g'ri qaraganmi — bosh burchaklari (yaw/pitch) chegarada bo'lsa.
/// Burchaklar `null` bo'lsa (aniqlanmagan) — markazda emas deb hisoblanadi.
@visibleForTesting
bool attendanceFaceCentered(
  Face face, {
  double maxYawDeg = 18,
  double maxPitchDeg = 15,
}) {
  final yaw = face.headEulerAngleY;
  final pitch = face.headEulerAngleX;
  if (yaw == null || pitch == null) return false;
  return yaw.abs() <= maxYawDeg && pitch.abs() <= maxPitchDeg;
}

/// "To'liq yuz" — yuz ramkasi kadrning yetarli qismini egallasa (juda uzoq emas).
@visibleForTesting
bool attendanceFaceLargeEnough(
  Rect faceBox,
  Size imageSize, {
  double minAreaRatio = 0.10,
}) {
  final imageArea = imageSize.width * imageSize.height;
  if (imageArea <= 0) return false;
  final faceArea = faceBox.width * faceBox.height;
  return (faceArea / imageArea) >= minAreaRatio;
}

@visibleForTesting
double attendanceAverageLuminance(List<int> luma) {
  if (luma.isEmpty) return 0;
  var sum = 0;
  for (final v in luma) {
    sum += v;
  }
  return sum / luma.length;
}

/// Yorug'lik muvozanatda — juda qorong'i ham, juda yorug' ham emas (0–255).
@visibleForTesting
bool attendanceBrightnessBalanced(
  double avg, {
  double min = 70,
  double max = 200,
}) {
  return avg >= min && avg <= max;
}

/// Laplas operatori variansiyasi — yuqori bo'lsa tasvir aniq, past bo'lsa xira.
@visibleForTesting
double attendanceLaplacianVariance(List<int> luma, int width, int height) {
  if (width < 3 || height < 3 || luma.length < width * height) return 0;

  final responses = <double>[];
  for (var y = 1; y < height - 1; y++) {
    for (var x = 1; x < width - 1; x++) {
      final i = y * width + x;
      final lap =
          (4 * luma[i] -
                  luma[i - 1] -
                  luma[i + 1] -
                  luma[i - width] -
                  luma[i + width])
              .toDouble();
      responses.add(lap);
    }
  }
  if (responses.isEmpty) return 0;

  var mean = 0.0;
  for (final r in responses) {
    mean += r;
  }
  mean /= responses.length;

  var variance = 0.0;
  for (final r in responses) {
    final d = r - mean;
    variance += d * d;
  }
  return variance / responses.length;
}

@visibleForTesting
bool attendanceSharpEnough(double variance, {double min = 8.0}) {
  return variance >= min;
}

/// Uzluksiz barqarorlik taymeri: bir xil `trackingId` `holdDuration` davomida
/// to'xtovsiz valid bo'lsagina `true` qaytaradi. Invalid kadr yoki trackingId
/// almashishi taymerni nolga qaytaradi. `now` test uchun injektsiya qilinadi.
@visibleForTesting
class AttendanceStabilityTracker {
  AttendanceStabilityTracker({this.holdDuration = const Duration(seconds: 2)});

  final Duration holdDuration;

  int? _trackingId;
  DateTime? _since;

  void reset() {
    _trackingId = null;
    _since = null;
  }

  bool update({required bool valid, int? trackingId, required DateTime now}) {
    if (!valid) {
      reset();
      return false;
    }
    if (trackingId != _trackingId || _since == null) {
      _trackingId = trackingId;
      _since = now;
      return false;
    }
    return now.difference(_since!) >= holdDuration;
  }
}

enum _AttendanceCameraPhase { intro, checking, initializing, camera, error }

class CameraScreen extends StatefulWidget {
  const CameraScreen({super.key, this.forProfilePhoto = false});

  final bool forProfilePhoto;

  @override
  State<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen>
    with WidgetsBindingObserver {
  static const int _lumaGridW = 32;
  static const int _lumaGridH = 32;

  final FaceDetector _faceDetector = FaceDetector(
    options: FaceDetectorOptions(
      enableClassification: true,
      enableTracking: true,
      performanceMode: FaceDetectorMode.accurate,
    ),
  );
  final AttendanceStabilityTracker _stability = AttendanceStabilityTracker();

  _AttendanceCameraPhase _phase = _AttendanceCameraPhase.intro;
  bool _sending = false;
  bool _processingFrame = false;
  bool _isValidFace = false;
  Words _statusMessage = Words.faceNotFound;
  LoginBloc? _loginBloc;
  bool _profileCheckStarted = false;
  bool _profileCheckFinished = true;
  bool _profilePhotoDialogOpen = false;
  bool _uploadingProfilePhoto = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) => _startProfileCheck());
  }

  void _startProfileCheck() {
    if (widget.forProfilePhoto || !mounted) return;
    try {
      _loginBloc = context.read<LoginBloc>();
    } catch (_) {
      return;
    }
    _profileCheckStarted = true;
    setState(() => _profileCheckFinished = false);
    _loginBloc!.add(const LoadUserProfile());
  }

  void _onProfileStateChanged(BuildContext context, LoginState state) {
    if (!_profileCheckStarted) return;

    if (state.status == LoginStatus.fail) {
      if (_uploadingProfilePhoto) {
        _uploadingProfilePhoto = false;
        showToast(
          context,
          state.errorMessage.isEmpty
              ? Words.errorOccurred.tr()
              : state.errorMessage,
        );
        _showProfilePhotoDialog(state.user);
      } else {
        _profileCheckStarted = false;
        showToast(
          context,
          state.errorMessage.isEmpty
              ? Words.errorOccurred.tr()
              : state.errorMessage,
        );
      }
      return;
    }

    if (state.status != LoginStatus.success) return;

    if (_uploadingProfilePhoto) {
      _uploadingProfilePhoto = false;
      _profileCheckStarted = false;
      setState(() => _profileCheckFinished = true);
      return;
    }

    _profileCheckStarted = false;
    if (state.user?.hasProfilePhoto ?? false) {
      setState(() => _profileCheckFinished = true);
    } else {
      _showProfilePhotoDialog(state.user);
    }
  }

  Future<void> _showProfilePhotoDialog(User? user) async {
    if (!mounted || user == null || _profilePhotoDialogOpen) return;
    _profilePhotoDialogOpen = true;
    final photo = await showProfilePhotoRequiredDialog(context);
    _profilePhotoDialogOpen = false;
    if (!mounted || photo == null) return;
    _uploadingProfilePhoto = true;
    _profileCheckStarted = true;
    _loginBloc?.add(ProfilePhotoUploaded(userId: user.id, photo: photo));
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    // Face-verification bo'limidan chiqilsa — qaytganda darhol login majburlanadi.
    // Faqat `paused` (isAppBackgrounded): `hidden` qaytishda ham yuboriladi va
    // bayroqni noto'g'ri qayta yoqib qo'yishi mumkin.
    if (isAppBackgrounded(state)) {
      di.get<ApiHive>().setPendingRelogin(true);
    }
  }

  // Intro'dagi "Boshlash" — kamerani ochishdan oldin bugungi yo'qlama
  // holatini GET orqali tekshiramiz.
  void _onStartPressed() {
    if (!widget.forProfilePhoto && !_profileCheckFinished) return;
    if (widget.forProfilePhoto) {
      _initializeCamera();
      return;
    }
    setState(() => _phase = _AttendanceCameraPhase.checking);
    context.read<AttendanceBloc>().add(AttendanceCheckAccess());
  }

  void _returnToLogin() {
    if (di.isRegistered<ApiHive>()) {
      unawaited(di.get<ApiHive>().setPendingRelogin(false));
    }
    try {
      Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
    } catch (_) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const LoginScreen()),
        (route) => false,
      );
    }
  }

  void _onAccessStateChanged(BuildContext context, AttendanceState state) {
    switch (state.status) {
      case AttendanceStatus.accessAllowed:
        _initializeCamera();
        break;
      case AttendanceStatus.accessBlocked:
        // Bugun allaqachon yo'qlama qilingan — hech qanday xabarsiz Home'ga.
        di.get<ApiHive>().setPendingRelogin(false);
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => const HomeScreen()),
          (route) => false,
        );
        break;
      case AttendanceStatus.fail:
        if (_phase == _AttendanceCameraPhase.checking) {
          showToast(context, state.error ?? Words.errorOccurred.tr());
          setState(() => _phase = _AttendanceCameraPhase.intro);
        }
        break;
      default:
        break;
    }
  }

  Future<void> _initializeCamera() async {
    _stability.reset();
    setState(() {
      _phase = _AttendanceCameraPhase.initializing;
      _sending = false;
      _isValidFace = false;
      _statusMessage = Words.faceNotFound;
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

    // Har safar oqim qayta boshlanganda 2 soniyalik barqarorlik qaytadan kerak.
    _stability.reset();
    controller.startImageStream(_processCameraImage);
  }

  Future<void> _processCameraImage(CameraImage image) async {
    if (_sending || _processingFrame) return;
    _processingFrame = true;

    try {
      final inputImage = _inputImageFromCameraImage(image);
      if (inputImage == null) return;

      // Yorug'lik (avg) va aniqlik (blur) — downsample qilingan luma to'ridan.
      final luma = _lumaGridFromImage(image);
      final avgLuma = attendanceAverageLuminance(luma);
      final variance = attendanceLaplacianVariance(
        luma,
        _lumaGridW,
        _lumaGridH,
      );
      final brightnessOk = attendanceBrightnessBalanced(avgLuma);
      final sharpOk = attendanceSharpEnough(variance);

      final faces = await _faceDetector.processImage(inputImage);
      if (!mounted) return;

      final face = attendanceLargestFace(faces);
      final imageSize = Size(image.width.toDouble(), image.height.toDouble());

      final faceDetected = face != null;
      final centered = faceDetected && attendanceFaceCentered(face);
      final largeEnough =
          faceDetected &&
          attendanceFaceLargeEnough(face.boundingBox, imageSize);
      final eyesOpen = faceDetected && attendanceHasOpenEyes(face);

      final valid =
          faceDetected &&
          centered &&
          largeEnough &&
          eyesOpen &&
          brightnessOk &&
          sharpOk;

      // Status xabari ustuvorligi: nima yetishmayotganini ko'rsatamiz.
      final Words message;
      if (!faceDetected) {
        message = Words.faceNotFound;
      } else if (!centered || !largeEnough) {
        message = Words.lookAtCamera;
      } else if (!brightnessOk) {
        message = avgLuma < 70 ? Words.faceTooDark : Words.faceTooBright;
      } else if (!sharpOk) {
        message = Words.faceBlurry;
      } else if (!eyesOpen) {
        message = Words.faceNotFound;
      } else {
        message = Words.faceHoldStill;
      }

      final ready = _stability.update(
        valid: valid,
        trackingId: face?.trackingId,
        now: DateTime.now(),
      );

      setState(() {
        _isValidFace = valid;
        _statusMessage = ready ? Words.faceConfirmed : message;
      });

      // Yuz to'liq, markazda, yaxshi yorug'likda va 2 soniya barqaror — yuboramiz.
      if (ready && !_sending) {
        await _autoTakePicture();
      }
    } finally {
      _processingFrame = false;
    }
  }

  // CameraImage'dan downsample qilingan luminance to'rini quradi (gridW x gridH).
  List<int> _lumaGridFromImage(CameraImage image) {
    final width = image.width;
    final height = image.height;
    final plane = image.planes.first;
    final bytes = plane.bytes;
    final bytesPerRow = plane.bytesPerRow;
    final grid = List<int>.filled(_lumaGridW * _lumaGridH, 0);

    if (Platform.isAndroid) {
      // NV21: Y (luminance) tekisligi birinchi; bytesPerRow padding bo'lishi mumkin.
      for (var gy = 0; gy < _lumaGridH; gy++) {
        final sy = gy * height ~/ _lumaGridH;
        for (var gx = 0; gx < _lumaGridW; gx++) {
          final sx = gx * width ~/ _lumaGridW;
          final idx = sy * bytesPerRow + sx;
          grid[gy * _lumaGridW + gx] = idx < bytes.length ? bytes[idx] : 0;
        }
      }
    } else {
      // BGRA8888: 4 bayt/piksel; luma = 0.114B + 0.587G + 0.299R.
      for (var gy = 0; gy < _lumaGridH; gy++) {
        final sy = gy * height ~/ _lumaGridH;
        for (var gx = 0; gx < _lumaGridW; gx++) {
          final sx = gx * width ~/ _lumaGridW;
          final idx = sy * bytesPerRow + sx * 4;
          if (idx + 2 < bytes.length) {
            final b = bytes[idx];
            final g = bytes[idx + 1];
            final r = bytes[idx + 2];
            grid[gy * _lumaGridW + gx] = (0.114 * b + 0.587 * g + 0.299 * r)
                .round();
          }
        }
      }
    }
    return grid;
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

    final xFile = await InAppCameraService.takePicture();
    if (!mounted) return;

    if (xFile == null) {
      showToast(context, Words.selfieFailed.tr());
      setState(() => _sending = false);
      _startImageStream();
      return;
    }

    final photo = File(xFile.path);
    if (widget.forProfilePhoto) {
      Navigator.pop(context, photo);
      return;
    }

    final hasPermission = await _checkLocationPermission();
    if (!mounted) return;

    if (!hasPermission) {
      setState(() => _sending = false);
      _startImageStream();
      return;
    }

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
    WidgetsBinding.instance.removeObserver(this);
    if (InAppCameraService.controller?.value.isStreamingImages ?? false) {
      InAppCameraService.controller?.stopImageStream();
    }
    unawaited(_faceDetector.close().catchError((_) {}));
    InAppCameraService.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Widget content = _buildPhase();
    if (!widget.forProfilePhoto) {
      content = BlocListener<AttendanceBloc, AttendanceState>(
        listenWhen: (prev, curr) => prev.status != curr.status,
        listener: _onAccessStateChanged,
        child: content,
      );
    }

    final loginBloc = _loginBloc;
    if (widget.forProfilePhoto || loginBloc == null) return content;

    return BlocListener<LoginBloc, LoginState>(
      bloc: loginBloc,
      listenWhen: (prev, curr) => prev.status != curr.status,
      listener: _onProfileStateChanged,
      child: content,
    );
  }

  Widget _buildPhase() {
    switch (_phase) {
      case _AttendanceCameraPhase.intro:
        return PopScope(
          canPop: false,
          onPopInvokedWithResult: (didPop, result) {
            if (!didPop) _returnToLogin();
          },
          child: _AttendanceIntroView(
            onBack: _returnToLogin,
            onStart: _onStartPressed,
          ),
        );
      case _AttendanceCameraPhase.checking:
      case _AttendanceCameraPhase.initializing:
        return const Scaffold(
          backgroundColor: _AttendanceCameraColors.background,
          body: Center(child: CircularProgressIndicator()),
        );
      case _AttendanceCameraPhase.error:
        return _CameraErrorView(onRetry: _initializeCamera);
      case _AttendanceCameraPhase.camera:
        if (widget.forProfilePhoto) {
          return Scaffold(
            body: _CameraScannerView(
              isValidFace: _isValidFace,
              statusMessage: _statusMessage,
              isSubmitting: _sending,
              preview: _CameraPreviewFill(
                controller: InAppCameraService.controller!,
              ),
            ),
          );
        }
        return _CameraAttendanceView(
          isValidFace: _isValidFace,
          statusMessage: _statusMessage,
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
    required this.statusMessage,
    required this.preview,
    required this.onSubmitFailed,
    required this.onSuccessResetSending,
    required this.onFailResetSending,
    required this.isSending,
  });

  final bool isValidFace;
  final Words statusMessage;
  final Widget preview;
  final VoidCallback onSubmitFailed;
  final VoidCallback onSuccessResetSending;
  final VoidCallback onFailResetSending;
  final bool isSending;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocConsumer<AttendanceBloc, AttendanceState>(
        listenWhen: (prev, curr) => prev.status != curr.status,
        listener: (context, state) {
          if (state.status == AttendanceStatus.success) {
            showToast(
              context,
              Words.attendanceAllowed.tr(),
              backgroundColor: AppColors.c17B26A,
            );
            onSuccessResetSending();

            // Yo'qlama topshirildi — Home ochilmoqda, login bayrog'ini tozalaymiz.
            di.get<ApiHive>().setPendingRelogin(false);
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
            statusMessage: statusMessage,
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
            icon: AppTools.svg(
              AppTools.icSmile,
              colorFilter: ColorFilter.mode(Color(0xFF202020), BlendMode.srcIn),
            ),
            label: Words.faceOpenFace.tr(),
            textStyle: textStyle,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _GuidanceItem(
            key: const Key('attendance-guidance-lighting'),
            icon: AppTools.svg(
              AppTools.icSun,
              colorFilter: ColorFilter.mode(Color(0xFF202020), BlendMode.srcIn),
            ),
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
    required this.statusMessage,
    required this.preview,
    required this.isSubmitting,
  });

  final bool isValidFace;
  final Words statusMessage;
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
                      message: statusMessage,
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
    this.message,
    this.isSubmitting = false,
  });

  final bool isValidFace;
  final Words? message;
  final bool isSubmitting;

  @override
  Widget build(BuildContext context) {
    final color = isValidFace
        ? _AttendanceCameraColors.success
        : _AttendanceCameraColors.error;
    final icon = isValidFace
        ? Icons.check_circle_outline
        : Icons.cancel_outlined;
    final label =
        (message ?? (isValidFace ? Words.faceConfirmed : Words.faceNotFound))
            .tr();

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
