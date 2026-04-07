import 'package:equatable/equatable.dart';
import '../core/models/global/egxu_list_model.dart';
import '../core/models/global/global_model.dart';
import '../core/models/grs/grs_detail_model/grs_gas_equipment.dart';

// Alohida statuslar har bir ma'lumot turi uchun
enum GlobalGeneralStatus { initial, loading, success, fail }

enum RegionsStatus { initial, loading, loaded, fail }

enum DistrictsStatus { initial, loading, loaded, fail }

enum EmployeesStatus { initial, loading, loaded, fail }

enum ConsumersStatus { initial, loading, loaded, fail }

enum EgxuTypesStatus { initial, loading, loaded, fail }

enum ActivityTypesStatus { initial, loading, loaded, fail }

enum GasNetworksStatus { initial, loading, loaded, fail }

enum ConnectionPointsStatus { initial, loading, loaded, fail }

enum DirectionsStatus { initial, loading, loaded, fail }

enum MinistriesStatus { initial, loading, loaded, fail }

enum GrsListStatus { initial, loading, loaded, fail }

enum IndustrialCollectorsStatus { initial, loading, loaded, fail }

enum MeasuringDevicesStatus { initial, loading, loaded, fail }

enum GrpTypesStatus { initial, loading, loaded, fail }

enum NeighborhoodsStatus { initial, loading, loaded, fail }

enum StampInstallationPointsStatus { initial, loading, loaded, fail }

enum GasEquipmentStatus { initial, loading, loaded, loadingMore, fail }

class PaginationInfo extends Equatable {
  final int count;
  final String? next;
  final String? previous;
  final int currentPage;
  final bool hasMore;

  const PaginationInfo({
    this.count = 0,
    this.next,
    this.previous,
    this.currentPage = 1,
    this.hasMore = false,
  });

  PaginationInfo copyWith({
    int? count,
    String? next,
    String? previous,
    int? currentPage,
    bool? hasMore,
  }) {
    return PaginationInfo(
      count: count ?? this.count,
      next: next ?? this.next,
      previous: previous ?? this.previous,
      currentPage: currentPage ?? this.currentPage,
      hasMore: hasMore ?? this.hasMore,
    );
  }

