import 'package:flutter_bloc/flutter_bloc.dart';
import '../core/api/global/global_api.dart';
import '../di.dart';
import 'global_event.dart';
import 'global_state.dart';

class GlobalBloc extends Bloc<GlobalEvent, GlobalState> {
  final GlobalApi _api = di.get<GlobalApi>();

  GlobalBloc() : super(const GlobalState()) {
    on<EgxuFormInitialDataRequested>(_onInitial);
    on<EgxuFormRegionSelected>(_onRegionSelected);
    on<EgxuFormDistrictSelected>(_onDistrictSelected);
    on<EgxuFormGrsSelected>(_onGrsSelected);
    on<EgxuFormConsumersRequested>(_onConsumersRequested);
    on<EgxuTypesRequested>(_onEgxuTypesRequested);
    on<StampInstallationPointsRequested>(_onStampInstallationPointsRequested);
    on<GetGasNetworksEvent>(_getGasNetworks);
    on<GasEquipmentFetched>(_onGetGasEquipment);
    on<GasEquipmentLoadMore>(_onLoadMore);
  }

  // ================= INITIAL =================

  Future<void> _onInitial(
      EgxuFormInitialDataRequested event,
      Emitter<GlobalState> emit,
      ) async {
    emit(state.copyWith(
      generalStatus: GlobalGeneralStatus.loading,
      regionsStatus: RegionsStatus.loading,
      activityTypesStatus: ActivityTypesStatus.loading,
      connectionPointsStatus: ConnectionPointsStatus.loading,
      directionsStatus: DirectionsStatus.loading,
      ministriesStatus: MinistriesStatus.loading,
      grpTypesStatus: GrpTypesStatus.loading,
      stampInstallationPointsStatus: StampInstallationPointsStatus.loading,
    ));

    try {
      final results = await Future.wait([
        _api.getRegions(),
        _api.getActivityTypes(),
        _api.getEgxuConnectionPoints(),
        _api.getDirections(),
        _api.getMinistries(),
        _api.getGrpTypes(),
        _api.getStampInstallationPoints(),
      ]);

      emit(state.copyWith(
        generalStatus: GlobalGeneralStatus.success,
        regionsStatus: RegionsStatus.loaded,
        activityTypesStatus: ActivityTypesStatus.loaded,
        connectionPointsStatus: ConnectionPointsStatus.loaded,
        directionsStatus: DirectionsStatus.loaded,
        ministriesStatus: MinistriesStatus.loaded,
        grpTypesStatus: GrpTypesStatus.loaded,
        stampInstallationPointsStatus: StampInstallationPointsStatus.loaded,
        regions: results[0],
        activityTypes: results[1],
        connectionPoints: results[2],
        directions: results[3],
        ministries: results[4],
        grpTypes: results[5],
        stampInstallationPoints: results[6],
      ));
    } catch (e) {
      emit(state.copyWith(
        generalStatus: GlobalGeneralStatus.fail,
        errorMessage: e.toString().replaceAll('Exception: ', ''),
      ));
    }
  }

  // ================= EGXU TYPES =================

  Future<void> _onEgxuTypesRequested(
      EgxuTypesRequested event,
      Emitter<GlobalState> emit,
      ) async {
    emit(state.copyWith(egxuTypesStatus: EgxuTypesStatus.loading));

    try {
      final types = await _api.getEgxuTypes();
      emit(state.copyWith(
        egxuTypesStatus: EgxuTypesStatus.loaded,
        egxuTypes: types,
      ));
    } catch (e) {
      emit(state.copyWith(
        egxuTypesStatus: EgxuTypesStatus.fail,
        errorMessage: e.toString(),
      ));
    }
  }

  // ================= CONSUMERS =================

  Future<void> _onConsumersRequested(
      EgxuFormConsumersRequested event,
      Emitter<GlobalState> emit,
      ) async {
    emit(state.copyWith(consumersStatus: ConsumersStatus.loading));

    try {
      final consumers = await _api.getConsumers(
        regionId: event.regionId,
        districtId: event.districtId,
      );

      emit(state.copyWith(
        consumersStatus: ConsumersStatus.loaded,
        consumers: consumers,
      ));
    } catch (e) {
      emit(state.copyWith(
        consumersStatus: ConsumersStatus.fail,
        errorMessage: e.toString(),
      ));
    }
  }

  // ================= REGION =================

  Future<void> _onRegionSelected(
      EgxuFormRegionSelected event,
      Emitter<GlobalState> emit,
      ) async {
    emit(state.copyWith(
      regionId: event.regionId,
      districtId: null,
      clearDistricts: true,
      districtsStatus: DistrictsStatus.loading,
    ));

    try {
      final districts = await _api.getDistricts(event.regionId);
      emit(state.copyWith(
        districtsStatus: DistrictsStatus.loaded,
        districts: districts,
      ));
    } catch (e) {
      emit(state.copyWith(
        districtsStatus: DistrictsStatus.fail,
        errorMessage: e.toString(),
      ));
    }
  }

  // ================= DISTRICT =================

