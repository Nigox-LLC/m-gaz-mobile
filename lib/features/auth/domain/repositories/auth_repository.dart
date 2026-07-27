import 'dart:io';

import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../entities/user.dart';

/// Domain contract for authentication. Implementations live in the data
/// layer (`AuthRepositoryImpl`).
abstract class AuthRepository {
  /// Validates username/password without persisting the legacy login tokens.
  Future<Either<Failure, int>> validateCredentials({
    required String userName,
    required String password,
  });

  /// Fetches the current user's profile using the stored access token.
  Future<Either<Failure, User>> loadProfile();

  Future<Either<Failure, User>> updateProfilePhoto({
    required int userId,
    required File photo,
  });

  /// Clears the locally stored auth state.
  Future<Either<Failure, Unit>> logout();

  /// Returns the last successfully logged-in username (empty if none), used to
  /// pre-fill the login form on app launch.
  Future<Either<Failure, String>> getSavedUsername();
}
