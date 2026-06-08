import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:injectable/injectable.dart';
import 'package:m_gaz/core/error/failures.dart';
import 'package:m_gaz/core/usecase/usecase.dart';

import '../entities/measurement_device_type.dart';
import '../entities/measuring_device_page.dart';
import '../repositories/gas_networks_repository.dart';

/// Loads the first page of measuring-device documents for a device type.
@injectable
class GetMeasuringDeviceDocuments
    implements UseCase<MeasuringDevicePage, GetMeasuringDeviceDocumentsParams> {
  GetMeasuringDeviceDocuments(this._repository);

  final GasNetworksRepository _repository;

  @override
  Future<Either<Failure, MeasuringDevicePage>> call(
    GetMeasuringDeviceDocumentsParams params,
  ) {
    return _repository.getDocuments(
      type: params.type,
      limit: params.limit,
      offset: params.offset,
    );
  }
}

class GetMeasuringDeviceDocumentsParams extends Equatable {
  final MeasurementDeviceType type;
  final int limit;
  final int offset;

  const GetMeasuringDeviceDocumentsParams({
    required this.type,
    this.limit = 20,
    this.offset = 0,
  });

  @override
  List<Object?> get props => [type, limit, offset];
}
