import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../data/datasources/eghu_indicator_api.dart';
import '../../../../../data/models/eghu_indicator_document.dart';

part 'eghu_indicator_list_event.dart';
part 'eghu_indicator_list_state.dart';

class EghuIndicatorListBloc
    extends Bloc<EghuIndicatorListEvent, EghuIndicatorListState> {
  EghuIndicatorListBloc({required EghuIndicatorListApi api, this.limit = 10})
    : _api = api,
      super(const EghuIndicatorListState()) {
    on<EghuIndicatorListStarted>(_onStarted);
    on<EghuIndicatorListRefreshed>(_onRefreshed);
    on<EghuIndicatorListLoadMoreRequested>(_onLoadMoreRequested);
    on<EghuIndicatorSearchChanged>(
      _onSearchChanged,
      transformer: restartable(),
    );
    on<EghuIndicatorFilterChanged>(
      _onFilterChanged,
      transformer: restartable(),
    );
  }

  final EghuIndicatorListApi _api;
  final int limit;

  Future<void> _onStarted(
    EghuIndicatorListStarted event,
    Emitter<EghuIndicatorListState> emit,
  ) async {
    if (state.status == EghuIndicatorListStatus.loading) return;
    await _loadFirstPage(emit);
  }

  Future<void> _onRefreshed(
    EghuIndicatorListRefreshed event,
    Emitter<EghuIndicatorListState> emit,
  ) async {
    await _loadFirstPage(emit);
  }

  Future<void> _onSearchChanged(
    EghuIndicatorSearchChanged event,
    Emitter<EghuIndicatorListState> emit,
  ) async {
    emit(state.copyWith(searchQuery: event.query));
    await Future<void>.delayed(const Duration(milliseconds: 400));
    if (emit.isDone) return;
    await _loadFirstPage(emit);
  }

  Future<void> _onFilterChanged(
    EghuIndicatorFilterChanged event,
    Emitter<EghuIndicatorListState> emit,
  ) async {
    emit(state.copyWith(filter: event.filter));
    await _loadFirstPage(emit);
  }

  Future<void> _loadFirstPage(Emitter<EghuIndicatorListState> emit) async {
    emit(
      state.copyWith(
        status: EghuIndicatorListStatus.loading,
        errorMessage: '',
        clearNextUrl: true,
        clearDocuments: true,
      ),
    );

    try {
      final filter = state.filter;
      final response = await _api.getDocuments(
        limit: limit,
        search: state.searchQuery,
        startDate: filter.startDate,
        endDate: filter.endDate,
        regionId: filter.regionId,
        districtId: filter.districtId,
      );
      emit(
        state.copyWith(
          status: EghuIndicatorListStatus.success,
          documents: response.results,
          nextUrl: response.next,
          clearNextUrl: response.next == null,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          status: EghuIndicatorListStatus.failure,
          errorMessage: e.toString().replaceAll('Exception: ', ''),
          documents: const [],
          clearNextUrl: true,
        ),
      );
    }
  }

  Future<void> _onLoadMoreRequested(
    EghuIndicatorListLoadMoreRequested event,
    Emitter<EghuIndicatorListState> emit,
  ) async {
    if (!state.hasNextPage ||
        state.status == EghuIndicatorListStatus.loadingMore ||
        state.status == EghuIndicatorListStatus.loading) {
      return;
    }

    emit(state.copyWith(status: EghuIndicatorListStatus.loadingMore));

    try {
      final response = await _api.getNextPage(state.nextUrl!);
      emit(
        state.copyWith(
          status: EghuIndicatorListStatus.success,
          documents: [...state.documents, ...response.results],
          nextUrl: response.next,
          clearNextUrl: response.next == null,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          status: EghuIndicatorListStatus.failure,
          errorMessage: e.toString().replaceAll('Exception: ', ''),
        ),
      );
    }
  }
}
