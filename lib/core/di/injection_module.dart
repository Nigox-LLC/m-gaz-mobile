import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';

/// Base URL for the clean-architecture API client. Mirrors the value used by
/// the legacy `ApiBase` but is kept independent so the new client can evolve
/// without touching the legacy layer.
const String apiBaseUrl = 'https://backend.m-gaz.uz/api/';

/// Registers third-party singletons (Dio, etc.) with `get_it` via the
/// `injectable` code generator.
@module
abstract class RegisterModule {
  @lazySingleton
  Dio get dio => Dio(
        BaseOptions(
          baseUrl: apiBaseUrl,
          connectTimeout: const Duration(seconds: 60),
          receiveTimeout: const Duration(seconds: 60),
          sendTimeout: const Duration(seconds: 60),
        ),
      );
}
