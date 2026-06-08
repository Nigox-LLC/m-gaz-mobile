import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../../../../core/common/words.dart';
import '../../../../../../../../core/models/working_with_consumers_document/working_with_consumers_document_detail.dart';
import '../../../../../../../../core/models/working_with_consumers_document/working_with_consumers_list.dart';
import '../../../../../../data/datasources/eghu_action_api.dart';
import '../../../../../../data/models/eghu_action_attachment.dart';
import '../../../../../../data/models/eghu_action_create_request.dart';
import '../../../../../../data/models/eghu_action_stamp_entry.dart';
import '../../../../../../data/models/eghu_removal_detail.dart';
import '../../../../../../domain/entities/action_menu_item.dart';

part 'eghu_detach_create_event.dart';
part 'eghu_detach_create_state.dart';

class EghuDetachCreateBloc
    extends Bloc<EghuDetachCreateEvent, EghuDetachCreateState> {
  EghuDetachCreateBloc({
    required EghuActionSubmitApi api,
    EghuActionDetailApi? detailApi,
    EghuRemovalDetail? detail,
    int? employeeId,
    String? employeeName,
    int? regionId,
    int? districtId,
    DateTime? now,
  }) : _api = api,
       _detailApi = detailApi,
       _now = now,
       super(
         detail != null
             ? EghuDetachCreateState.fromDetail(
                 detail,
                 employeeId: employeeId,
                 employeeName: employeeName,
                 regionId: regionId,
                 districtId: districtId,
                 now: now,
               )
             : EghuDetachCreateState(
                 employeeId: employeeId,
                 employeeName: employeeName,
                 profileRegionId: regionId,
                 profileDistrictId: districtId,
                 stamps: [
                   EghuActionStampEntry.newEntry(
                     installedAt: now ?? DateTime.now(),
                     employeeName: employeeName,
                   ),
                 ],
               ),
       ) {
    on<EghuDetachConsumerSelected>(_onConsumerSelected);
    on<EghuDetachEghuSelected>(_onEghuSelected);
    on<EghuDetachReasonSelected>(_onReasonSelected);
    on<EghuDetachReasonCleared>(_onReasonCleared);
    on<EghuDetachOtherReasonChanged>(_onOtherReasonChanged);
    on<EghuDetachSealStatusSelected>(_onSealStatusSelected);
    on<EghuDetachSealStatusCleared>(_onSealStatusCleared);
    on<EghuDetachActFileAdded>(_onActFileAdded);
    on<EghuDetachActFileRemovedAt>(_onActFileRemovedAt);
    on<EghuDetachProofFileAdded>(_onProofFileAdded);
    on<EghuDetachProofFileRemovedAt>(_onProofFileRemovedAt);
    on<EghuDetachProtocolFileAdded>(_onProtocolFileAdded);
    on<EghuDetachProtocolFileRemovedAt>(_onProtocolFileRemovedAt);
    on<EghuDetachGasSupplyStoppedSelected>(_onGasSupplyStoppedSelected);
    on<EghuDetachGasSupplyStoppedCleared>(_onGasSupplyStoppedCleared);
    on<EghuDetachStampAdded>(_onStampAdded);
    on<EghuDetachStampRemoved>(_onStampRemoved);
    on<EghuDetachStampNumberChanged>(_onStampNumberChanged);
    on<EghuDetachStampDateChanged>(_onStampDateChanged);
    on<EghuDetachProfileChanged>(_onProfileChanged);
    on<EghuDetachSubmitted>(_onSubmitted);
  }

  final EghuActionSubmitApi _api;
  final EghuActionDetailApi? _detailApi;
  final DateTime? _now;

  void _onConsumerSelected(
    EghuDetachConsumerSelected event,
    Emitter<EghuDetachCreateState> emit,
  ) {
    emit(
      state.copyWith(
        selectedConsumer: event.consumer,
        clearSelectedEghu: true,
        clearSelectedConsumerDetail: true,
        status: EghuDetachSubmitStatus.initial,
        errorMessage: '',
      ),
    );
  }

  void _onEghuSelected(
    EghuDetachEghuSelected event,
    Emitter<EghuDetachCreateState> emit,
  ) {
    emit(
      state.copyWith(
        selectedEghu: event.eghu,
        selectedConsumerDetail: event.consumerDetail,
        clearSelectedConsumerDetail: event.consumerDetail == null,
        status: EghuDetachSubmitStatus.initial,
        errorMessage: '',
      ),
    );
  }

  void _onReasonSelected(
    EghuDetachReasonSelected event,
    Emitter<EghuDetachCreateState> emit,
  ) {
    emit(
      state.copyWith(
        reason: event.reason,
        clearOtherReason: event.reason != EghuDetachReason.other,
        status: EghuDetachSubmitStatus.initial,
        errorMessage: '',
      ),
    );
  }

  void _onReasonCleared(
    EghuDetachReasonCleared event,
    Emitter<EghuDetachCreateState> emit,
  ) {
    emit(
      state.copyWith(
        clearReason: true,
        clearOtherReason: true,
        status: EghuDetachSubmitStatus.initial,
        errorMessage: '',
      ),
    );
  }

  void _onOtherReasonChanged(
    EghuDetachOtherReasonChanged event,
    Emitter<EghuDetachCreateState> emit,
  ) {
    emit(state.copyWith(otherReason: event.value));
  }

  void _onSealStatusSelected(
    EghuDetachSealStatusSelected event,
    Emitter<EghuDetachCreateState> emit,
  ) {
    final sealChanged = state.sealStatus != event.status;
    emit(
      state.copyWith(
        sealStatus: event.status,
        clearActFile:
            sealChanged || event.status != EghuDetachSealStatus.defective,
        clearProofFile:
            sealChanged || event.status != EghuDetachSealStatus.working,
        clearProtocolFile: sealChanged,
        clearGasSupplyStopped: sealChanged,
        clearStamp: sealChanged,
        status: EghuDetachSubmitStatus.initial,
        errorMessage: '',
      ),
    );
  }

  void _onSealStatusCleared(
    EghuDetachSealStatusCleared event,
    Emitter<EghuDetachCreateState> emit,
  ) {
    emit(
      state.copyWith(
        clearSealStatus: true,
        clearActFile: true,
        clearProofFile: true,
        clearProtocolFile: true,
        clearGasSupplyStopped: true,
        clearStamp: true,
        status: EghuDetachSubmitStatus.initial,
        errorMessage: '',
      ),
    );
  }

  void _onActFileAdded(
    EghuDetachActFileAdded event,
    Emitter<EghuDetachCreateState> emit,
  ) {
    emit(state.copyWith(actFiles: [...state.actFiles, event.file]));
  }

  void _onActFileRemovedAt(
    EghuDetachActFileRemovedAt event,
    Emitter<EghuDetachCreateState> emit,
  ) {
    if (event.index < 0 || event.index >= state.actFiles.length) return;
    final updated = [...state.actFiles]..removeAt(event.index);
    if (updated.isEmpty) {
      emit(
        state.copyWith(
          clearActFile: true,
          clearProtocolFile: true,
          clearGasSupplyStopped: true,
          clearStamp: true,
        ),
      );
    } else {
      emit(state.copyWith(actFiles: updated));
    }
  }

  void _onProofFileAdded(
    EghuDetachProofFileAdded event,
    Emitter<EghuDetachCreateState> emit,
  ) {
    emit(state.copyWith(proofFiles: [...state.proofFiles, event.file]));
  }

  void _onProofFileRemovedAt(
    EghuDetachProofFileRemovedAt event,
    Emitter<EghuDetachCreateState> emit,
  ) {
    if (event.index < 0 || event.index >= state.proofFiles.length) return;
    emit(
      state.copyWith(
        proofFiles: [...state.proofFiles]..removeAt(event.index),
      ),
    );
  }

  void _onProtocolFileAdded(
    EghuDetachProtocolFileAdded event,
    Emitter<EghuDetachCreateState> emit,
  ) {
    emit(state.copyWith(protocolFiles: [...state.protocolFiles, event.file]));
  }

  void _onProtocolFileRemovedAt(
    EghuDetachProtocolFileRemovedAt event,
    Emitter<EghuDetachCreateState> emit,
  ) {
    if (event.index < 0 || event.index >= state.protocolFiles.length) return;
    emit(
      state.copyWith(
        protocolFiles: [...state.protocolFiles]..removeAt(event.index),
      ),
    );
  }

  void _onGasSupplyStoppedSelected(
    EghuDetachGasSupplyStoppedSelected event,
    Emitter<EghuDetachCreateState> emit,
  ) {
    final shouldAddInitialStamp =
        event.value == EghuGasSupplyStopped.yes && state.stamps.isEmpty;
    emit(
      state.copyWith(
        gasSupplyStopped: event.value,
        stamps: shouldAddInitialStamp
            ? [
                EghuActionStampEntry.newEntry(
                  installedAt: _now ?? DateTime.now(),
                  employeeName: state.employeeName,
                ),
              ]
            : null,
        clearProtocolFile: event.value != EghuGasSupplyStopped.no,
        clearStamp: event.value != EghuGasSupplyStopped.yes,
      ),
    );
  }

  void _onGasSupplyStoppedCleared(
    EghuDetachGasSupplyStoppedCleared event,
    Emitter<EghuDetachCreateState> emit,
  ) {
    emit(
      state.copyWith(
        clearGasSupplyStopped: true,
        clearProtocolFile: true,
        clearStamp: true,
      ),
    );
  }

  void _onStampNumberChanged(
    EghuDetachStampNumberChanged event,
    Emitter<EghuDetachCreateState> emit,
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
    EghuDetachStampDateChanged event,
    Emitter<EghuDetachCreateState> emit,
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
    EghuDetachStampAdded event,
    Emitter<EghuDetachCreateState> emit,
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
    EghuDetachStampRemoved event,
    Emitter<EghuDetachCreateState> emit,
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
    EghuDetachProfileChanged event,
    Emitter<EghuDetachCreateState> emit,
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
    EghuDetachSubmitted event,
    Emitter<EghuDetachCreateState> emit,
  ) async {
    final request = state.toRequest(now: _now ?? DateTime.now());
    if (request == null || state.status == EghuDetachSubmitStatus.submitting) {
      return;
    }

    emit(
      state.copyWith(
        status: EghuDetachSubmitStatus.submitting,
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
      emit(state.copyWith(status: EghuDetachSubmitStatus.success));
    } catch (e) {
      emit(
        state.copyWith(
          status: EghuDetachSubmitStatus.failure,
          errorMessage: e.toString().replaceAll('Exception: ', ''),
        ),
      );
    }
  }
}

enum EghuDetachReason {
  repair('repair'),
  eghuImprovement('eghu_improvement'),
  periodicComparison('periodic_comparison'),
  other('other');

  const EghuDetachReason(this.apiValue);

  final String apiValue;

  String get label => switch (this) {
    EghuDetachReason.repair => Words.repair.tr(),
    EghuDetachReason.eghuImprovement => Words.eghuImprovement.tr(),
    EghuDetachReason.periodicComparison => Words.periodicComparison.tr(),
    EghuDetachReason.other => Words.other.tr(),
  };
}

enum EghuDetachSealStatus {
  working('working'),
  defective('defective');

  const EghuDetachSealStatus(this.apiValue);

  final String apiValue;

  String get label => switch (this) {
    EghuDetachSealStatus.working => Words.workingSeal.tr(),
    EghuDetachSealStatus.defective => Words.defectiveSeal.tr(),
  };
}

enum EghuGasSupplyStopped {
  yes('yes'),
  no('no');

  const EghuGasSupplyStopped(this.apiValue);

  final String apiValue;

  String get label => switch (this) {
    EghuGasSupplyStopped.yes => Words.yes.tr(),
    EghuGasSupplyStopped.no => Words.no.tr(),
  };
}
