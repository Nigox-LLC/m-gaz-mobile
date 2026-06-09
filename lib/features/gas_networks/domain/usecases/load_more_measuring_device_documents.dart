import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:injectable/injectable.dart';
import 'package:m_gaz/core/error/failures.dart';
import 'package:m_gaz/core/usecase/usecase.dart';

import '../entities/measuring_device_page.dart';
import '../repositories/gas_networks_repository.dart';

/// Loads the next page of measuring-device documents from a `next` cursor URL.
@injectable
class LoadMoreMeasuringDeviceDocuments
    implements
        UseCase<MeasuringDevicePage, LoadMoreMeasuringDeviceDocumentsParams> {
  LoadMoreMeasuringDeviceDocuments(this._repository);

  final GasNetworksRepository _repository;

  @override
  Future<Either<Failure, MeasuringDevicePage>> call(
    LoadMoreMeasuringDeviceDocumentsParams params,
  ) {
    return _repository.getNextPage(params.nextUrl);
  }
}

class LoadMoreMeasuringDeviceDocumentsParams extends Equatable {
  final String nextUrl;

  const LoadMoreMeasuringDeviceDocumentsParams(this.nextUrl);

  @override
  List<Object?> get props => [nextUrl];
}
