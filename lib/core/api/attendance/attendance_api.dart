import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../base/base_api.dart';

class AttendanceApi {
  final   ApiBase _base;

  AttendanceApi(this._base);

  Future<Map<String, dynamic>> sendAttendance({
    required File photo,
    Map<String, dynamic>? data,
  }) async {
    try {
      debugPrint("📸 Attendance yuborilmoqda...");

      final formData = FormData.fromMap({
        if (data != null) ...data,
        // Backend kutayotgan field nomini moslang: "photo" yoki "image"
        "photo": await MultipartFile.fromFile(photo.path),
      });

      final response = await _base.dio.post(
        "directory/employee-attendance/",
        data: formData,
      );

      debugPrint("📥 STATUS CODE: ${response.statusCode}");

      if (response.statusCode == 200 || response.statusCode == 201) {
        return response.data;
      } else {
        throw Exception("Xatolik: ${response.statusCode}");
      }
    } on DioException catch (e) {
      final error = e.response?.data;
      String errorMessage =
          error?['message'] ?? error?['error'] ?? "So'rov bajarilmadi";
      debugPrint("❌ Dio Xatolik: $errorMessage");
      throw Exception(errorMessage);
    } catch (e) {
      debugPrint("❌ UNKNOWN: $e");
      throw Exception("Kutilmagan xatolik: $e");
    }
  }
}
