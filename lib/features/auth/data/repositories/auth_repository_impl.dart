import 'dart:io';

import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_local_data_source.dart';
import '../datasources/auth_remote_data_source.dart';

@LazySingleton(as: AuthRepository)
class AuthRepositoryImpl implements AuthRepository {
  AuthRepositoryImpl(this._remote, this._local);

  final AuthRemoteDataSource _remote;
  final AuthLocalDataSource _local;

  @override
  Future<Either<Failure, int>> validateCredentials({
    required String userName,
    required String password,
  }) async {
    try {
      final employeeId = await _remote.validateCredentials(
        userName: userName,
        password: password,
      );
      await _local.saveUsername(userName);
      return Right(employeeId);
    } on UnauthorizedException catch (e) {
      return Left(UnauthorizedFailure(e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, User>> loadProfile() async {
    try {
      final userModel = await _remote.loadProfile();
      final employeeId = userModel.employeeId;
      if (employeeId != null) {
        await _local.saveEmployeeId(employeeId);
      }
      return Right(userModel);
    } on UnauthorizedException catch (e) {
      // Token expired or invalid — purge local state so subsequent flows
      // re-authenticate cleanly (mirrors legacy `UserApi.loadUserProfile`).
      await _local.clear();
      return Left(UnauthorizedFailure(e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, User>> updateProfilePhoto({
    required int userId,
    required File photo,
  }) async {
    try {
      await _remote.updateProfilePhoto(userId: userId, photo: photo);
      final user = await _remote.loadProfile();
      return Right(user);
    } on UnauthorizedException catch (e) {
      await _local.clear();
      return Left(UnauthorizedFailure(e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Unit>> logout() async {
    try {
      await _local.clearAll();
      return const Right(unit);
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, String>> getSavedUsername() async {
    try {
      return Right(_local.savedUsername);
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }
}
