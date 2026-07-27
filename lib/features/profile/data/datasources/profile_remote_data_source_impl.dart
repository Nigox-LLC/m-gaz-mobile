import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/error/exceptions.dart';
import '../../../../core/network/api_client.dart';
import '../../../auth/data/datasources/auth_local_data_source.dart';
import '../models/profile_model.dart';
import 'profile_remote_data_source.dart';

/// Concrete remote data source for the profile feature. Uses the
/// clean-architecture [ApiClient] and mirrors the request shape of the legacy
/// `UserApi.loadUserProfile` — but throws typed `*Exception`s instead of
/// generic `Exception` and never touches local storage directly.
///
/// The access token is read through [AuthLocalDataSource] and attached
/// manually, because `AuthInterceptor` is not wired into [ApiClient] yet
/// (same approach as `AuthRemoteDataSourceImpl`).
@LazySingleton(as: ProfileRemoteDataSource)
class ProfileRemoteDataSourceImpl implements ProfileRemoteDataSource {
  ProfileRemoteDataSourceImpl(this._client, this._local);

  final ApiClient _client;
  final AuthLocalDataSource _local;

  @override
  Future<ProfileModel> loadProfile() async {
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
      return ProfileModel.fromJson(data);
    } on DioException catch (e) {
      throw _mapDioError(e, defaultMessage: 'Profil yuklanmadi');
    }
  }

  @override
  Future<void> updatePassword({
    required int userId,
    required String password,
  }) async {
    try {
      await _client.dio.patch(
        'directory/users/$userId/',
        data: {'password': password},
        options: Options(
          contentType: Headers.jsonContentType,
          headers: {
            if (_local.accessToken.isNotEmpty)
              'Authorization': 'Bearer ${_local.accessToken}',
          },
        ),
      );
    } on DioException catch (e) {
      throw _mapDioError(e, defaultMessage: "Parol o'zgartirilmadi");
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
        message == defaultMessage ? 'Sessiya tugadi, qayta kiring' : message,
      );
    }
    if (status != null && status >= 400) {
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
