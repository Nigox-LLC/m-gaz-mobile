import 'package:equatable/equatable.dart';

abstract class TaskEvent extends Equatable {
  const TaskEvent();

  @override
  List<Object?> get props => [];
}

class TaskLoad extends TaskEvent {}

class TaskAnalysisLoad extends TaskEvent {}

class TaskLoadMore extends TaskEvent {}

class TaskDetailFetched extends TaskEvent {
  final int documentId;

  const TaskDetailFetched(this.documentId);

  @override
  List<Object> get props => [documentId];
}
