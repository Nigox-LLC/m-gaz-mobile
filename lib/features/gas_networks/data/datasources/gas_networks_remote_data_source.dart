import '../../domain/entities/measurement_device_type.dart';
import '../models/measuring_device_page_model.dart';

/// Contract for the remote gas-network data source. Implementations talk to the
/// backend and translate transport errors into the typed exceptions declared in
/// `core/error/exceptions.dart`.
abstract class GasNetworksRemoteDataSource {
  /// First page of documents for [type].
  Future<MeasuringDevicePageModel> getDocuments({
    required MeasurementDeviceType type,
    int limit = 20,
    int offset = 0,
  });

  /// Follow-up page from the backend's absolute `next` [url].
  Future<MeasuringDevicePageModel> getNextPage(String url);
}
