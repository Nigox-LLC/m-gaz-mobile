import 'package:permission_handler/permission_handler.dart';

class PermissionService {
  static Future<bool> requestAll() async {
    final camera = await Permission.camera.request();
    final location = await Permission.location.request();
    return camera.isGranted && location.isGranted;
  }
}