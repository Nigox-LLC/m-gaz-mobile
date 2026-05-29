import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../../../core/models/working_with_consumers_document/working_with_consumers_document_detail.dart';
import '../../../../../../../core/models/working_with_consumers_document/working_with_consumers_list.dart';
import '../../../../../data/datasources/eghu_action_api.dart';
import '../../../../../data/models/eghu_action_attachment.dart';
import '../../../../../data/models/eghu_action_create_request.dart';
import '../../../../../domain/entities/action_menu_item.dart';

part 'eghu_action_create_event.dart';
part 'eghu_action_create_state.dart';

class EghuActionCreateBloc
    extends Bloc<EghuActionCreateEvent, EghuActionCreateState> {
  EghuActionCreateBloc({
    required ActionMenuType actionType,
    required EghuActionSubmitApi api,
    int? employeeId,
    String? employeeName,
    int? regionId,
    int? districtId,
    DateTime? initialStampDateTime,
  }) : _api = api,
       super(
         EghuActionCreateState(
           actionType: actionType,
           employeeId: employeeId,
           employeeName: employeeName,
           profileRegionId: regionId,
           profileDistrictId: districtId,
           stampDateTime: initialStampDateTime ?? DateTime.now(),
         ),
       ) {
    on<EghuActionConsumerSelected>(_onConsumerSelected);
    on<EghuActionEghuSelected>(_onEghuSelected);
    on<EghuActionAttachmentSet>(_onAttachmentSet);
    on<EghuActionAttachmentRemoved>(_onAttachmentRemoved);
    on<EghuActionStampNumberChanged>(_onStampNumberChanged);
    on<EghuActionStampDateChanged>(_onStampDateChanged);
    on<EghuActionSubmitted>(_onSubmitted);
  }

  final EghuActionSubmitApi _api;

  void _onConsumerSelected(
    EghuActionConsumerSelected event,
    Emitter<EghuActionCreateState> emit,
  ) {
    emit(
      state.copyWith(
        selectedConsumer: event.consumer,
        clearSelectedEghu: true,
        clearSelectedConsumerDetail: true,
        status: EghuActionSubmitStatus.initial,
        errorMessage: '',
      ),
    );
  }

  void _onEghuSelected(
    EghuActionEghuSelected event,
    Emitter<EghuActionCreateState> emit,
  ) {
    emit(
      state.copyWith(
        selectedEghu: event.eghu,
        selectedConsumerDetail: event.consumerDetail,
        clearSelectedConsumerDetail: event.consumerDetail == null,
        status: EghuActionSubmitStatus.initial,
        errorMessage: '',
      ),
    );
  }

  void _onAttachmentSet(
    EghuActionAttachmentSet event,
    Emitter<EghuActionCreateState> emit,
  ) {
    emit(switch (event.slot) {
      EghuActionAttachmentSlot.act => state.copyWith(actFile: event.file),
      EghuActionAttachmentSlot.comparison => state.copyWith(
        comparisonFile: event.file,
      ),
    });
  }

  void _onAttachmentRemoved(
    EghuActionAttachmentRemoved event,
    Emitter<EghuActionCreateState> emit,
  ) {
    emit(switch (event.slot) {
      EghuActionAttachmentSlot.act => state.copyWith(clearActFile: true),
      EghuActionAttachmentSlot.comparison => state.copyWith(
        clearComparisonFile: true,
      ),
    });
  }

  void _onStampNumberChanged(
    EghuActionStampNumberChanged event,
    Emitter<EghuActionCreateState> emit,
  ) {
    emit(state.copyWith(stampNumber: event.value));
  }

  void _onStampDateChanged(
    EghuActionStampDateChanged event,
    Emitter<EghuActionCreateState> emit,
  ) {
    emit(state.copyWith(stampDateTime: event.value));
  }

  Future<void> _onSubmitted(
    EghuActionSubmitted event,
    Emitter<EghuActionCreateState> emit,
  ) async {
    final request = state.toRequest();
    if (request == null || state.status == EghuActionSubmitStatus.submitting) {
      return;
    }

    emit(
      state.copyWith(
        status: EghuActionSubmitStatus.submitting,
        errorMessage: '',
        lastSubmittedRequest: request,
      ),
    );

    try {
      await _api.create(request);
      emit(state.copyWith(status: EghuActionSubmitStatus.success));
    } catch (e) {
      emit(
        state.copyWith(
          status: EghuActionSubmitStatus.failure,
          errorMessage: e.toString().replaceAll('Exception: ', ''),
        ),
      );
    }
  }
}

enum EghuActionAttachmentSlot {
  act(
    title: "Dalolatnoma ma'lumotlari",
    alertTitle: "Dalolatnoma fayli yuklandi",
  ),
  comparison(
    title: "Yangi qiyoslov ma'lumotlari",
    alertTitle: "Qiyoslov fayli yuklandi",
  );

  const EghuActionAttachmentSlot({
    required this.title,
    required this.alertTitle,
  });

  final String title;
  final String alertTitle;
}
