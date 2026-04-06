
import 'package:equatable/equatable.dart';

abstract class GrsMeasurementDevicesEvent extends Equatable {
  const GrsMeasurementDevicesEvent();

  @override
  List<Object?> get props => [];
}

class GrsMeasurementDevicesLoad extends GrsMeasurementDevicesEvent {}

class GrsMeasurementDevicesLoadMore extends GrsMeasurementDevicesEvent {}


class GrsMeasurementDevicesDetailFetched extends GrsMeasurementDevicesEvent {
  final int documentId;

  const GrsMeasurementDevicesDetailFetched(this.documentId);

  @override
  List<Object> get props => [documentId];
}