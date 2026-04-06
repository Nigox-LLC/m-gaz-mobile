import 'dart:ui';
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
    await _load(
      emit,
      before: () => emit(state.copyWith(status: GlobalStatus.loading)),
      request: () async {
        final results = await Future.wait([
          _api.getRegions(),
          _api.getActivityTypes(),
          _api.getEgxuConnectionPoints(),
          _api.getDirections(),
          _api.getMinistries(),
          _api.getGrpTypes(),
          _api.getStampInstallationPoints(),
        ]);

        emit(
          state.copyWith(
            status: GlobalStatus.loaded,
            regions: results[0],
            activityTypes: results[1],
            connectionPoints: results[2],
            directions: results[3],
            ministries: results[4],
            grpTypes: results[5],
            stampInstallationPoints: results[6],
          ),
        );
      },
    );
  }

  Future<void> _onEgxuTypesRequested(
    EgxuTypesRequested event,
    Emitter<GlobalState> emit,
  ) async {
    emit(state.copyWith(status: GlobalStatus.loading));

    try {
      final types = await _api.getEgxuTypes();
      emit(state.copyWith(status: GlobalStatus.loaded, egxuTypes: types));
    } catch (e) {
      emit(
        state.copyWith(status: GlobalStatus.fail, errorMessage: e.toString()),
      );
    }
  }

  Future<void> _onConsumersRequested(
    EgxuFormConsumersRequested event,
    Emitter<GlobalState> emit,
  ) async {
    emit(state.copyWith(isConsumerLoading: true));

    await _load(
      emit,
      request: () async {
        final consumers = await _api.getConsumers(
          regionId: event.regionId,
          districtId: event.districtId,
        );

        emit(state.copyWith(consumers: consumers, isConsumerLoading: false));
      },
    );
  }

  // ================= REGION =================

  Future<void> _onRegionSelected(
    EgxuFormRegionSelected event,
    Emitter<GlobalState> emit,
  ) async {
    emit(
      state.copyWith(
        regionId: event.regionId,
        districtId: null,
        districts: const [],
        isDistrictLoading: true,
      ),
    );

    await _load(
      emit,
      request: () async {
        final districts = await _api.getDistricts(event.regionId);
        emit(state.copyWith(districts: districts, isDistrictLoading: false));
      },
    );
  }

  // ================= DISTRICT =================

  Future<void> _onDistrictSelected(
    EgxuFormDistrictSelected event,
    Emitter<GlobalState> emit,
  ) async {
    emit(
      state.copyWith(
        districtId: event.districtId,
        isEmployeeLoading: true,
        isConsumerLoading: true,
        isNeighborhoodLoading: true,
        isGasNetworkLoading: true,
      ),
    );

    await _load(
      emit,
      request: () async {
        final rId = state.regionId!;

        final employeesResponse = await _api.getEmployees(
          regionId: rId,
          districtId: event.districtId,
        );

        final results = await Future.wait([
          _api.getConsumers(regionId: rId, districtId: event.districtId),
          _api.getNeighborhoods(regionId: rId, districtId: event.districtId),
        ]);

        emit(
          state.copyWith(
            employees: employeesResponse.results,
            consumers: results[0],
            neighborhoods: results[1],
            isEmployeeLoading: false,
            isConsumerLoading: false,
            isNeighborhoodLoading: false,
            isGasNetworkLoading: false,
          ),
        );
      },
    );
  }

  Future<void> _getGasNetworks(
    GetGasNetworksEvent event,
    Emitter<GlobalState> emit,
  ) async {
    emit(
      state.status == GlobalStatus.loading
          ? state.copyWith(isGasNetworkLoading: true)
          : state,
    );

    try {
      final result = await _api.getGasNetworks(
        regionId: event.regionId,
        districtId: event.districtId,
      );

      emit(state.copyWith(gasNetworks: result, isGasNetworkLoading: false));
    } catch (e) {
      emit(
        state.copyWith(isGasNetworkLoading: false, errorMessage: e.toString()),
      );
    }
  }

  // ================= GRS =================

  Future<void> _onGrsSelected(
    EgxuFormGrsSelected event,
    Emitter<GlobalState> emit,
  ) async {
    emit(
      state.copyWith(
        isIndustrialCollectorLoading: true,
        isMeasuringDeviceLoading: true,
      ),
    );

    await _load(
      emit,
      request: () async {
        final rId = state.regionId!;
        final results = await Future.wait([
          _api.getIndustrialCollectors(regionId: rId, grsId: event.grsId),
          _api.getMeasuringDevices(regionId: rId, grsId: event.grsId),
        ]);

        emit(
          state.copyWith(
            industrialCollectors: results[0],
            measuringDevices: results[1],
            isIndustrialCollectorLoading: false,
            isMeasuringDeviceLoading: false,
          ),
        );
      },
    );
  }

  // ================= HELPER =================

  Future<void> _load(
    Emitter<GlobalState> emit, {
    required Future<void> Function() request,
    VoidCallback? before,
  }) async {
    try {
      before?.call();
      await request();
    } catch (e) {
      emit(
        state.copyWith(
          isDistrictLoading: false,
          isEmployeeLoading: false,
          isConsumerLoading: false,
          isNeighborhoodLoading: false,
          isGasNetworkLoading: false,
          isIndustrialCollectorLoading: false,
          isMeasuringDeviceLoading: false,
          errorMessage: e.toString().replaceAll('Exception: ', ''),
        ),
      );
    }
  }

  Future<void> _onStampInstallationPointsRequested(
    StampInstallationPointsRequested event,
    Emitter<GlobalState> emit,
  ) async {
    emit(state.copyWith(isStampInstallationPointLoading: true));

    await _load(
      emit,
      request: () async {
        final list = await _api.getStampInstallationPoints();
        emit(
          state.copyWith(
            stampInstallationPoints: list,
            isStampInstallationPointLoading: false,
          ),
        );
      },
    );
  }

  Future<void> _onGetGasEquipment(
    GasEquipmentFetched event,
    Emitter<GlobalState> emit,
  ) async {
    emit(state.copyWith(status: GlobalStatus.loading));
    try {
      final response = await _api.getGasEquipment(limit: 10);
      emit(
        state.copyWith(
          status: GlobalStatus.success,
          gasEquipment: response.results,
          nextUrl: response.next,
          hasReachedMax: response.next == null,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          status: GlobalStatus.fail,
          errorMessage: e.toString().replaceAll('Exception: ', ''),
        ),
      );
    }
  }

  Future<void> _onLoadMore(
    GasEquipmentLoadMore event,
    Emitter<GlobalState> emit,
  ) async {
    if (state.hasReachedMax || state.isLoadingMore || state.nextUrl == null) {
      return;
    }

    emit(state.copyWith(isLoadingMore: true));
    try {
      final response = await _api.getNextPage(state.nextUrl!);
      emit(
        state.copyWith(
          status: GlobalStatus.success,
          gasEquipment: [...state.gasEquipment, ...response.results],
          nextUrl: response.next,
          hasReachedMax: response.next == null,
          isLoadingMore: false,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          status: GlobalStatus.fail,
          errorMessage: e.toString().replaceAll('Exception: ', ''),
          isLoadingMore: false,
        ),
      );
    }
  }
}
