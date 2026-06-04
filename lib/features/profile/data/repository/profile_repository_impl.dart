import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:m_gaz/core/error/exceptions.dart';
import 'package:m_gaz/core/error/failures.dart';
import 'package:m_gaz/features/profile/data/datasources/profile_remote_data_source.dart';
import 'package:m_gaz/features/profile/domain/entities/profile_entity.dart';
import 'package:m_gaz/features/profile/domain/repository/profile_repository.dart';

@LazySingleton(as: ProfileRepository)
class ProfileRepositoryImpl implements ProfileRepository {
  ProfileRepositoryImpl(this._remote);

  final ProfileRemoteDataSource _remote;

  @override
  Future<Either<Failure, ProfileEntity>> loadProfileData() async {
    try {
      final profile = await _remote.loadProfile();
      return Right(profile);
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
}
