
import 'package:equatable/equatable.dart';

abstract class WorkingWithStampEvent extends Equatable {
  const WorkingWithStampEvent();

  @override
  List<Object?> get props => [];
}

// Dastlabki yuklash
  class WorkingWithStampFetched extends WorkingWithStampEvent {}

// Qo'shimcha ma'lumotlar yuklash (pagination)
class WorkingWithStampLoadMore extends WorkingWithStampEvent {}


class WorkingWithStampDocumentFetched extends WorkingWithStampEvent {
  final int documentId;

  const WorkingWithStampDocumentFetched(this.documentId);

  @override
  List<Object> get props => [documentId];
}