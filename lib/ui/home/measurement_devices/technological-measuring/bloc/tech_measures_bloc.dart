import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:m_gaz/ui/home/measurement_devices/technological-measuring/bloc/tech_measures_event.dart';
import 'package:m_gaz/ui/home/measurement_devices/technological-measuring/bloc/tech_measures_state.dart';
import '../../../../../core/api/tech_measure/tech_measure.dart';

class TechMeasuresBloc extends Bloc<TechMeasuresEvent, TechMeasuresState> {
  final TechMeasureApi _api;

  TechMeasuresBloc(this._api) : super(const TechMeasuresState()) {
    on<TechMeasureLoad>(_onFetched);
    on<TechMeasureLoadMore>(_onLoadMore);
    on<TechMeasureDetailFetched>(_onDocumentFetched);
  }

  Future<void> _onFetched(
      TechMeasureLoad event,
      Emitter<TechMeasuresState> emit,
      ) async {
    emit(state.copyWith(status: TechMeasuresStatus.loading));
    try {
      final response = await _api.getDocuments(limit: 20);
      emit(
        state.copyWith(
          status: TechMeasuresStatus.success,
          items: response.results,
          nextUrl: response.next,
          hasReachedMax: response.next == null,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          status: TechMeasuresStatus.fail,
          errorMessage: e.toString().replaceAll('Exception: ', ''),
        ),
      );
    }
  }

  Future<void> _onLoadMore(
      TechMeasureLoadMore event,
      Emitter<TechMeasuresState> emit,
      ) async {
    if (state.hasReachedMax || state.isLoadingMore || state.nextUrl == null) {
      return;
    }

    emit(state.copyWith(isLoadingMore: true));
    try {
      final response = await _api.getNextPage(state.nextUrl!);
      emit(
        state.copyWith(
          status: TechMeasuresStatus.success,
          items: [...state.items, ...response.results],
          nextUrl: response.next,
          hasReachedMax: response.next == null,
          isLoadingMore: false,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          status: TechMeasuresStatus.fail,
          errorMessage: e.toString().replaceAll('Exception: ', ''),
          isLoadingMore: false,
        ),
      );
    }
  }

  Future<void> _onDocumentFetched(
      TechMeasureDetailFetched event,
      Emitter<TechMeasuresState> emit,
      ) async {
    emit(state.copyWith(status: TechMeasuresStatus.loading));
    try {
      final document = await _api.getDocumentById(event.documentId);
      emit(
        state.copyWith(
          status: TechMeasuresStatus.success,
          teachMeasureDetail: document,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          status: TechMeasuresStatus.fail,
          errorMessage: e.toString().replaceAll('Exception: ', ''),
        ),
      );
    }
  }
}
