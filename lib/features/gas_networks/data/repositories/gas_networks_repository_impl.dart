import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:m_gaz/core/error/exceptions.dart';
import 'package:m_gaz/core/error/failures.dart';

import '../../domain/entities/measurement_device_type.dart';
import '../../domain/entities/measuring_device_page.dart';
import '../../domain/repositories/gas_networks_repository.dart';
import '../datasources/gas_networks_remote_data_source.dart';

@LazySingleton(as: GasNetworksRepository)
class GasNetworksRepositoryImpl implements GasNetworksRepository {
  GasNetworksRepositoryImpl(this._remote);

  final GasNetworksRemoteDataSource _remote;

  @override
  Future<Either<Failure, MeasuringDevicePage>> getDocuments({
    required MeasurementDeviceType type,
    int limit = 20,
    int offset = 0,
  }) {
    return _guard(
      () => _remote.getDocuments(type: type, limit: limit, offset: offset),
    );
  }

  @override
  Future<Either<Failure, MeasuringDevicePage>> getNextPage(String url) {
    return _guard(() => _remote.getNextPage(url));
  }

  Future<Either<Failure, MeasuringDevicePage>> _guard(
    Future<MeasuringDevicePage> Function() body,
  ) async {
    try {
      return Right(await body());
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
