
import 'package:camera/camera.dart';

class InAppCameraService {
  static CameraController? controller;
  static List<CameraDescription> _cameras = [];

  static Future<bool> initialize() async {
    try {
      _cameras = await availableCameras();
      final frontCamera = _cameras.firstWhere(
            (camera) => camera.lensDirection == CameraLensDirection.front,
        orElse: () => _cameras.first,
      );

      controller = CameraController(
        frontCamera,
        ResolutionPreset.medium,
        enableAudio: false,
      );

      await controller!.initialize();
      return true;
    } catch (e) {
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
  }
}