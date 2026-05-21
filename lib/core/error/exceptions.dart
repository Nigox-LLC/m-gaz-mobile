/// Data-layer exceptions. Thrown by data sources / API clients and caught
/// by repositories to be mapped into domain [Failure]s.
class ServerException implements Exception {
  ServerException(this.message);
  final String message;
  @override
  String toString() => 'ServerException: $message';
}

class NetworkException implements Exception {
  NetworkException(this.message);
  final String message;
  @override
  String toString() => 'NetworkException: $message';
}

class CacheException implements Exception {
  CacheException(this.message);
  final String message;
  @override
  String toString() => 'CacheException: $message';
}

class UnauthorizedException implements Exception {
  UnauthorizedException(this.message);
  final String message;
  @override
  String toString() => 'UnauthorizedException: $message';
}
