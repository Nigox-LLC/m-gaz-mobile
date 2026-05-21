import 'package:injectable/injectable.dart';

/// Abstraction over connectivity checks. Domain/data layers depend on this
/// interface; the concrete implementation may use `connectivity_plus` or
/// `internet_connection_checker` in a later phase.
abstract class NetworkInfo {
  Future<bool> get isConnected;
}

/// Placeholder implementation that always reports the device as connected.
/// Real connectivity integration is intentionally out of scope for the
/// skeleton phase.
@LazySingleton(as: NetworkInfo)
class NetworkInfoImpl implements NetworkInfo {
  @override
  Future<bool> get isConnected => Future.value(true);
}
