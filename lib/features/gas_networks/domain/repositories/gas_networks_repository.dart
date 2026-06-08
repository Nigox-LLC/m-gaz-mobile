import 'package:dartz/dartz.dart';
import 'package:m_gaz/core/error/failures.dart';

import '../entities/measurement_device_type.dart';
import '../entities/measuring_device_page.dart';

/// Contract for fetching the gas-network measuring-device document lists.
abstract class GasNetworksRepository {
  /// First page for the given [type].
  Future<Either<Failure, MeasuringDevicePage>> getDocuments({
    required MeasurementDeviceType type,
    int limit = 20,
    int offset = 0,
  });

  /// Follow-up page from the backend's absolute `next` [url].
  Future<Either<Failure, MeasuringDevicePage>> getNextPage(String url);
}
