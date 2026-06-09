part of 'measurement_devices_bloc.dart';

abstract class MeasurementDevicesEvent extends Equatable {
  const MeasurementDevicesEvent();

  @override
  List<Object?> get props => [];
}

/// (Re)loads the first page for [type]. Also sets the active type on the state.
class LoadMeasurementDevices extends MeasurementDevicesEvent {
  final MeasurementDeviceType type;

  const LoadMeasurementDevices(this.type);

  @override
  List<Object?> get props => [type];
}

/// Appends the next page (triggered near the bottom of the list).
class LoadMoreMeasurementDevices extends MeasurementDevicesEvent {
  const LoadMoreMeasurementDevices();
}
