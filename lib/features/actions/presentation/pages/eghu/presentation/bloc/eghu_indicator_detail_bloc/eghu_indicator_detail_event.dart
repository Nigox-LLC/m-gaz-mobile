part of 'eghu_indicator_detail_bloc.dart';

sealed class EghuIndicatorDetailEvent extends Equatable {
  const EghuIndicatorDetailEvent();

  @override
  List<Object?> get props => [];
}

class EghuIndicatorDetailStarted extends EghuIndicatorDetailEvent {
  const EghuIndicatorDetailStarted();
}

class EghuIndicatorDetailConsumerSelected extends EghuIndicatorDetailEvent {
  const EghuIndicatorDetailConsumerSelected(this.consumer);

  final WorkingWithConsumersList consumer;

  @override
  List<Object?> get props => [consumer];
}

class EghuIndicatorDetailEghuSelected extends EghuIndicatorDetailEvent {
  const EghuIndicatorDetailEghuSelected(this.eghu, {this.consumerDetail});

  final ConsumersEgxuItem eghu;
  final WorkingWithConsumersDetailModel? consumerDetail;

  @override
  List<Object?> get props => [eghu, consumerDetail];
}

class EghuIndicatorDetailValueChanged extends EghuIndicatorDetailEvent {
  const EghuIndicatorDetailValueChanged(this.value);

  final String value;

  @override
  List<Object?> get props => [value];
}

class EghuIndicatorDetailBasicFileSet extends EghuIndicatorDetailEvent {
  const EghuIndicatorDetailBasicFileSet(this.file);

  final EghuActionAttachment file;

  @override
  List<Object?> get props => [file];
}

class EghuIndicatorDetailBasicFileRemoved extends EghuIndicatorDetailEvent {
  const EghuIndicatorDetailBasicFileRemoved();
}

class EghuIndicatorDetailPrintFileSet extends EghuIndicatorDetailEvent {
  const EghuIndicatorDetailPrintFileSet(this.file);

  final EghuActionAttachment file;

  @override
  List<Object?> get props => [file];
}

class EghuIndicatorDetailPrintFileRemoved extends EghuIndicatorDetailEvent {
  const EghuIndicatorDetailPrintFileRemoved();
}

class EghuIndicatorDetailProfileChanged extends EghuIndicatorDetailEvent {
  const EghuIndicatorDetailProfileChanged({this.employeeName});

  final String? employeeName;

  @override
  List<Object?> get props => [employeeName];
}

class EghuIndicatorDetailSubmitted extends EghuIndicatorDetailEvent {
  const EghuIndicatorDetailSubmitted();
}
