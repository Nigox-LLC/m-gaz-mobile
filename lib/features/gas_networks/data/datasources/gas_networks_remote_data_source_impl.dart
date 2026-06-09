import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/error/exceptions.dart';
import '../../../../core/network/api_client.dart';
import '../../../auth/data/datasources/auth_local_data_source.dart';
import '../../domain/entities/measurement_device_type.dart';
import '../models/measuring_device_page_model.dart';
import 'gas_networks_remote_data_source.dart';

/// Concrete remote data source for the gas-network measuring-device lists. Uses
/// the clean-architecture [ApiClient] and throws typed `*Exception`s.
///
/// The access token is read through [AuthLocalDataSource] and attached
/// manually, because `AuthInterceptor` is not wired into [ApiClient] yet (same
/// approach as `AuthRemoteDataSourceImpl` / `ProfileRemoteDataSourceImpl`).
@LazySingleton(as: GasNetworksRemoteDataSource)
class GasNetworksRemoteDataSourceImpl implements GasNetworksRemoteDataSource {
  GasNetworksRemoteDataSourceImpl(this._client, this._local);

  final ApiClient _client;
  final AuthLocalDataSource _local;

  String _endpointFor(MeasurementDeviceType type) {
    switch (type) {
      case MeasurementDeviceType.gts:
        return 'grs-measuring-devices-documents/';
      case MeasurementDeviceType.industrialCollectors:
        return 'grs-industrial-collectors-documents/';
      case MeasurementDeviceType.technological:
        return 'technological-measuring-devices-documents/';
    }
  }

  Options get _authOptions => Options(
        contentType: 'application/json',
        headers: {
          if (_local.accessToken.isNotEmpty)
            'Authorization': 'Bearer ${_local.accessToken}',
        },
      );

  @override
  Future<MeasuringDevicePageModel> getDocuments({
    required MeasurementDeviceType type,
    int limit = 20,
    int offset = 0,
  }) async {
    try {
      final response = await _client.dio.get(
        _endpointFor(type),
        queryParameters: {'limit': limit, 'offset': offset},
        options: _authOptions,
      );
      return _parse(response.data);
    } on DioException catch (e) {
      throw _mapDioError(e, defaultMessage: "Ma'lumotlar yuklanmadi");
    }
  }

  @override
  Future<MeasuringDevicePageModel> getNextPage(String url) async {
    try {
      // Strip the absolute origin + `/api/` prefix so the request stays relative
      // to the configured baseUrl.
      final uri = Uri.parse(url);
      final endpoint = uri.path.replaceFirst('/api/', '');
      final response = await _client.dio.get(
        endpoint,
        queryParameters: uri.queryParameters,
        options: _authOptions,
      );
      return _parse(response.data);
    } on DioException catch (e) {
      throw _mapDioError(e, defaultMessage: "Ma'lumotlar yuklanmadi");
    }
  }

  MeasuringDevicePageModel _parse(dynamic data) {
    if (data is! Map<String, dynamic>) {
      throw ServerException("Server noto'g'ri formatda data qaytardi");
    }
    return MeasuringDevicePageModel.fromJson(data);
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
