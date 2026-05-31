import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../../../core/common/words.dart';
import '../../../../../../../core/models/working_with_consumers_document/working_with_consumers_document_detail.dart';
import '../../../../../../../core/models/working_with_consumers_document/working_with_consumers_list.dart';
import '../../../../../data/datasources/eghu_action_api.dart';
import '../../../../../data/models/eghu_action_attachment.dart';
import '../../../../../data/models/eghu_action_create_request.dart';
import '../../../../../data/models/eghu_action_stamp_entry.dart';
import '../../../../../data/models/eghu_removal_detail.dart';
import '../../../../../domain/entities/action_menu_item.dart';

part 'eghu_action_create_event.dart';
part 'eghu_action_create_state.dart';

class EghuActionCreateBloc
    extends Bloc<EghuActionCreateEvent, EghuActionCreateState> {
  EghuActionCreateBloc({
    required ActionMenuType actionType,
    required EghuActionSubmitApi api,
    EghuActionDetailApi? detailApi,
    EghuRemovalDetail? detail,
    int? employeeId,
    String? employeeName,
    int? regionId,
    int? districtId,
    DateTime? initialStampDateTime,
  }) : _api = api,
       _detailApi = detailApi,
       _now = initialStampDateTime,
       super(
         detail != null
             ? EghuActionCreateState.fromDetail(
                 detail,
                 actionType,
                 employeeId: employeeId,
                 employeeName: employeeName,
                 regionId: regionId,
                 districtId: districtId,
                 now: initialStampDateTime,
               )
             : EghuActionCreateState(
                 actionType: actionType,
                 employeeId: employeeId,
                 employeeName: employeeName,
                 profileRegionId: regionId,
                 profileDistrictId: districtId,
                 stamps: [
                   EghuActionStampEntry.newEntry(
                     installedAt: initialStampDateTime ?? DateTime.now(),
                     employeeName: employeeName,
                   ),
                 ],
               ),
       ) {
    on<EghuActionConsumerSelected>(_onConsumerSelected);
    on<EghuActionEghuSelected>(_onEghuSelected);
    on<EghuActionAttachmentSet>(_onAttachmentSet);
    on<EghuActionAttachmentRemoved>(_onAttachmentRemoved);
    on<EghuActionStampAdded>(_onStampAdded);
    on<EghuActionStampRemoved>(_onStampRemoved);
    on<EghuActionStampNumberChanged>(_onStampNumberChanged);
    on<EghuActionStampDateChanged>(_onStampDateChanged);
    on<EghuActionProfileChanged>(_onProfileChanged);
    on<EghuActionSubmitted>(_onSubmitted);
  }

  final EghuActionSubmitApi _api;
  final EghuActionDetailApi? _detailApi;
  final DateTime? _now;

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
    final stampId =
        event.localId ??
        (state.stamps.isEmpty ? null : state.stamps.first.localId);
    if (stampId == null) return;

    emit(
      state.copyWith(
        stamps: state.stamps
            .map(
              (stamp) => stamp.localId == stampId
                  ? stamp.copyWith(number: event.value, isDirty: true)
                  : stamp,
            )
            .toList(),
      ),
    );
  }

  void _onStampDateChanged(
    EghuActionStampDateChanged event,
    Emitter<EghuActionCreateState> emit,
  ) {
    final stampId =
        event.localId ??
        (state.stamps.isEmpty ? null : state.stamps.first.localId);
    if (stampId == null) return;

    emit(
      state.copyWith(
        stamps: state.stamps
            .map(
              (stamp) => stamp.localId == stampId
                  ? stamp.copyWith(installedAt: event.value, isDirty: true)
                  : stamp,
            )
            .toList(),
      ),
    );
  }

  void _onStampAdded(
    EghuActionStampAdded event,
    Emitter<EghuActionCreateState> emit,
  ) {
    emit(
      state.copyWith(
        stamps: [
          EghuActionStampEntry.newEntry(
            installedAt: _now ?? DateTime.now(),
            employeeName: state.employeeName,
            localId:
                'stamp-${DateTime.now().microsecondsSinceEpoch}-${state.stamps.length}',
          ),
          ...state.stamps,
        ],
      ),
    );
  }

  void _onStampRemoved(
    EghuActionStampRemoved event,
    Emitter<EghuActionCreateState> emit,
  ) {
    emit(
      state.copyWith(
        stamps: state.stamps
            .where(
              (stamp) =>
                  stamp.localId != event.localId ||
                  !stamp.isNew ||
                  stamp.realId != null,
            )
            .toList(),
      ),
    );
  }

  void _onProfileChanged(
    EghuActionProfileChanged event,
    Emitter<EghuActionCreateState> emit,
  ) {
    emit(
      state.copyWith(
        employeeId: event.employeeId,
        employeeName: event.employeeName,
        profileRegionId: event.regionId,
        profileDistrictId: event.districtId,
      ),
    );
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
      final recordId = request.recordId;
      if (recordId != null && _detailApi != null) {
        await _detailApi.update(recordId, request);
      } else {
        await _api.create(request);
      }
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
  act,
  comparison;

  String get title => switch (this) {
    EghuActionAttachmentSlot.act => Words.actInformation.tr(),
    EghuActionAttachmentSlot.comparison => Words.comparisonInformation.tr(),
  };
}
