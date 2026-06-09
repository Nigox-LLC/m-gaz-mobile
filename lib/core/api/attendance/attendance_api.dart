import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../base/base_api.dart';

class AttendanceApi {
  final   ApiBase _base;

  AttendanceApi(this._base);

  /// Kamerani ochishdan oldin foydalanuvchi bugun allaqachon yo'qlama
  /// qilganligini tekshiradi. Bir xil endpoint GET qilinadi va javobdagi
  /// `already_attended` bayrog'i qaytariladi.
  Future<bool> checkAlreadyAttended() async {
    try {
      debugPrint("🔎 Yo'qlama holati tekshirilmoqda...");

      final response = await _base.dio.get(
        "directory/employee-attendance/",
        options: Options(contentType: "application/json"),
      );

      debugPrint("📥 STATUS CODE: ${response.statusCode}");

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = response.data;
        return data is Map && data['already_attended'] == true;
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
