import 'package:equatable/equatable.dart';

abstract class TechMeasureEvent extends Equatable {
  const TechMeasureEvent();

  @override
  List<Object?> get props => [];
}

class TechMeasureLoad extends TechMeasureEvent {}

class TechMeasureLoadMore extends TechMeasureEvent {}


class TechMeasureDetailFetched extends TechMeasureEvent {
  final int documentId;

  const TechMeasureDetailFetched(this.documentId);

  @override
  List<Object> get props => [documentId];
}