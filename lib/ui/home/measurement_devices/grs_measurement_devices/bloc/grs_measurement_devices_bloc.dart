
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../../core/api/grs/grs_measurement_api.dart';
import '../../../../../di.dart';
import 'grs_measurement_devices_event.dart';
import 'grs_measurement_devices_state.dart';

class GrsMeasurementDevicesBloc extends Bloc<GrsMeasurementDevicesEvent, GrsMeasurementDevicesState> {
  final GrsMeasurementDevicesApi api = di.get<GrsMeasurementDevicesApi>();

  GrsMeasurementDevicesBloc() : super(const GrsMeasurementDevicesState()) {
    on<GrsMeasurementDevicesLoad>(_onFetched);
    on<GrsMeasurementDevicesLoadMore>(_onLoadMore);
    on<GrsMeasurementDevicesDetailFetched>(_onDocumentFetched);
  }

  Future<void> _onFetched(
      GrsMeasurementDevicesLoad event,
      Emitter<GrsMeasurementDevicesState> emit,
      ) async {
    emit(state.copyWith(status: GrsMeasurementDevicesStatus.loading));
    try {
      final response = await api.getDocuments(limit: 20);
      emit(
        state.copyWith(
          status: GrsMeasurementDevicesStatus.success,
          items: response.results,
          nextUrl: response.next,
          hasReachedMax: response.next == null,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          status: GrsMeasurementDevicesStatus.fail,
          errorMessage: e.toString().replaceAll('Exception: ', ''),
        ),
      );
    }
  }

  Future<void> _onLoadMore(
      GrsMeasurementDevicesLoadMore event,
      Emitter<GrsMeasurementDevicesState> emit,
      ) async {
    if (state.hasReachedMax || state.isLoadingMore || state.nextUrl == null) {
      return;
    }

    emit(state.copyWith(isLoadingMore: true));
    try {
      final response = await api.getNextPage(state.nextUrl!);
      emit(
        state.copyWith(
          status: GrsMeasurementDevicesStatus.success,
          items: [...state.items, ...response.results],
          nextUrl: response.next,
          hasReachedMax: response.next == null,
          isLoadingMore: false,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          status: GrsMeasurementDevicesStatus.fail,
          errorMessage: e.toString().replaceAll('Exception: ', ''),
          isLoadingMore: false,
        ),
      );
    }
  }

  Future<void> _onDocumentFetched(
      GrsMeasurementDevicesDetailFetched event,
      Emitter<GrsMeasurementDevicesState> emit,
      ) async {
    emit(state.copyWith(status: GrsMeasurementDevicesStatus.loading));
    try {
      final document = await api.getDocumentById(event.documentId);
      emit(
        state.copyWith(
          status: GrsMeasurementDevicesStatus.success,
          grsDetail: document,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          status: GrsMeasurementDevicesStatus.fail,
          errorMessage: e.toString().replaceAll('Exception: ', ''),
        ),
      );
    }
  }
}
