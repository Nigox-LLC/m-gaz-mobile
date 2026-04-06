import 'dart:io';
import 'package:dio/dio.dart';

class ApiService {
  static final Dio _dio = Dio(BaseOptions(
    baseUrl: 'https://your-api.com/api/v1',
    connectTimeout: const Duration(seconds: 30),
  ));

  static Future<bool> sendUserData({
    required File selfie,
    required String locationLink,
  }) async {
    try {
      final formData = FormData.fromMap({
        'selfie': await MultipartFile.fromFile(selfie.path, filename: 'selfie.jpg'),
        'location_link': locationLink,
      });
      final response = await _dio.post('/user/verify-selfie', data: formData);
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }
}