import 'dart:io';

import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/error/exceptions.dart';
import '../../../../core/network/api_client.dart';
import '../models/auth_token_model.dart';
import '../models/user_model.dart';
import 'auth_local_data_source.dart';
import 'auth_remote_data_source.dart';

/// Concrete remote data source. Uses [ApiClient] (the new clean-architecture
/// HTTP client) and mirrors the request/response shape of the legacy
/// `UserApi` — but throws typed `*Exception`s instead of generic
/// `Exception` and never touches local storage.
@LazySingleton(as: AuthRemoteDataSource)
class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  AuthRemoteDataSourceImpl(this._client, this._local);

  final ApiClient _client;
  final AuthLocalDataSource _local;

  @override
  Future<AuthTokenModel> login({
    required String userName,
    required String password,
  }) async {
    try {
      final response = await _client.dio.post(
        'login/',
        data: {'username': userName, 'password': password},
        options: Options(contentType: Headers.jsonContentType),
      );

      final data = response.data;
      if (data is! Map<String, dynamic>) {
        throw ServerException(
          "Server javobi noto'g'ri formatda: ${data.runtimeType}",
        );
      }
      return AuthTokenModel.fromJson(data);
    } on DioException catch (e) {
      throw _mapDioError(e, defaultMessage: 'Login muvaffaqiyatsiz');
    }
  }

  @override
  Future<UserModel> loadProfile() async {
    try {
      final response = await _client.dio.get(
        'directory/profile/',
        options: Options(
          contentType: 'application/json',
          headers: {
            if (_local.accessToken.isNotEmpty)
              'Authorization': 'Bearer ${_local.accessToken}',
          },
        ),
      );

      final data = response.data;
      if (data is! Map<String, dynamic>) {
        throw ServerException("Server noto'g'ri formatda data qaytardi");
      }
      return UserModel.fromJson(data);
    } on DioException catch (e) {
      throw _mapDioError(e, defaultMessage: 'Profil yuklanmadi');
    }
  }

  @override
  Future<void> updateProfilePhoto({
    required int userId,
    required File photo,
  }) async {
    try {
      await _client.dio.patch(
        'directory/users/$userId/',
        data: FormData.fromMap({
          'photo': await MultipartFile.fromFile(photo.path),
        }),
        options: Options(
          headers: {
            if (_local.accessToken.isNotEmpty)
              'Authorization': 'Bearer ${_local.accessToken}',
          },
        ),
      );
    } on DioException catch (e) {
      throw _mapDioError(e, defaultMessage: 'Profil rasmi yuklanmadi');
    }
  }

  Exception _mapDioError(DioException e, {required String defaultMessage}) {
    final status = e.response?.statusCode;
    final data = e.response?.data;
    String message = defaultMessage;
    if (data is Map) {
      final extracted = (data['message'] ?? data['error']);
      if (extracted is String && extracted.isNotEmpty) {
        message = extracted;
      }
    }

    if (status == 401) {
      return UnauthorizedException(
        message == defaultMessage ? "Login yoki parol noto'g'ri" : message,
      );
    }
    if (status == 400) {
      return ServerException(
        message == defaultMessage ? "So'rovda xatolik bor" : message,
      );
    }
    if (status != null) {
      return ServerException(message);
    }

    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
      case DioExceptionType.connectionError:
        return NetworkException(message);
      default:
        return ServerException(message);
    }
  }
}
