import 'package:equatable/equatable.dart';
import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../../data/datasources/eghu_action_api.dart';
import '../../../../../../data/models/eghu_working_document.dart';
import '../../../../../../domain/entities/action_menu_item.dart';

part 'eghu_action_list_event.dart';
part 'eghu_action_list_state.dart';

class EghuActionListBloc
    extends Bloc<EghuActionListEvent, EghuActionListState> {
  EghuActionListBloc({
    required EghuActionListApi api,
    this.limit = 10,
    this.actionType,
    String? facial,
  }) : _api = api,
       super(EghuActionListState(searchQuery: facial?.trim() ?? '')) {
    on<EghuActionListStarted>(_onStarted);
    on<EghuActionListRefreshed>(_onRefreshed);
    on<EghuActionListLoadMoreRequested>(_onLoadMoreRequested);
    on<EghuActionListSearchChanged>(
      _onSearchChanged,
      transformer: restartable(),
    );
    on<EghuActionListFilterChanged>(
      _onFilterChanged,
      transformer: restartable(),
    );
  }

  final EghuActionListApi _api;
  final int limit;
  final ActionMenuType? actionType;

  Future<void> _onStarted(
    EghuActionListStarted event,
    Emitter<EghuActionListState> emit,
  ) async {
    if (state.status == EghuActionListStatus.loading) return;
    await _loadFirstPage(emit);
  }

  Future<void> _onRefreshed(
    EghuActionListRefreshed event,
    Emitter<EghuActionListState> emit,
  ) async {
    await _loadFirstPage(emit);
  }

  Future<void> _loadFirstPage(Emitter<EghuActionListState> emit) async {
    emit(
      state.copyWith(
        status: EghuActionListStatus.loading,
        errorMessage: '',
        clearNextUrl: true,
        clearDocuments: true,
      ),
    );

    try {
      final response = await _api.getDocuments(
        limit: limit,
        actionType: actionType,
        search: state.searchQuery,
        createdAtFrom: state.filter.dateFrom,
        createdAtTo: state.filter.dateTo,
        regionId: state.filter.regionId,
        districtId: state.filter.districtId,
        reason: state.filter.reason?.apiValue,
      );
      emit(
        state.copyWith(
          status: EghuActionListStatus.success,
          documents: response.results,
          nextUrl: response.next,
          clearNextUrl: response.next == null,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          status: EghuActionListStatus.failure,
          errorMessage: e.toString().replaceAll('Exception: ', ''),
          documents: const [],
          clearNextUrl: true,
        ),
      );
    }
  }

  Future<void> _onSearchChanged(
    EghuActionListSearchChanged event,
    Emitter<EghuActionListState> emit,
  ) async {
    emit(state.copyWith(searchQuery: event.query));

    await Future<void>.delayed(const Duration(milliseconds: 400));
    if (emit.isDone) return;

    await _loadFirstPage(emit);
  }

  Future<void> _onFilterChanged(
    EghuActionListFilterChanged event,
    Emitter<EghuActionListState> emit,
  ) async {
    emit(state.copyWith(filter: event.filter));
    await _loadFirstPage(emit);
  }

  Future<void> _onLoadMoreRequested(
    EghuActionListLoadMoreRequested event,
    Emitter<EghuActionListState> emit,
  ) async {
    if (!state.hasNextPage ||
        state.status == EghuActionListStatus.loadingMore ||
        state.status == EghuActionListStatus.loading) {
      return;
    }

    emit(state.copyWith(status: EghuActionListStatus.loadingMore));

    try {
      final response = await _api.getNextPage(state.nextUrl!);
      emit(
        state.copyWith(
          status: EghuActionListStatus.success,
          documents: [...state.documents, ...response.results],
          nextUrl: response.next,
          clearNextUrl: response.next == null,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          status: EghuActionListStatus.failure,
          errorMessage: e.toString().replaceAll('Exception: ', ''),
        ),
      );
    }
  }
}
