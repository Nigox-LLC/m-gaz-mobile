import 'package:equatable/equatable.dart';

abstract class TechMeasuresEvent extends Equatable {
  const TechMeasuresEvent();

  @override
  List<Object?> get props => [];
}

class TechMeasureLoad extends TechMeasuresEvent {}

class TechMeasureLoadMore extends TechMeasuresEvent {}


class TechMeasureDetailFetched extends TechMeasuresEvent {
  final int documentId;

  const TechMeasureDetailFetched(this.documentId);

  @override
  List<Object> get props => [documentId];
}