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

class EghuActionAttachmentSet extends EghuActionCreateEvent {
  const EghuActionAttachmentSet({required this.slot, required this.file});

  final EghuActionAttachmentSlot slot;
  final EghuActionAttachment file;

  @override
  List<Object?> get props => [slot, file];
}

class EghuActionAttachmentRemoved extends EghuActionCreateEvent {
  const EghuActionAttachmentRemoved(this.slot);

  final EghuActionAttachmentSlot slot;

  @override
  List<Object?> get props => [slot];
}

class EghuActionStampNumberChanged extends EghuActionCreateEvent {
  const EghuActionStampNumberChanged(this.value);

  final String value;

  @override
  List<Object?> get props => [value];
}

class EghuActionStampDateChanged extends EghuActionCreateEvent {
  const EghuActionStampDateChanged(this.value);

  final DateTime value;

  @override
  List<Object?> get props => [value];
}

class EghuActionSubmitted extends EghuActionCreateEvent {
  const EghuActionSubmitted();
}
