import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';

/// New clean-architecture HTTP client.
///
/// Wraps a [Dio] instance provided through DI. Unlike the legacy `ApiBase`,
/// this client has **no** dependency on `BuildContext`, `GlobalKey`,
/// `mainKey`, easy_localization, or any other UI concern — interceptors
/// receive their dependencies via constructor injection.
@lazySingleton
class ApiClient {
  ApiClient(this._dio);

  final Dio _dio;

  /// Underlying Dio instance. Data sources should use this to make requests.
  Dio get dio => _dio;
}
