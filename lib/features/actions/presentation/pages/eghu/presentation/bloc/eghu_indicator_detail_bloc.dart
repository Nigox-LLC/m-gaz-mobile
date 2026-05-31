import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../../../core/models/working_with_consumers_document/working_with_consumers_document_detail.dart';
import '../../../../../../../core/models/working_with_consumers_document/working_with_consumers_list.dart';
import '../../../../../data/datasources/eghu_indicator_api.dart';
import '../../../../../data/models/eghu_action_attachment.dart';
import '../../../../../data/models/eghu_indicator_create_request.dart';
import '../../../../../data/models/eghu_indicator_document.dart';
import 'eghu_indicator_create_bloc.dart';

part 'eghu_indicator_detail_event.dart';
part 'eghu_indicator_detail_state.dart';

class EghuIndicatorDetailBloc
    extends Bloc<EghuIndicatorDetailEvent, EghuIndicatorDetailState> {
  EghuIndicatorDetailBloc({
    required EghuIndicatorDetailApi api,
    required int id,
    String? employeeName,
  }) : _api = api,
       super(EghuIndicatorDetailState(id: id, employeeName: employeeName)) {
    on<EghuIndicatorDetailStarted>(_onStarted);
    on<EghuIndicatorDetailConsumerSelected>(_onConsumerSelected);
    on<EghuIndicatorDetailEghuSelected>(_onEghuSelected);
    on<EghuIndicatorDetailValueChanged>(_onValueChanged);
    on<EghuIndicatorDetailBasicFileSet>(_onBasicFileSet);
    on<EghuIndicatorDetailBasicFileRemoved>(_onBasicFileRemoved);
    on<EghuIndicatorDetailPrintFileSet>(_onPrintFileSet);
    on<EghuIndicatorDetailPrintFileRemoved>(_onPrintFileRemoved);
    on<EghuIndicatorDetailProfileChanged>(_onProfileChanged);
    on<EghuIndicatorDetailSubmitted>(_onSubmitted);
  }

  final EghuIndicatorDetailApi _api;

  Future<void> _onStarted(
    EghuIndicatorDetailStarted event,
    Emitter<EghuIndicatorDetailState> emit,
  ) async {
    if (state.status == EghuIndicatorDetailStatus.loading) return;
    emit(
      state.copyWith(
        status: EghuIndicatorDetailStatus.loading,
        errorMessage: '',
      ),
    );

    try {
      final document = await _api.getDetail(state.id);
      emit(EghuIndicatorDetailState.fromDocument(document, state.employeeName));
    } catch (e) {
      emit(
        state.copyWith(
          status: EghuIndicatorDetailStatus.failure,
          errorMessage: e.toString().replaceAll('Exception: ', ''),
        ),
      );
    }
  }

  void _onConsumerSelected(
    EghuIndicatorDetailConsumerSelected event,
    Emitter<EghuIndicatorDetailState> emit,
  ) {
    emit(
      state.copyWith(
        selectedConsumer: event.consumer,
        clearSelectedEghu: true,
        clearSelectedConsumerDetail: true,
        status: EghuIndicatorDetailStatus.success,
        errorMessage: '',
      ),
    );
  }

  void _onEghuSelected(
    EghuIndicatorDetailEghuSelected event,
    Emitter<EghuIndicatorDetailState> emit,
  ) {
    emit(
      state.copyWith(
        selectedEghu: event.eghu,
        selectedConsumerDetail: event.consumerDetail,
        clearSelectedConsumerDetail: event.consumerDetail == null,
        status: EghuIndicatorDetailStatus.success,
        errorMessage: '',
      ),
    );
  }

  void _onValueChanged(
    EghuIndicatorDetailValueChanged event,
    Emitter<EghuIndicatorDetailState> emit,
  ) {
    emit(
      state.copyWith(
        value: _normalizeValueDraft(event.value),
        status: EghuIndicatorDetailStatus.success,
        errorMessage: '',
      ),
    );
  }

  void _onBasicFileSet(
    EghuIndicatorDetailBasicFileSet event,
    Emitter<EghuIndicatorDetailState> emit,
  ) {
    emit(state.copyWith(basicFile: event.file, basicFileChanged: true));
  }

  void _onBasicFileRemoved(
    EghuIndicatorDetailBasicFileRemoved event,
    Emitter<EghuIndicatorDetailState> emit,
  ) {
    emit(state.copyWith(clearBasicFile: true, basicFileChanged: true));
  }

  void _onPrintFileSet(
    EghuIndicatorDetailPrintFileSet event,
    Emitter<EghuIndicatorDetailState> emit,
  ) {
    emit(state.copyWith(printFile: event.file, printFileChanged: true));
  }

  void _onPrintFileRemoved(
    EghuIndicatorDetailPrintFileRemoved event,
    Emitter<EghuIndicatorDetailState> emit,
  ) {
    emit(state.copyWith(clearPrintFile: true, printFileChanged: true));
  }

  void _onProfileChanged(
    EghuIndicatorDetailProfileChanged event,
    Emitter<EghuIndicatorDetailState> emit,
  ) {
    emit(state.copyWith(employeeName: event.employeeName));
  }

  Future<void> _onSubmitted(
    EghuIndicatorDetailSubmitted event,
    Emitter<EghuIndicatorDetailState> emit,
  ) async {
    final request = state.toRequest();
    if (request == null ||
        state.status == EghuIndicatorDetailStatus.submitting) {
      return;
    }

    emit(
      state.copyWith(
        status: EghuIndicatorDetailStatus.submitting,
        errorMessage: '',
        lastSubmittedRequest: request,
      ),
    );

    try {
      await _api.update(request);
      emit(state.copyWith(status: EghuIndicatorDetailStatus.successSaved));
    } catch (e) {
      emit(
        state.copyWith(
          status: EghuIndicatorDetailStatus.submitFailure,
          errorMessage: e.toString().replaceAll('Exception: ', ''),
        ),
      );
    }
  }
}

String _normalizeValueDraft(String value) {
  final normalized = value.replaceAll(',', '.');
  if (normalized == '.') return '0.';
  if (normalized.startsWith('.')) return '0$normalized';
  return normalized;
}
