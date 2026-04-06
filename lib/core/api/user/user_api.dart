import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import '../../hive/api_hive.dart';
import '../../models/user/token_model.dart';
import '../../models/user/user_model.dart';
import '../base/base_api.dart';

class UserApi {
  final ApiBase _base;

  const UserApi(this._base);
  ApiHive get hive => _base.hive;  // ⭐ Qo'shildi

  Future<void> loginUser({
    required String userName,
    required String password,
  }) async {
    try {
      debugPrint("🔹 Login so'rov yuborilmoqda...");
      debugPrint("🔹 URL: ${_base.dio.options.baseUrl}login/");
      debugPrint("🔹 Body (JSON): {username: $userName, password: $password}");

      final response = await _base.dio.post(
        "login/",
        data: {"username": userName, "password": password},
        options: Options(contentType: Headers.jsonContentType),
      );

      debugPrint("🔹 Javob status code: ${response.statusCode}");
      debugPrint("🔹 Javob headers: ${response.headers}");
      debugPrint("🔹 Javob body: ${response.data}");

      if (response.data == null || response.data is! Map<String, dynamic>) {
        throw Exception(
          "❌ Server javobi noto'g'ri formatda: ${response.data.runtimeType}",
        );
      }

      final tokenModel = TokenModel.fromJson(response.data);
      await _base.hive.putToken(tokenModel);

      debugPrint("✅ ACCESS TOKEN: ${tokenModel.access}");
      debugPrint("✅ REFRESH TOKEN: ${tokenModel.refresh}");
    } on DioException catch (e) {
      final error = e.response?.data;
      String errorMessage =
          error?['message'] ?? error?['error'] ?? "Login muvaffaqiyatsiz";
      if (e.response?.statusCode == 401) {
        errorMessage = "Login yoki parol noto'g'ri";
      } else if (e.response?.statusCode == 400) {
        errorMessage = "So'rovda xatolik bor";
      }
      throw Exception(errorMessage);
    }
  }

  Future<UserModel?> loadUserProfile() async {
    try {
      final response = await _base.dio.get(
        "directory/profile/",
        options: Options(contentType: "application/json"),
      );

      if (response.data is! Map<String, dynamic>) {
        throw Exception("Server noto‘g‘ri formatda data qaytardi");
      }

      return UserModel.fromJson(response.data);

    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        /// TOKEN ESKIRGAN → HIVE CLEAR
        await _base.hive.clear();
        return null;
      }
      throw Exception("Profil yuklanmadi");
    }
  }

  Future<bool> refreshToken() async {
    final refresh = _base.hive.refreshToken;
    if (refresh.isEmpty) return false;

    try {
      final response = await _base.dio.post(
        "api/token/refresh/",
        data: {"refresh": refresh},
        options: Options(
          headers: {"content-type": "application/json"},
          extra: {"no_token": true},
        ),
      );

      if (response.data == null || response.data is! Map<String, dynamic>) {
        throw Exception("Token yangilash javobi noto'g'ri formatda");
      }

      final model = TokenModel.fromJson(response.data);
      await _base.hive.putToken(model);

      debugPrint("Yangi token saqlandi: ${model.access}");
      return true;
    } on DioException catch (e) {
      debugPrint("Token refresh error: ${e.response?.data}");
      await _base.hive.clear();
      return false;
    } catch (e) {
      debugPrint("UNKNOWN ERROR: $e");
      return false;
    }
  }

  Future<void> logout() async => _base.hive.clear();

  Future<void> deleteByOtp({
    required String phone,
    required String code,
  }) async {
    try {
      await _base.dio.post(
        "users/logout/",
        data: {"phone": phone, "code": code},
      );
    } on DioException catch (e) {
      debugPrint("Logout error: ${e.response?.data}");
      final error = e.response?.data;
      throw Exception(
        error?['message'] ?? error?['error'] ?? "Chiqishda xatolik",
      );
    }
  }
}
