import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/auth_token.dart';
import '../../domain/entities/eimzo_mobile_session.dart';
import '../../domain/entities/eimzo_status.dart';
import '../../domain/repositories/eimzo_auth_repository.dart';
import '../datasources/auth_local_data_source.dart';
import '../datasources/eimzo_remote_data_source.dart';

@LazySingleton(as: EImzoAuthRepository)
class EImzoAuthRepositoryImpl implements EImzoAuthRepository {
  EImzoAuthRepositoryImpl(this._remote, this._local);

  final EImzoRemoteDataSource _remote;
  final AuthLocalDataSource _local;

  @override
  Future<Either<Failure, EImzoMobileSession>> startMobileSession() =>
      _guard(_remote.startMobileSession);

  @override
  Future<Either<Failure, EImzoStatus>> getMobileStatus(String documentId) =>
      _guard(() => _remote.getMobileStatus(documentId));

  @override
  Future<Either<Failure, AuthToken>> completeMobileLogin({
    required String documentId,
    required int employeeId,
  }) async {
    try {
      final token = await _remote.completeMobileLogin(
        documentId: documentId,
        employeeId: employeeId,
      );
      await _local.saveToken(token);
      return Right(token);
    } on UnauthorizedException catch (error) {
      return Left(UnauthorizedFailure(error.message));
    } on NetworkException catch (error) {
      return Left(NetworkFailure(error.message));
    } on ServerException catch (error) {
      return Left(ServerFailure(error.message));
    } catch (error) {
      return Left(ServerFailure(error.toString()));
    }
  }

  Future<Either<Failure, T>> _guard<T>(Future<T> Function() request) async {
    try {
      return Right(await request());
    } on UnauthorizedException catch (error) {
      return Left(UnauthorizedFailure(error.message));
    } on NetworkException catch (error) {
      return Left(NetworkFailure(error.message));
    } on ServerException catch (error) {
      return Left(ServerFailure(error.message));
    } catch (error) {
      return Left(ServerFailure(error.toString()));
    }
  }
}
