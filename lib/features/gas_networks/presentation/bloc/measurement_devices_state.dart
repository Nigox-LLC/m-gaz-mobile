part of 'measurement_devices_bloc.dart';

class MeasurementDevicesState extends Equatable {
  final Status status;
  final MeasurementDeviceType type;
  final List<MeasuringDeviceDocument> items;
  final String? nextUrl;
  final bool hasReachedMax;
  final bool isLoadingMore;
  final String? errorMessage;

  const MeasurementDevicesState({
    this.status = Status.initial,
    this.type = MeasurementDeviceType.gts,
    this.items = const [],
    this.nextUrl,
    this.hasReachedMax = false,
    this.isLoadingMore = false,
    this.errorMessage,
  });

  MeasurementDevicesState copyWith({
    Status? status,
    MeasurementDeviceType? type,
    List<MeasuringDeviceDocument>? items,
    String? nextUrl,
    bool clearNextUrl = false,
    bool? hasReachedMax,
    bool? isLoadingMore,
    String? errorMessage,
  }) {
    return MeasurementDevicesState(
      status: status ?? this.status,
      type: type ?? this.type,
      items: items ?? this.items,
      nextUrl: clearNextUrl ? null : (nextUrl ?? this.nextUrl),
      hasReachedMax: hasReachedMax ?? this.hasReachedMax,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [
        status,
        type,
        items,
        nextUrl,
        hasReachedMax,
        isLoadingMore,
        errorMessage,
      ];
}
