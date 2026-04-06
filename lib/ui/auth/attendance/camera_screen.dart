import 'dart:io';
import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:camera/camera.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import 'package:m_gaz/core/extension/message_extension.dart';
import 'package:m_gaz/core/utils/colors.dart';
import '../../../core/utils/services/in_app_camera_service.dart';
import 'bloc/attendance_bloc.dart';
import 'bloc/attendance_event.dart';
import 'bloc/attendance_state.dart';
import '../../home/home_screen.dart';

class CameraScreen extends StatefulWidget {
  const CameraScreen({super.key});

  @override
  State<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  bool _sending = false;
  bool _initializing = true;
  bool _error = false;

  // Face detection uchun o'zgaruvchilar
  final FaceDetector _faceDetector = FaceDetector(
    options: FaceDetectorOptions(
      enableClassification: true, // Ko'z ochiq/yopiqligini aniqlash
      enableTracking: true,
      performanceMode: FaceDetectorMode.accurate,
    ),
  );

  bool _faceDetected = false;
  bool _eyesOpen = false;
  String _statusMessage = "Yuzni kameraga qarating";

  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }

  Future<void> _initializeCamera() async {
    setState(() => _initializing = true);
    final initialized = await InAppCameraService.initialize();

    if (!initialized) {
      setState(() {
        _error = true;
        _initializing = false;
      });
    } else {
      // Image streamni boshlash
      _startImageStream();
      setState(() => _initializing = false);
    }
  }

  void _startImageStream() {
    InAppCameraService.controller?.startImageStream((CameraImage image) {
      _processCameraImage(image);
    });
  }

  final List<String> successMessages = [
    "Zo‘r! Juda aniq ko‘rinyapsiz 😎",
    "Ajoyib! Surat olinmoqda 📸",
    "Perfect! Joydan qimirlamang 👍",
    "Zo‘r chiqyapsiz! Bir zum kuting 😉",
  ];

  String randomSuccessMessage() {
    successMessages.shuffle();
    return successMessages.first;
  }

  Future<void> _processCameraImage(CameraImage image) async {
    if (_sending) return;

    // InputImagega aylantirish
    final WriteBuffer allBytes = WriteBuffer();
    for (Plane plane in image.planes) {
      allBytes.putUint8List(plane.bytes);
    }

    final bytes = allBytes.done().buffer.asUint8List();
    final Size size = Size(image.width.toDouble(), image.height.toDouble());

    final inputImage = InputImage.fromBytes(
      bytes: bytes,
      metadata: InputImageMetadata(
        size: size,
        rotation: InputImageRotation.rotation0deg,
        format: InputImageFormat.nv21,
        bytesPerRow: image.planes[0].bytesPerRow,
      ),
    );

    final List<Face> faces = await _faceDetector.processImage(inputImage);

    if (!mounted) return;

    if (faces.isEmpty) {
      setState(() {
        _faceDetected = false;
        _eyesOpen = false;
        _statusMessage = "📌 Iltimos, yuzingizni kameraga qarating";
      });
      return;
    }

    final face = faces.first;

    // Ko‘z ochiqligi
    final leftEye = face.leftEyeOpenProbability ?? 0.0;
    final rightEye = face.rightEyeOpenProbability ?? 0.0;
    final eyesOpen = leftEye > 0.8 && rightEye > 0.8;

    setState(() {
      _faceDetected = true;
      _eyesOpen = eyesOpen;
    });

    if (!eyesOpen) {
      setState(() => _statusMessage = "👀 Ko‘zlaringizni kattaroq oching");
      return;
    }

    // Hammasi OK → Auto capture
    setState(() {
      _statusMessage = randomSuccessMessage();
    });

    _autoTakePicture();
  }

  Future<void> _autoTakePicture() async {
    if (_sending) return;

    // Streamni to'xtatish (kamroq resurs ishlatish uchun)
    await InAppCameraService.controller?.stopImageStream();

    bool hasPermission = await _checkLocationPermission();
    if (!hasPermission) {
      _startImageStream(); // Ruxsat yo'q bo'lsa, streamni qayta boshlash
      return;
    }

    final xFile = await InAppCameraService.takePicture();
    if (xFile == null) {
      showToast(context, "Selfie olinmadi");
      _startImageStream(); // Xato bo'lsa, streamni qayta boshlash
      return;
    }

    File photo = File(xFile.path);
    Position pos = await Geolocator.getCurrentPosition();

    if (mounted) {
      context.read<AttendanceBloc>().add(
        AttendanceSubmit(
          photo: photo,
          data: {
            "lat": pos.latitude.toString(),
            "lng": pos.longitude.toString(),
          },
        ),
      );
      setState(() => _sending = true);
    }
  }

  Future<bool> _checkLocationPermission() async {
    LocationPermission permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    if (permission == LocationPermission.deniedForever) {
      showToast(context, "Ilova GPS ruxsatiga muhtoj");
      return false;
    }

    return permission == LocationPermission.always ||
        permission == LocationPermission.whileInUse;
  }

  @override
  void dispose() {
    InAppCameraService.controller?.stopImageStream();
    _faceDetector.close();
    InAppCameraService.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_initializing) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (_error) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text("Kamera ishga tushmadi"),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _initializeCamera,
                child: const Text("Qayta urinib ko'rish"),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      body: Stack(
        children: [
          /// Kamera preview (Aspect Ratio to'g'rilangan)
          Positioned.fill(
            child: FittedBox(
              fit: BoxFit.cover,
              child: SizedBox(
                width: InAppCameraService.controller!.value.previewSize!.height,
                height: InAppCameraService.controller!.value.previewSize!.width,
                child: CameraPreview(InAppCameraService.controller!),
              ),
            ),
          ),

          /// Status matni
          Positioned(
            top: 60,
            left: 0,
            right: 0,
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: _faceDetected && _eyesOpen
                      ? Colors.green
                      : Colors.black87,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  _statusMessage,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ),

          /// Yuz ramkasi
          if (_faceDetected)
            Positioned.fill(
              child: Center(
                child: Container(
                  width: 250,
                  height: 250,
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: _eyesOpen ? Colors.green : Colors.yellow,
                      width: 3,
                    ),
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
              ),
            ),

          /// Pastdagi tugma (zarurat bo'lsa qo'lda olish uchun)
          Positioned(
            bottom: 40,
            left: 0,
            right: 0,
            child: BlocConsumer<AttendanceBloc, AttendanceState>(
              listener: (context, state) {
                if (state.status == AttendanceStatus.success) {
                  showToast(
                    context,
                    "Foydalanish uchun ruxsat berildi",
                    backgroundColor: AppColors.c17B26A,
                  );
                  setState(() => _sending = false);

                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (_) => const HomeScreen()),
                    (route) => false,
                  );
                }

                if (state.status == AttendanceStatus.fail) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(state.error ?? "Xatolik")),
                  );
                  setState(() => _sending = false);
                  _startImageStream();
                }
              },
              builder: (context, state) {
                return Center(
                  child: ElevatedButton(
                    onPressed: _sending ? null : _autoTakePicture,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      _sending ? "Yuborilmoqda..." : "Qo'lda olish",
                      style: const TextStyle(fontSize: 16),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
