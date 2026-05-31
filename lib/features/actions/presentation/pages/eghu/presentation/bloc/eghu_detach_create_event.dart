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

class EghuDetachActFileSet extends EghuDetachCreateEvent {
  const EghuDetachActFileSet(this.file);

  final EghuActionAttachment file;

  @override
  List<Object?> get props => [file];
}

class EghuDetachActFileRemoved extends EghuDetachCreateEvent {
  const EghuDetachActFileRemoved();
}

class EghuDetachProofFileSet extends EghuDetachCreateEvent {
  const EghuDetachProofFileSet(this.file);

  final EghuActionAttachment file;

  @override
  List<Object?> get props => [file];
}

class EghuDetachProofFileRemoved extends EghuDetachCreateEvent {
  const EghuDetachProofFileRemoved();
}

class EghuDetachProtocolFileSet extends EghuDetachCreateEvent {
  const EghuDetachProtocolFileSet(this.file);

  final EghuActionAttachment file;

  @override
  List<Object?> get props => [file];
}

class EghuDetachProtocolFileRemoved extends EghuDetachCreateEvent {
  const EghuDetachProtocolFileRemoved();
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

class EghuDetachStampNumberChanged extends EghuDetachCreateEvent {
  const EghuDetachStampNumberChanged(this.value);

  final String value;

  @override
  List<Object?> get props => [value];
}

class EghuDetachStampDateChanged extends EghuDetachCreateEvent {
  const EghuDetachStampDateChanged(this.value);

  final DateTime value;

  @override
  List<Object?> get props => [value];
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