  Future<void> _onDistrictSelected(
      EgxuFormDistrictSelected event,
      Emitter<GlobalState> emit,
      ) async {
    emit(state.copyWith(
      districtId: event.districtId,
      employeesStatus: EmployeesStatus.loading,
      consumersStatus: ConsumersStatus.loading,
      neighborhoodsStatus: NeighborhoodsStatus.loading,
      gasNetworksStatus: GasNetworksStatus.loading,
    ));

    try {
      final rId = state.regionId!;

      final employeesResponse = await _api.getEmployees(
        regionId: rId,
        districtId: event.districtId,
      );

      final results = await Future.wait([
        _api.getConsumers(regionId: rId, districtId: event.districtId),
        _api.getNeighborhoods(regionId: rId, districtId: event.districtId),
      ]);

      emit(state.copyWith(
        employeesStatus: EmployeesStatus.loaded,
        consumersStatus: ConsumersStatus.loaded,
        neighborhoodsStatus: NeighborhoodsStatus.loaded,
        gasNetworksStatus: GasNetworksStatus.loaded,
        employees: employeesResponse.results,
        consumers: results[0],
        neighborhoods: results[1],
      ));
    } catch (e) {
      emit(state.copyWith(
        employeesStatus: EmployeesStatus.fail,
        consumersStatus: ConsumersStatus.fail,
        neighborhoodsStatus: NeighborhoodsStatus.fail,
        gasNetworksStatus: GasNetworksStatus.fail,
        errorMessage: e.toString(),
      ));
    }
  }

  // ================= GAS NETWORKS =================

  Future<void> _getGasNetworks(
      GetGasNetworksEvent event,
      Emitter<GlobalState> emit,
      ) async {
    emit(state.copyWith(gasNetworksStatus: GasNetworksStatus.loading));

    try {
      final result = await _api.getGasNetworks(
        regionId: event.regionId,
        districtId: event.districtId,
      );

      emit(state.copyWith(
        gasNetworksStatus: GasNetworksStatus.loaded,
        gasNetworks: result,
      ));
    } catch (e) {
      emit(state.copyWith(
        gasNetworksStatus: GasNetworksStatus.fail,
        errorMessage: e.toString(),
      ));
    }
  }

  // ================= GRS =================

  Future<void> _onGrsSelected(
      EgxuFormGrsSelected event,
      Emitter<GlobalState> emit,
      ) async {
    emit(state.copyWith(
      industrialCollectorsStatus: IndustrialCollectorsStatus.loading,
      measuringDevicesStatus: MeasuringDevicesStatus.loading,
    ));

    try {
      final rId = state.regionId!;
      final results = await Future.wait([
        _api.getIndustrialCollectors(regionId: rId, grsId: event.grsId),
        _api.getMeasuringDevices(regionId: rId, grsId: event.grsId),
      ]);

      emit(state.copyWith(
        industrialCollectorsStatus: IndustrialCollectorsStatus.loaded,
        measuringDevicesStatus: MeasuringDevicesStatus.loaded,
        industrialCollectors: results[0],
        measuringDevices: results[1],
      ));
    } catch (e) {
      emit(state.copyWith(
        industrialCollectorsStatus: IndustrialCollectorsStatus.fail,
        measuringDevicesStatus: MeasuringDevicesStatus.fail,
        errorMessage: e.toString(),
      ));
    }
  }

  // ================= STAMP INSTALLATION POINTS =================

  Future<void> _onStampInstallationPointsRequested(
      StampInstallationPointsRequested event,
      Emitter<GlobalState> emit,
      ) async {
    emit(state.copyWith(
      stampInstallationPointsStatus: StampInstallationPointsStatus.loading,
    ));

    try {
      final list = await _api.getStampInstallationPoints();
      emit(state.copyWith(
        stampInstallationPointsStatus: StampInstallationPointsStatus.loaded,
        stampInstallationPoints: list,
      ));
    } catch (e) {
      emit(state.copyWith(
        stampInstallationPointsStatus: StampInstallationPointsStatus.fail,
        errorMessage: e.toString(),
      ));
    }
  }

  // ================= GAS EQUIPMENT =================

  Future<void> _onGetGasEquipment(
      GasEquipmentFetched event,
      Emitter<GlobalState> emit,
      ) async {
    emit(state.copyWith(
      gasEquipmentStatus: GasEquipmentStatus.loading,
      clearGasEquipment: true,
    ));

    try {
      final response = await _api.getGasEquipment(limit: 10);
      emit(state.copyWith(
        gasEquipmentStatus: GasEquipmentStatus.loaded,
        gasEquipment: response.results,
        gasEquipmentPagination: PaginationInfo(
          count: response.count,
          next: response.next,
          hasMore: response.next != null,
        ),
      ));
    } catch (e) {
      emit(state.copyWith(
        gasEquipmentStatus: GasEquipmentStatus.fail,
        errorMessage: e.toString().replaceAll('Exception: ', ''),
      ));
    }
  }

  Future<void> _onLoadMore(
      GasEquipmentLoadMore event,
      Emitter<GlobalState> emit,
      ) async {
    if (state.isLoadingMoreGasEquipment || !state.hasMoreGasEquipment) {
      return;
    }

    emit(state.copyWith(
      gasEquipmentStatus: GasEquipmentStatus.loadingMore,
      isLoadingMoreGasEquipment: true,
    ));

    try {
      final nextUrl = state.gasEquipmentPagination.next;
      if (nextUrl == null) return;

      final response = await _api.getNextPage(nextUrl);
      emit(state.copyWith(
        gasEquipmentStatus: GasEquipmentStatus.loaded,
        appendGasEquipment: true,
        gasEquipment: response.results,
        gasEquipmentPagination: PaginationInfo(
          next: response.next,
          hasMore: response.next != null,
        ),
        isLoadingMoreGasEquipment: false,
      ));
    } catch (e) {
      emit(state.copyWith(
        gasEquipmentStatus: GasEquipmentStatus.fail,
        errorMessage: e.toString().replaceAll('Exception: ', ''),
        isLoadingMoreGasEquipment: false,
      ));
    }
  }
}