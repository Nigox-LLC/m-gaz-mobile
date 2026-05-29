import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../data/datasources/eghu_action_api.dart';
import '../../../../../data/models/eghu_working_document.dart';

part 'eghu_action_list_event.dart';
part 'eghu_action_list_state.dart';

class EghuActionListBloc
    extends Bloc<EghuActionListEvent, EghuActionListState> {
  EghuActionListBloc({required EghuActionListApi api, this.limit = 10})
    : _api = api,
      super(const EghuActionListState()) {
    on<EghuActionListStarted>(_onStarted);
    on<EghuActionListRefreshed>(_onRefreshed);
    on<EghuActionListLoadMoreRequested>(_onLoadMoreRequested);
  }

  final EghuActionListApi _api;
  final int limit;

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
      ),
    );

    try {
      final response = await _api.getDocuments(limit: limit);
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
