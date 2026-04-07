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

class TaskComplete extends TaskEvent {
  final int taskId;
  final String? filePath;

  const TaskComplete({
    required this.taskId,
    this.filePath,
  });

  @override
  List<Object?> get props => [taskId, filePath];
}