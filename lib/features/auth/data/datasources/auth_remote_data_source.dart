import '../models/auth_token_model.dart';
import '../models/user_model.dart';

/// Contract for the remote auth data source. Implementations talk to the
/// backend HTTP API and translate transport errors into the typed exceptions
/// declared in `core/error/exceptions.dart`.
abstract class AuthRemoteDataSource {
  /// Sends username/password to the backend and returns the resulting token
  /// pair. Token persistence is NOT a responsibility of this layer — the
  /// repository decides how/where to store it.
  Future<AuthTokenModel> login({
    required String userName,
    required String password,
  });

  /// Loads the authenticated user's profile. Caller is responsible for
  /// ensuring the access token has already been set on the request (the
  /// concrete implementation reads it from local storage).
  Future<UserModel> loadProfile();
}
