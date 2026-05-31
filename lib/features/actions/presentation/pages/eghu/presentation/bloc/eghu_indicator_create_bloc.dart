import 'package:equatable/equatable.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../../../core/models/working_with_consumers_document/working_with_consumers_document_detail.dart';
import '../../../../../../../core/models/working_with_consumers_document/working_with_consumers_list.dart';
import '../../../../../data/datasources/eghu_indicator_api.dart';
import '../../../../../data/models/eghu_action_attachment.dart';
import '../../../../../data/models/eghu_indicator_create_request.dart';

part 'eghu_indicator_create_event.dart';
part 'eghu_indicator_create_state.dart';

class EghuIndicatorCreateBloc
    extends Bloc<EghuIndicatorCreateEvent, EghuIndicatorCreateState> {
  EghuIndicatorCreateBloc({
    required EghuIndicatorSubmitApi api,
    DateTime? now,
    String? employeeName,
  }) : _api = api,
       _now = now,
       super(EghuIndicatorCreateState(employeeName: employeeName)) {
    on<EghuIndicatorConsumerSelected>(_onConsumerSelected);
    on<EghuIndicatorEghuSelected>(_onEghuSelected);
    on<EghuIndicatorValueChanged>(_onValueChanged);
    on<EghuIndicatorBasicFileSet>(_onBasicFileSet);
    on<EghuIndicatorBasicFileRemoved>(_onBasicFileRemoved);
    on<EghuIndicatorPrintFileSet>(_onPrintFileSet);
    on<EghuIndicatorPrintFileRemoved>(_onPrintFileRemoved);
    on<EghuIndicatorProfileChanged>(_onProfileChanged);
    on<EghuIndicatorSubmitted>(_onSubmitted);
  }

  final EghuIndicatorSubmitApi _api;
  final DateTime? _now;

  void _onConsumerSelected(
    EghuIndicatorConsumerSelected event,
    Emitter<EghuIndicatorCreateState> emit,
  ) {
    emit(
      state.copyWith(
        selectedConsumer: event.consumer,
        clearSelectedEghu: true,
        clearSelectedConsumerDetail: true,
        status: EghuIndicatorSubmitStatus.initial,
        errorMessage: '',
      ),
    );
  }

  void _onEghuSelected(
    EghuIndicatorEghuSelected event,
    Emitter<EghuIndicatorCreateState> emit,
  ) {
    emit(
      state.copyWith(
        selectedEghu: event.eghu,
        selectedConsumerDetail: event.consumerDetail,
        clearSelectedConsumerDetail: event.consumerDetail == null,
        status: EghuIndicatorSubmitStatus.initial,
        errorMessage: '',
      ),
    );
  }

  void _onValueChanged(
    EghuIndicatorValueChanged event,
    Emitter<EghuIndicatorCreateState> emit,
  ) {
    emit(
      state.copyWith(
        value: _normalizeValueDraft(event.value),
        status: EghuIndicatorSubmitStatus.initial,
        errorMessage: '',
      ),
    );
  }

  void _onBasicFileSet(
    EghuIndicatorBasicFileSet event,
    Emitter<EghuIndicatorCreateState> emit,
  ) {
    emit(state.copyWith(basicFile: event.file));
  }

  void _onBasicFileRemoved(
    EghuIndicatorBasicFileRemoved event,
    Emitter<EghuIndicatorCreateState> emit,
  ) {
    emit(state.copyWith(clearBasicFile: true));
  }

  void _onPrintFileSet(
    EghuIndicatorPrintFileSet event,
    Emitter<EghuIndicatorCreateState> emit,
  ) {
    emit(state.copyWith(printFile: event.file));
  }

  void _onPrintFileRemoved(
    EghuIndicatorPrintFileRemoved event,
    Emitter<EghuIndicatorCreateState> emit,
  ) {
    emit(state.copyWith(clearPrintFile: true));
  }

  void _onProfileChanged(
    EghuIndicatorProfileChanged event,
    Emitter<EghuIndicatorCreateState> emit,
  ) {
    emit(state.copyWith(employeeName: event.employeeName));
  }

  Future<void> _onSubmitted(
    EghuIndicatorSubmitted event,
    Emitter<EghuIndicatorCreateState> emit,
  ) async {
    final request = state.toRequest(now: _now ?? DateTime.now());
    if (request == null ||
        state.status == EghuIndicatorSubmitStatus.submitting) {
      return;
    }

    emit(
      state.copyWith(
        status: EghuIndicatorSubmitStatus.submitting,
        errorMessage: '',
        lastSubmittedRequest: request,
      ),
    );

    try {
      await _api.create(request);
      emit(state.copyWith(status: EghuIndicatorSubmitStatus.success));
    } catch (e) {
      emit(
        state.copyWith(
          status: EghuIndicatorSubmitStatus.failure,
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

String normalizeEghuIndicatorValue(String value) {
  final normalized = _normalizeValueDraft(value).trim();
  final parsed = double.tryParse(normalized);
  if (parsed == null) return '';
  return parsed.toStringAsFixed(2);
}

class EghuIndicatorValueInputFormatter extends TextInputFormatter {
  const EghuIndicatorValueInputFormatter();

  static final _pattern = RegExp(r'^\d{0,8}([,.]\d{0,2})?$');

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    if (newValue.text.isEmpty || _pattern.hasMatch(newValue.text)) {
      return newValue;
    }
    return oldValue;
  }
}
