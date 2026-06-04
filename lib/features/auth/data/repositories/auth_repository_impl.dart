import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/auth_token.dart';
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
  Future<Either<Failure, AuthToken>> login({
    required String userName,
    required String password,
  }) async {
    try {
      final tokenModel = await _remote.login(
        userName: userName,
        password: password,
      );
      await _local.saveToken(tokenModel);
      await _local.saveUsername(userName);
      return Right(tokenModel);
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
  Future<Either<Failure, Unit>> logout() async {
    try {
      await _local.clearAll();
      return const Right(unit);
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, bool>> requiresDailyAgreement() async {
    try {
      final now = DateTime.now();
      final todayStr = '${now.year}-${now.month}-${now.day}';
      final lastDate = _local.lastAgreementDate;
      if (lastDate != todayStr) {
        _local.lastAgreementDate = todayStr;
        return const Right(true);
      }
      return const Right(false);
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
