part of 'eghu_detach_create_bloc.dart';

sealed class EghuDetachCreateEvent extends Equatable {
  const EghuDetachCreateEvent();

  @override
  List<Object?> get props => [];
}

class EghuDetachConsumerSelected extends EghuDetachCreateEvent {
  const EghuDetachConsumerSelected(this.consumer);

  final WorkingWithConsumersList consumer;

  @override
  List<Object?> get props => [consumer];
}

class EghuDetachEghuSelected extends EghuDetachCreateEvent {
  const EghuDetachEghuSelected(this.eghu, {this.consumerDetail});

  final ConsumersEgxuItem eghu;
  final WorkingWithConsumersDetailModel? consumerDetail;

  @override
  List<Object?> get props => [eghu, consumerDetail];
}

class EghuDetachReasonSelected extends EghuDetachCreateEvent {
  const EghuDetachReasonSelected(this.reason);

  final EghuDetachReason reason;

  @override
  List<Object?> get props => [reason];
}

class EghuDetachReasonCleared extends EghuDetachCreateEvent {
  const EghuDetachReasonCleared();
}

class EghuDetachOtherReasonChanged extends EghuDetachCreateEvent {
  const EghuDetachOtherReasonChanged(this.value);

  final String value;

  @override
  List<Object?> get props => [value];
}

class EghuDetachSealStatusSelected extends EghuDetachCreateEvent {
  const EghuDetachSealStatusSelected(this.status);

  final EghuDetachSealStatus status;

  @override
  List<Object?> get props => [status];
}

class EghuDetachSealStatusCleared extends EghuDetachCreateEvent {
  const EghuDetachSealStatusCleared();
}

class EghuDetachActFileAdded extends EghuDetachCreateEvent {
  const EghuDetachActFileAdded(this.file);

  final EghuActionAttachment file;

  @override
  List<Object?> get props => [file];
}

class EghuDetachActFileRemovedAt extends EghuDetachCreateEvent {
  const EghuDetachActFileRemovedAt(this.index);

  final int index;

  @override
  List<Object?> get props => [index];
}

class EghuDetachProofFileAdded extends EghuDetachCreateEvent {
  const EghuDetachProofFileAdded(this.file);

  final EghuActionAttachment file;

  @override
  List<Object?> get props => [file];
}

class EghuDetachProofFileRemovedAt extends EghuDetachCreateEvent {
  const EghuDetachProofFileRemovedAt(this.index);

  final int index;

  @override
  List<Object?> get props => [index];
}

class EghuDetachProtocolFileAdded extends EghuDetachCreateEvent {
  const EghuDetachProtocolFileAdded(this.file);

  final EghuActionAttachment file;

  @override
  List<Object?> get props => [file];
}

class EghuDetachProtocolFileRemovedAt extends EghuDetachCreateEvent {
  const EghuDetachProtocolFileRemovedAt(this.index);

  final int index;

  @override
  List<Object?> get props => [index];
}

class EghuDetachGasSupplyStoppedSelected extends EghuDetachCreateEvent {
  const EghuDetachGasSupplyStoppedSelected(this.value);

  final EghuGasSupplyStopped value;

  @override
  List<Object?> get props => [value];
}

class EghuDetachGasSupplyStoppedCleared extends EghuDetachCreateEvent {
  const EghuDetachGasSupplyStoppedCleared();
}

class EghuDetachStampAdded extends EghuDetachCreateEvent {
  const EghuDetachStampAdded();
}

class EghuDetachStampRemoved extends EghuDetachCreateEvent {
  const EghuDetachStampRemoved(this.localId);

  final String localId;

  @override
  List<Object?> get props => [localId];
}

class EghuDetachStampNumberChanged extends EghuDetachCreateEvent {
  const EghuDetachStampNumberChanged(this.value, {this.localId});

  final String value;
  final String? localId;

  @override
  List<Object?> get props => [value, localId];
}

class EghuDetachStampDateChanged extends EghuDetachCreateEvent {
  const EghuDetachStampDateChanged(this.value, {this.localId});

  final DateTime value;
  final String? localId;

  @override
  List<Object?> get props => [value, localId];
}

class EghuDetachProfileChanged extends EghuDetachCreateEvent {
  const EghuDetachProfileChanged({
    this.employeeId,
    this.employeeName,
    this.regionId,
    this.districtId,
  });

  final int? employeeId;
  final String? employeeName;
  final int? regionId;
  final int? districtId;

  @override
  List<Object?> get props => [employeeId, employeeName, regionId, districtId];
}

class EghuDetachSubmitted extends EghuDetachCreateEvent {
  const EghuDetachSubmitted();
}
