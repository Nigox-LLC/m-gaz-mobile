import 'dart:io';

import 'package:camera/camera.dart';

class InAppCameraService {
  static CameraController? controller;
  static List<CameraDescription> _cameras = [];
  static CameraDescription? _selectedCamera;

  static CameraDescription? get selectedCamera => _selectedCamera;

  static Future<bool> initialize() async {
    try {
      dispose();
      _cameras = await availableCameras();
      final frontCamera = _cameras.firstWhere(
        (camera) => camera.lensDirection == CameraLensDirection.front,
        orElse: () => _cameras.first,
      );
      _selectedCamera = frontCamera;

      controller = CameraController(
        frontCamera,
        ResolutionPreset.high,
        enableAudio: false,
        imageFormatGroup: Platform.isAndroid
            ? ImageFormatGroup.nv21
            : ImageFormatGroup.bgra8888,
      );

      await controller!.initialize();
      return true;
    } catch (e) {
      _selectedCamera = null;
      return false;
    }
  }

  static Future<XFile?> takePicture() async {
    if (controller == null || !controller!.value.isInitialized) return null;
    try {
      return await controller!.takePicture();
    } catch (e) {
      return null;
    }
  }

  static void dispose() {
    controller?.dispose();
    controller = null;
    _selectedCamera = null;
  }
}
