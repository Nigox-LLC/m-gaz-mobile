import 'package:equatable/equatable.dart';
import '../core/models/global/egxu_list_model.dart';
import '../core/models/global/global_model.dart';
import '../core/models/grs/grs_detail_model/grs_gas_equipment.dart';

enum GlobalStatus {
  initial,
  loading,
  loaded,
  submitting,
  submitted,
  success,
  fail,
}

class GlobalState extends Equatable {
  final GlobalStatus status;

  // Asosiy ma'lumotlar
  final int? regionId;
  final int? districtId;
  final int? employeeId;
  final int? consumerId;

  // Dropdown optionlar
  final List<GlobalModel> regions;
  final List<GlobalModel> districts;
  final List<GlobalModel> employees;
  final List<GlobalModel> consumers;
  final List<EgxuListModel> egxuTypes;
  final List<GlobalModel> activityTypes;
  final List<GlobalModel> gasNetworks;
  final List<GlobalModel> connectionPoints;
  final List<GlobalModel> directions;
  final List<GlobalModel> ministries;
  final List<GlobalModel> grsList;
  final List<GlobalModel> industrialCollectors;
  final List<GlobalModel> measuringDevices;
  final List<GlobalModel> grpTypes;
  final List<GlobalModel> neighborhoods;
  final List<GlobalModel> stampInstallationPoints;
  final List<GrsGasEquipment> gasEquipment;
  final String? nextUrl;
  final bool hasReachedMax;
  final bool isLoadingMore;

  // Loading holatlari
  final bool isDistrictLoading;
  final bool isEmployeeLoading;
  final bool isConsumerLoading;
  final bool isGasNetworkLoading;
  final bool isIndustrialCollectorLoading;
  final bool isMeasuringDeviceLoading;
  final bool isNeighborhoodLoading;
  final bool isStampInstallationPointLoading;

  // Xatoliklar
  final String? errorMessage;

  const GlobalState({
    this.status = GlobalStatus.initial,
    this.regionId,
    this.districtId,
    this.employeeId,
    this.consumerId,
    this.regions = const [],
    this.districts = const [],
    this.employees = const [],
    this.consumers = const [],
    this.egxuTypes = const [],
    this.activityTypes = const [],
    this.gasNetworks = const [],
    this.connectionPoints = const [],
    this.directions = const [],
    this.ministries = const [],
    this.grsList = const [],
    this.industrialCollectors = const [],
    this.measuringDevices = const [],
    this.grpTypes = const [],
    this.neighborhoods = const [],
    this.stampInstallationPoints = const [],
    this.gasEquipment = const [],
    this.nextUrl,
    this.hasReachedMax = false,
    this.isLoadingMore = false,
    this.isStampInstallationPointLoading = false,
    this.isDistrictLoading = false,
    this.isEmployeeLoading = false,
    this.isConsumerLoading = false,
    this.isGasNetworkLoading = false,
    this.isIndustrialCollectorLoading = false,
    this.isMeasuringDeviceLoading = false,
    this.isNeighborhoodLoading = false,
    this.errorMessage,
  });

  GlobalState copyWith({
    GlobalStatus? status,

    int? regionId,
    int? districtId,
    int? employeeId,
    int? consumerId,
    List<GlobalModel>? regions,
    List<GlobalModel>? districts,
    List<GlobalModel>? employees,
    List<GlobalModel>? consumers,
    List<EgxuListModel>? egxuTypes,
    List<GlobalModel>? activityTypes,
    List<GlobalModel>? gasNetworks,
    List<GlobalModel>? connectionPoints,
    List<GlobalModel>? directions,
    List<GlobalModel>? ministries,
    List<GlobalModel>? grsList,
    List<GlobalModel>? industrialCollectors,
    List<GlobalModel>? measuringDevices,
    List<GlobalModel>? grpTypes,
    List<GlobalModel>? neighborhoods,
    List<GlobalModel>? stampInstallationPoints,
    List<GrsGasEquipment>? gasEquipment,
    String? nextUrl,
    bool? hasReachedMax,
    bool? isLoadingMore,
    bool? isStampInstallationPointLoading,
    bool? isDistrictLoading,
    bool? isEmployeeLoading,
    bool? isConsumerLoading,
    bool? isGasNetworkLoading,
    bool? isIndustrialCollectorLoading,
    bool? isMeasuringDeviceLoading,
    bool? isNeighborhoodLoading,
    String? errorMessage,
  }) {
    return GlobalState(
      status: status ?? this.status,
      regionId: regionId ?? this.regionId,
      districtId: districtId ?? this.districtId,
      employeeId: employeeId ?? this.employeeId,
      consumerId: consumerId ?? this.consumerId,
      regions: regions ?? this.regions,
      districts: districts ?? this.districts,
      employees: employees ?? this.employees,
      consumers: consumers ?? this.consumers,
      egxuTypes: egxuTypes ?? this.egxuTypes,
      activityTypes: activityTypes ?? this.activityTypes,
      gasNetworks: gasNetworks ?? this.gasNetworks,
      connectionPoints: connectionPoints ?? this.connectionPoints,
      directions: directions ?? this.directions,
      ministries: ministries ?? this.ministries,
      grsList: grsList ?? this.grsList,
      industrialCollectors: industrialCollectors ?? this.industrialCollectors,
      measuringDevices: measuringDevices ?? this.measuringDevices,
      grpTypes: grpTypes ?? this.grpTypes,
      neighborhoods: neighborhoods ?? this.neighborhoods,
      stampInstallationPoints:
          stampInstallationPoints ?? this.stampInstallationPoints,
      gasEquipment: gasEquipment ?? this.gasEquipment,
      nextUrl: nextUrl ?? this.nextUrl,
      hasReachedMax: hasReachedMax ?? this.hasReachedMax,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      isStampInstallationPointLoading:
          isStampInstallationPointLoading ??
          this.isStampInstallationPointLoading,
      isDistrictLoading: isDistrictLoading ?? this.isDistrictLoading,
      isEmployeeLoading: isEmployeeLoading ?? this.isEmployeeLoading,
      isConsumerLoading: isConsumerLoading ?? this.isConsumerLoading,
      isGasNetworkLoading: isGasNetworkLoading ?? this.isGasNetworkLoading,
      isIndustrialCollectorLoading:
          isIndustrialCollectorLoading ?? this.isIndustrialCollectorLoading,
      isMeasuringDeviceLoading:
          isMeasuringDeviceLoading ?? this.isMeasuringDeviceLoading,
      isNeighborhoodLoading:
          isNeighborhoodLoading ?? this.isNeighborhoodLoading,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [
    status,
    regionId,
    districtId,
    employeeId,
    consumerId,
    regions,
    districts,
    employees,
    consumers,
    egxuTypes,
    activityTypes,
    gasNetworks,
    connectionPoints,
    directions,
    ministries,
    grsList,
    industrialCollectors,
    measuringDevices,
    grpTypes,
    neighborhoods,
    stampInstallationPoints,
    gasEquipment,
    nextUrl,
    hasReachedMax,
    isLoadingMore,
    isStampInstallationPointLoading,
    isDistrictLoading,
    isEmployeeLoading,
    isConsumerLoading,
    isGasNetworkLoading,
    isIndustrialCollectorLoading,
    isMeasuringDeviceLoading,
    isNeighborhoodLoading,
    errorMessage,
  ];
}
