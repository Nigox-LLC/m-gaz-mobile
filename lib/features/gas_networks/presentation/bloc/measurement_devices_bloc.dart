import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/enums/status.dart';
import '../../domain/entities/measurement_device_type.dart';
import '../../domain/entities/measuring_device_document.dart';
import '../../domain/usecases/get_measuring_device_documents.dart';
import '../../domain/usecases/load_more_measuring_device_documents.dart';

part 'measurement_devices_event.dart';
part 'measurement_devices_state.dart';

/// Single BLoC driving all three gas-network list pages. Each page provides its
/// own instance (registered as a factory) and seeds it with a
/// [LoadMeasurementDevices] carrying the page's [MeasurementDeviceType].
@injectable
class MeasurementDevicesBloc
    extends Bloc<MeasurementDevicesEvent, MeasurementDevicesState> {
  MeasurementDevicesBloc(this._getDocuments, this._loadMore)
      : super(const MeasurementDevicesState()) {
    on<LoadMeasurementDevices>(_onLoad);
    on<LoadMoreMeasurementDevices>(_onLoadMore);
  }

  final GetMeasuringDeviceDocuments _getDocuments;
  final LoadMoreMeasuringDeviceDocuments _loadMore;

  Future<void> _onLoad(
    LoadMeasurementDevices event,
    Emitter<MeasurementDevicesState> emit,
  ) async {
    emit(state.copyWith(status: Status.loading, type: event.type));

    final result = await _getDocuments(
      GetMeasuringDeviceDocumentsParams(type: event.type),
    );

    result.fold(
      (failure) => emit(
        state.copyWith(status: Status.error, errorMessage: failure.message),
      ),
      (page) => emit(
        state.copyWith(
          status: page.items.isEmpty ? Status.empty : Status.success,
          items: page.items,
          nextUrl: page.nextUrl,
          clearNextUrl: page.nextUrl == null,
          hasReachedMax: page.hasReachedMax,
          isLoadingMore: false,
        ),
      ),
    );
  }

  Future<void> _onLoadMore(
    LoadMoreMeasurementDevices event,
    Emitter<MeasurementDevicesState> emit,
  ) async {
    if (state.hasReachedMax || state.isLoadingMore || state.nextUrl == null) {
      return;
    }

    emit(state.copyWith(isLoadingMore: true));

    final result = await _loadMore(
      LoadMoreMeasuringDeviceDocumentsParams(state.nextUrl!),
    );

    result.fold(
      (failure) => emit(
        state.copyWith(
          status: Status.error,
          errorMessage: failure.message,
          isLoadingMore: false,
        ),
      ),
      (page) => emit(
        state.copyWith(
          status: Status.success,
          items: [...state.items, ...page.items],
          nextUrl: page.nextUrl,
          clearNextUrl: page.nextUrl == null,
          hasReachedMax: page.hasReachedMax,
          isLoadingMore: false,
        ),
      ),
    );
  }
}
