import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/error/exceptions.dart';
import '../../../../core/network/api_client.dart';
import '../models/auth_token_model.dart';
import '../models/eimzo_mobile_session_model.dart';
import '../models/eimzo_status_model.dart';
import 'eimzo_remote_data_source.dart';

@LazySingleton(as: EImzoRemoteDataSource)
class EImzoRemoteDataSourceImpl implements EImzoRemoteDataSource {
  EImzoRemoteDataSourceImpl(this._client);

  static const _eimzoServer = 'https://m-gaz.uz';

  final ApiClient _client;

  @override
  Future<EImzoMobileSessionModel> startMobileSession() async {
    try {
      final response = await _client.dio.post(
        '$_eimzoServer/frontend/mobile/auth',
        options: Options(contentType: Headers.jsonContentType),
      );
      return EImzoMobileSessionModel.fromJson(_data(response));
    } on DioException catch (error) {
      throw _mapDioError(error, 'E-Imzo sessiyasi ochilmadi');
    } on FormatException catch (error) {
      throw ServerException(error.message);
    }
  }

  @override
  Future<EImzoStatusModel> getMobileStatus(String documentId) async {
    try {
      final response = await _client.dio.post(
        '$_eimzoServer/frontend/mobile/status',
        data: {'documentId': documentId},
        options: Options(contentType: Headers.formUrlEncodedContentType),
      );
      return EImzoStatusModel.fromJson(_data(response));
    } on DioException catch (error) {
      throw _mapDioError(error, 'E-Imzo holati tekshirilmadi');
    } on FormatException catch (error) {
      throw ServerException(error.message);
    }
  }

  @override
  Future<AuthTokenModel> completeMobileLogin({
    required String documentId,
    required int employeeId,
  }) async {
    try {
      final response = await _client.dio.post(
        'e-imzo/auth/e-imzo/mobile/',
        data: {'documentId': documentId, 'employee_id': employeeId},
        options: Options(contentType: Headers.jsonContentType),
      );
      final token = AuthTokenModel.fromJson(_data(response));
      if (token.access.isEmpty || token.refresh.isEmpty) {
        throw ServerException('E-Imzo tokenlari olinmadi');
      }
      return token;
    } on DioException catch (error) {
      throw _mapDioError(error, 'E-Imzo orqali kirish yakunlanmadi');
    }
  }

  Map<String, dynamic> _data(Response<dynamic> response) {
    final data = response.data;
    if (data is Map<String, dynamic>) return data;
    if (data is Map) return Map<String, dynamic>.from(data);
    throw const FormatException('Server response is invalid.');
  }

  Exception _mapDioError(DioException error, String fallback) {
    final data = error.response?.data;
    final message = data is Map && (data['message'] ?? data['error']) is String
        ? (data['message'] ?? data['error']) as String
        : fallback;
    final status = error.response?.statusCode;
    if (status == 401 || status == 403) return UnauthorizedException(message);
    if (status == null) return NetworkException(message);
    return ServerException(message);
  }
}
