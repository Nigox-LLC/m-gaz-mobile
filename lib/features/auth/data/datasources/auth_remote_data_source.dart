import 'dart:io';

import '../models/user_model.dart';

/// Contract for the remote auth data source. Implementations talk to the
/// backend HTTP API and translate transport errors into the typed exceptions
/// declared in `core/error/exceptions.dart`.
abstract class AuthRemoteDataSource {
  /// Checks username/password without making the returned JWT available to
  /// the application. E-Imzo owns the final authenticated session.
  Future<int> validateCredentials({
    required String userName,
    required String password,
  });

  /// Loads the authenticated user's profile. Caller is responsible for
  /// ensuring the access token has already been set on the request (the
  /// concrete implementation reads it from local storage).
  Future<UserModel> loadProfile();

  Future<void> updateProfilePhoto({required int userId, required File photo});
}
