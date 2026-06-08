part of 'eghu_action_create_bloc.dart';

sealed class EghuActionCreateEvent extends Equatable {
  const EghuActionCreateEvent();

  @override
  List<Object?> get props => [];
}

class EghuActionConsumerSelected extends EghuActionCreateEvent {
  const EghuActionConsumerSelected(this.consumer);

  final WorkingWithConsumersList consumer;

  @override
  List<Object?> get props => [consumer];
}

class EghuActionEghuSelected extends EghuActionCreateEvent {
  const EghuActionEghuSelected(this.eghu, {this.consumerDetail});

  final ConsumersEgxuItem eghu;
  final WorkingWithConsumersDetailModel? consumerDetail;

  @override
  List<Object?> get props => [eghu, consumerDetail];
}

class EghuActionAttachmentAdded extends EghuActionCreateEvent {
  const EghuActionAttachmentAdded({required this.slot, required this.file});

  final EghuActionAttachmentSlot slot;
  final EghuActionAttachment file;

  @override
  List<Object?> get props => [slot, file];
}

class EghuActionAttachmentRemovedAt extends EghuActionCreateEvent {
  const EghuActionAttachmentRemovedAt({required this.slot, required this.index});

  final EghuActionAttachmentSlot slot;
  final int index;

  @override
  List<Object?> get props => [slot, index];
}

class EghuActionStampAdded extends EghuActionCreateEvent {
  const EghuActionStampAdded();
}

class EghuActionStampRemoved extends EghuActionCreateEvent {
  const EghuActionStampRemoved(this.localId);

  final String localId;

  @override
  List<Object?> get props => [localId];
}

class EghuActionStampNumberChanged extends EghuActionCreateEvent {
  const EghuActionStampNumberChanged(this.value, {this.localId});

  final String value;
  final String? localId;

  @override
  List<Object?> get props => [value, localId];
}

class EghuActionStampDateChanged extends EghuActionCreateEvent {
  const EghuActionStampDateChanged(this.value, {this.localId});

  final DateTime value;
  final String? localId;

  @override
  List<Object?> get props => [value, localId];
}

class EghuActionStampPlaceChanged extends EghuActionCreateEvent {
  const EghuActionStampPlaceChanged({
    required this.localId,
    required this.placeId,
    required this.placeName,
  });

  final String localId;
  final int placeId;
  final String placeName;

  @override
  List<Object?> get props => [localId, placeId, placeName];
}

class EghuActionStampPlaceCleared extends EghuActionCreateEvent {
  const EghuActionStampPlaceCleared(this.localId);

  final String localId;

  @override
  List<Object?> get props => [localId];
}

class EghuActionProfileChanged extends EghuActionCreateEvent {
  const EghuActionProfileChanged({
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

class EghuActionSubmitted extends EghuActionCreateEvent {
  const EghuActionSubmitted();
}
