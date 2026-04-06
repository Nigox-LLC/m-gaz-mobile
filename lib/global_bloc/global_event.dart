import 'package:equatable/equatable.dart';

abstract class GlobalEvent extends Equatable {
  const GlobalEvent();

  @override
  List<Object?> get props => [];
}

/// Dastlabki ma'lumotlarni yuklash
class EgxuFormInitialDataRequested extends GlobalEvent {}

/// Region tanlandi
class EgxuFormRegionSelected extends GlobalEvent {
  final int regionId;

  const EgxuFormRegionSelected(this.regionId);

  @override
  List<Object?> get props => [regionId];
}

/// District tanlandi
class EgxuFormDistrictSelected extends GlobalEvent {
  final int districtId;

  const EgxuFormDistrictSelected(this.districtId);

  @override
  List<Object?> get props => [districtId];
}

/// GRS tanlandi
class EgxuFormGrsSelected extends GlobalEvent {
  final int grsId;

  const EgxuFormGrsSelected(this.grsId);

  @override
  List<Object?> get props => [grsId];
}

class EgxuFormConsumersRequested extends GlobalEvent {
  final int regionId;
  final int districtId;

  const EgxuFormConsumersRequested({
    required this.regionId,
    required this.districtId,
  });
}

class EgxuTypesRequested extends GlobalEvent {}

class StampInstallationPointsRequested extends GlobalEvent {}

class GetGasNetworksEvent extends GlobalEvent {
  final int regionId;
  final int districtId;

  const GetGasNetworksEvent({
    required this.regionId,
    required this.districtId,
  });
}

// Dastlabki yuklash
class GasEquipmentFetched extends GlobalEvent {}

// Qo'shimcha ma'lumotlar yuklash (pagination)
class GasEquipmentLoadMore extends GlobalEvent {}


