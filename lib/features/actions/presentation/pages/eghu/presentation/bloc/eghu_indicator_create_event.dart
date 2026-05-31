part of 'eghu_indicator_create_bloc.dart';

sealed class EghuIndicatorCreateEvent extends Equatable {
  const EghuIndicatorCreateEvent();

  @override
  List<Object?> get props => [];
}

class EghuIndicatorConsumerSelected extends EghuIndicatorCreateEvent {
  const EghuIndicatorConsumerSelected(this.consumer);

  final WorkingWithConsumersList consumer;

  @override
  List<Object?> get props => [consumer];
}

class EghuIndicatorEghuSelected extends EghuIndicatorCreateEvent {
  const EghuIndicatorEghuSelected(this.eghu, {this.consumerDetail});

  final ConsumersEgxuItem eghu;
  final WorkingWithConsumersDetailModel? consumerDetail;

  @override
  List<Object?> get props => [eghu, consumerDetail];
}

class EghuIndicatorValueChanged extends EghuIndicatorCreateEvent {
  const EghuIndicatorValueChanged(this.value);

  final String value;

  @override
  List<Object?> get props => [value];
}

class EghuIndicatorBasicFileSet extends EghuIndicatorCreateEvent {
  const EghuIndicatorBasicFileSet(this.file);

  final EghuActionAttachment file;

  @override
  List<Object?> get props => [file];
}

class EghuIndicatorBasicFileRemoved extends EghuIndicatorCreateEvent {
  const EghuIndicatorBasicFileRemoved();
}

class EghuIndicatorPrintFileSet extends EghuIndicatorCreateEvent {
  const EghuIndicatorPrintFileSet(this.file);

  final EghuActionAttachment file;

  @override
  List<Object?> get props => [file];
}

class EghuIndicatorPrintFileRemoved extends EghuIndicatorCreateEvent {
  const EghuIndicatorPrintFileRemoved();
}

class EghuIndicatorProfileChanged extends EghuIndicatorCreateEvent {
  const EghuIndicatorProfileChanged({this.employeeName});

  final String? employeeName;

  @override
  List<Object?> get props => [employeeName];
}

class EghuIndicatorSubmitted extends EghuIndicatorCreateEvent {
  const EghuIndicatorSubmitted();
}
