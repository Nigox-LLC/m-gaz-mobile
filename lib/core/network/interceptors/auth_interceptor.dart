import 'package:dio/dio.dart';

/// Synchronous accessor that returns the current access token (or `null`
/// when the user is anonymous). Provided by the auth feature.
typedef TokenReader = String? Function();

/// Asynchronous callback that refreshes the token on 401/403 and returns
/// the new token (or `null` if refresh failed). Provided by the auth
/// feature.
typedef TokenRefresher = Future<String?> Function();

/// Adds the `Authorization: Bearer <token>` header to outbound requests and
/// retries them once after a successful refresh on `401`/`403`.
///
/// This class has **no** UI dependencies — tokens are read/refreshed via
/// the callbacks passed to the constructor. It is **not** wired into Dio
/// yet; that happens during the auth migration phase.
class AuthInterceptor extends Interceptor {
  AuthInterceptor({
    required this.readToken,
    required this.refreshToken,
  });

  final TokenReader readToken;
  final TokenRefresher refreshToken;

  @override
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) {
    final token = readToken();
    if (token != null && token.isNotEmpty) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    handler.next(options);
  }

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    final status = err.response?.statusCode;
    if (status != 401 && status != 403) {
      return handler.next(err);
    }

    final newToken = await refreshToken();
    if (newToken == null || newToken.isEmpty) {
      return handler.next(err);
    }

    // Retry once with the refreshed token.
    final retried = err.requestOptions;
    retried.headers['Authorization'] = 'Bearer $newToken';
    try {
      final dio = Dio(BaseOptions(baseUrl: retried.baseUrl));
      final response = await dio.fetch<dynamic>(retried);
      return handler.resolve(response);
    } on DioException catch (e) {
      return handler.next(e);
    }
  }
}