  int? get nextPage {
    if (!hasMore || next == null || next!.isEmpty) return null;
    try {
      final uri = Uri.parse(next!);
      final pageParam = uri.queryParameters['page'];
      if (pageParam != null) {
        return int.tryParse(pageParam);
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  @override
  List<Object?> get props => [count, next, previous, currentPage, hasMore];
}

class GlobalState extends Equatable {
  // Umumiy status
  final GlobalGeneralStatus generalStatus;
  final String? errorMessage;

  // Tanlangan qiymatlar
  final int? regionId;
  final int? districtId;
  final int? employeeId;
  final int? consumerId;

  // Ma'lumotlar statuslari alohida
  final RegionsStatus regionsStatus;
  final DistrictsStatus districtsStatus;
  final EmployeesStatus employeesStatus;
  final ConsumersStatus consumersStatus;
  final EgxuTypesStatus egxuTypesStatus;
  final ActivityTypesStatus activityTypesStatus;
  final GasNetworksStatus gasNetworksStatus;
  final ConnectionPointsStatus connectionPointsStatus;
  final DirectionsStatus directionsStatus;
  final MinistriesStatus ministriesStatus;
  final GrsListStatus grsListStatus;
  final IndustrialCollectorsStatus industrialCollectorsStatus;
  final MeasuringDevicesStatus measuringDevicesStatus;
  final GrpTypesStatus grpTypesStatus;
  final NeighborhoodsStatus neighborhoodsStatus;
  final StampInstallationPointsStatus stampInstallationPointsStatus;
  final GasEquipmentStatus gasEquipmentStatus;

  // Ma'lumotlar
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

  // Pagination
  final PaginationInfo gasEquipmentPagination;
  final bool isLoadingMoreGasEquipment;

  const GlobalState({
    this.generalStatus = GlobalGeneralStatus.initial,
    this.errorMessage,
    this.regionId,
    this.districtId,
    this.employeeId,
    this.consumerId,
    this.regionsStatus = RegionsStatus.initial,
    this.districtsStatus = DistrictsStatus.initial,
    this.employeesStatus = EmployeesStatus.initial,
    this.consumersStatus = ConsumersStatus.initial,
    this.egxuTypesStatus = EgxuTypesStatus.initial,
    this.activityTypesStatus = ActivityTypesStatus.initial,
    this.gasNetworksStatus = GasNetworksStatus.initial,
    this.connectionPointsStatus = ConnectionPointsStatus.initial,
    this.directionsStatus = DirectionsStatus.initial,
    this.ministriesStatus = MinistriesStatus.initial,
    this.grsListStatus = GrsListStatus.initial,
    this.industrialCollectorsStatus = IndustrialCollectorsStatus.initial,
    this.measuringDevicesStatus = MeasuringDevicesStatus.initial,
    this.grpTypesStatus = GrpTypesStatus.initial,
    this.neighborhoodsStatus = NeighborhoodsStatus.initial,
    this.stampInstallationPointsStatus = StampInstallationPointsStatus.initial,
    this.gasEquipmentStatus = GasEquipmentStatus.initial,
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
    this.gasEquipmentPagination = const PaginationInfo(),
    this.isLoadingMoreGasEquipment = false,
  });

  // Helper getterlar
  bool get isLoading => generalStatus == GlobalGeneralStatus.loading;
  bool get isSuccess => generalStatus == GlobalGeneralStatus.success;
  bool get isFail => generalStatus == GlobalGeneralStatus.fail;

  bool get isRegionsLoading => regionsStatus == RegionsStatus.loading;
  bool get isRegionsLoaded => regionsStatus == RegionsStatus.loaded;

  bool get isDistrictsLoading => districtsStatus == DistrictsStatus.loading;
  bool get isDistrictsLoaded => districtsStatus == DistrictsStatus.loaded;

  bool get isEmployeesLoading => employeesStatus == EmployeesStatus.loading;
  bool get isEmployeesLoaded => employeesStatus == EmployeesStatus.loaded;

  bool get isConsumersLoading => consumersStatus == ConsumersStatus.loading;
  bool get isConsumersLoaded => consumersStatus == ConsumersStatus.loaded;

  bool get isEgxuTypesLoading => egxuTypesStatus == EgxuTypesStatus.loading;
  bool get isEgxuTypesLoaded => egxuTypesStatus == EgxuTypesStatus.loaded;

  bool get isActivityTypesLoading => activityTypesStatus == ActivityTypesStatus.loading;
  bool get isActivityTypesLoaded => activityTypesStatus == ActivityTypesStatus.loaded;

  bool get isGasNetworksLoading => gasNetworksStatus == GasNetworksStatus.loading;
  bool get isGasNetworksLoaded => gasNetworksStatus == GasNetworksStatus.loaded;

  bool get isConnectionPointsLoading => connectionPointsStatus == ConnectionPointsStatus.loading;
  bool get isConnectionPointsLoaded => connectionPointsStatus == ConnectionPointsStatus.loaded;

  bool get isDirectionsLoading => directionsStatus == DirectionsStatus.loading;
  bool get isDirectionsLoaded => directionsStatus == DirectionsStatus.loaded;

  bool get isMinistriesLoading => ministriesStatus == MinistriesStatus.loading;
  bool get isMinistriesLoaded => ministriesStatus == MinistriesStatus.loaded;

  bool get isGrsListLoading => grsListStatus == GrsListStatus.loading;
  bool get isGrsListLoaded => grsListStatus == GrsListStatus.loaded;

  bool get isIndustrialCollectorsLoading => industrialCollectorsStatus == IndustrialCollectorsStatus.loading;
  bool get isIndustrialCollectorsLoaded => industrialCollectorsStatus == IndustrialCollectorsStatus.loaded;

  bool get isMeasuringDevicesLoading => measuringDevicesStatus == MeasuringDevicesStatus.loading;
  bool get isMeasuringDevicesLoaded => measuringDevicesStatus == MeasuringDevicesStatus.loaded;

  bool get isGrpTypesLoading => grpTypesStatus == GrpTypesStatus.loading;
  bool get isGrpTypesLoaded => grpTypesStatus == GrpTypesStatus.loaded;

  bool get isNeighborhoodsLoading => neighborhoodsStatus == NeighborhoodsStatus.loading;
  bool get isNeighborhoodsLoaded => neighborhoodsStatus == NeighborhoodsStatus.loaded;

  bool get isStampInstallationPointsLoading => stampInstallationPointsStatus == StampInstallationPointsStatus.loading;
  bool get isStampInstallationPointsLoaded => stampInstallationPointsStatus == StampInstallationPointsStatus.loaded;

  bool get isGasEquipmentLoading => gasEquipmentStatus == GasEquipmentStatus.loading;
  bool get isGasEquipmentLoaded => gasEquipmentStatus == GasEquipmentStatus.loaded;
  bool get isGasEquipmentLoadingMore => gasEquipmentStatus == GasEquipmentStatus.loadingMore;
  bool get hasMoreGasEquipment => gasEquipmentPagination.hasMore;

  GlobalState copyWith({
    GlobalGeneralStatus? generalStatus,
    String? errorMessage,
    int? regionId,
    int? districtId,
    int? employeeId,
    int? consumerId,
    RegionsStatus? regionsStatus,
    DistrictsStatus? districtsStatus,
    EmployeesStatus? employeesStatus,
    ConsumersStatus? consumersStatus,
    EgxuTypesStatus? egxuTypesStatus,
    ActivityTypesStatus? activityTypesStatus,
    GasNetworksStatus? gasNetworksStatus,
    ConnectionPointsStatus? connectionPointsStatus,
    DirectionsStatus? directionsStatus,
    MinistriesStatus? ministriesStatus,
    GrsListStatus? grsListStatus,
    IndustrialCollectorsStatus? industrialCollectorsStatus,
    MeasuringDevicesStatus? measuringDevicesStatus,
    GrpTypesStatus? grpTypesStatus,
    NeighborhoodsStatus? neighborhoodsStatus,
    StampInstallationPointsStatus? stampInstallationPointsStatus,
    GasEquipmentStatus? gasEquipmentStatus,
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
    PaginationInfo? gasEquipmentPagination,
    bool? isLoadingMoreGasEquipment,
    bool clearDistricts = false,
    bool clearEmployees = false,
    bool clearConsumers = false,
    bool clearIndustrialCollectors = false,
    bool clearMeasuringDevices = false,
    bool clearGasEquipment = false,
    bool appendGasEquipment = false,
  }) {
    return GlobalState(
      generalStatus: generalStatus ?? this.generalStatus,
      errorMessage: errorMessage ?? this.errorMessage,
      regionId: regionId ?? this.regionId,
      districtId: districtId ?? this.districtId,
      employeeId: employeeId ?? this.employeeId,
      consumerId: consumerId ?? this.consumerId,
      regionsStatus: regionsStatus ?? this.regionsStatus,
      districtsStatus: districtsStatus ?? this.districtsStatus,
      employeesStatus: employeesStatus ?? this.employeesStatus,
      consumersStatus: consumersStatus ?? this.consumersStatus,
      egxuTypesStatus: egxuTypesStatus ?? this.egxuTypesStatus,
      activityTypesStatus: activityTypesStatus ?? this.activityTypesStatus,
      gasNetworksStatus: gasNetworksStatus ?? this.gasNetworksStatus,
      connectionPointsStatus: connectionPointsStatus ?? this.connectionPointsStatus,
      directionsStatus: directionsStatus ?? this.directionsStatus,
      ministriesStatus: ministriesStatus ?? this.ministriesStatus,
      grsListStatus: grsListStatus ?? this.grsListStatus,
      industrialCollectorsStatus: industrialCollectorsStatus ?? this.industrialCollectorsStatus,
      measuringDevicesStatus: measuringDevicesStatus ?? this.measuringDevicesStatus,
      grpTypesStatus: grpTypesStatus ?? this.grpTypesStatus,
      neighborhoodsStatus: neighborhoodsStatus ?? this.neighborhoodsStatus,
      stampInstallationPointsStatus: stampInstallationPointsStatus ?? this.stampInstallationPointsStatus,
      gasEquipmentStatus: gasEquipmentStatus ?? this.gasEquipmentStatus,
      regions: regions ?? this.regions,
      districts: clearDistricts ? const [] : (districts ?? this.districts),
      employees: clearEmployees ? const [] : (employees ?? this.employees),
      consumers: clearConsumers ? const [] : (consumers ?? this.consumers),
      egxuTypes: egxuTypes ?? this.egxuTypes,
      activityTypes: activityTypes ?? this.activityTypes,
      gasNetworks: gasNetworks ?? this.gasNetworks,
      connectionPoints: connectionPoints ?? this.connectionPoints,
      directions: directions ?? this.directions,
      ministries: ministries ?? this.ministries,
      grsList: grsList ?? this.grsList,
      industrialCollectors: clearIndustrialCollectors
          ? const []
          : (industrialCollectors ?? this.industrialCollectors),
      measuringDevices: clearMeasuringDevices
          ? const []
          : (measuringDevices ?? this.measuringDevices),
      grpTypes: grpTypes ?? this.grpTypes,
      neighborhoods: neighborhoods ?? this.neighborhoods,
      stampInstallationPoints: stampInstallationPoints ?? this.stampInstallationPoints,
      gasEquipment: clearGasEquipment
          ? const []
          : appendGasEquipment
          ? [...this.gasEquipment, ...(gasEquipment ?? [])]
          : (gasEquipment ?? this.gasEquipment),
      gasEquipmentPagination: gasEquipmentPagination ?? this.gasEquipmentPagination,
      isLoadingMoreGasEquipment: isLoadingMoreGasEquipment ?? this.isLoadingMoreGasEquipment,
    );
  }

  @override
  List<Object?> get props => [
    generalStatus,
    errorMessage,
    regionId,
    districtId,
    employeeId,
    consumerId,
    regionsStatus,
    districtsStatus,
    employeesStatus,
    consumersStatus,
    egxuTypesStatus,
    activityTypesStatus,
    gasNetworksStatus,
    connectionPointsStatus,
    directionsStatus,
    ministriesStatus,
    grsListStatus,
    industrialCollectorsStatus,
    measuringDevicesStatus,
    grpTypesStatus,
    neighborhoodsStatus,
    stampInstallationPointsStatus,
    gasEquipmentStatus,
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
    gasEquipmentPagination,
    isLoadingMoreGasEquipment,
  ];
}