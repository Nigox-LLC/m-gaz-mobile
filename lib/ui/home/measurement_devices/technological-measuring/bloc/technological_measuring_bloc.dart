import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:m_gaz/ui/home/measurement_devices/technological-measuring/bloc/technological_measuring_event.dart';
import 'package:m_gaz/ui/home/measurement_devices/technological-measuring/bloc/technological_measuring_state.dart';

import '../../../../../core/api/tech_measure_api/tech_Measure_api.dart';
import '../../../../../di.dart';

  class TechMeasureBloc extends Bloc<TechMeasureEvent, TechMeasureState> {
  final TechMeasureApi api = di.get<TechMeasureApi>();

  TechMeasureBloc() : super(const TechMeasureState()) {
    on<TechMeasureLoad>(_onFetched);
    on<TechMeasureLoadMore>(_onLoadMore);
    on<TechMeasureDetailFetched>(_onDocumentFetched);
  }

  Future<void> _onFetched(
    TechMeasureLoad event,
    Emitter<TechMeasureState> emit,
  ) async {
    emit(state.copyWith(status: TechMeasureStatus.loading));
    try {
      final response = await api.getDocuments(limit: 20);
      emit(
        state.copyWith(
          status: TechMeasureStatus.success,
          items: response.results,
          nextUrl: response.next,
          hasReachedMax: response.next == null,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          status: TechMeasureStatus.fail,
          errorMessage: e.toString().replaceAll('Exception: ', ''),
        ),
      );
    }
  }

  Future<void> _onLoadMore(
    TechMeasureLoadMore event,
    Emitter<TechMeasureState> emit,
  ) async {
    if (state.hasReachedMax || state.isLoadingMore || state.nextUrl == null) {
      return;
    }

    emit(state.copyWith(isLoadingMore: true));
    try {
      final response = await api.getNextPage(state.nextUrl!);
      emit(
        state.copyWith(
          status: TechMeasureStatus.success,
          items: [...state.items, ...response.results],
          nextUrl: response.next,
          hasReachedMax: response.next == null,
          isLoadingMore: false,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          status: TechMeasureStatus.fail,
          errorMessage: e.toString().replaceAll('Exception: ', ''),
          isLoadingMore: false,
        ),
      );
    }
  }

  Future<void> _onDocumentFetched(
    TechMeasureDetailFetched event,
    Emitter<TechMeasureState> emit,
  ) async {
    emit(state.copyWith(status: TechMeasureStatus.loading));
    try {
      final document = await api.getDocumentById(event.documentId);
      emit(
        state.copyWith(
          status: TechMeasureStatus.success,
          teachMeasureDetail: document,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          status: TechMeasureStatus.fail,
          errorMessage: e.toString().replaceAll('Exception: ', ''),
        ),
      );
    }
  }
}
