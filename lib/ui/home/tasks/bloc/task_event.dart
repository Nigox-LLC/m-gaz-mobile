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
  final double? latitude;
  final double? longitude;

  const TaskComplete({
    required this.taskId,
    this.filePath,
    this.latitude,
    this.longitude,
  });

  @override
  List<Object?> get props => [taskId, filePath, latitude, longitude];
}

class TaskCancel extends TaskEvent {
  final int taskId;
  final String description;
  final String filePath;

  const TaskCancel({
    required this.taskId,
    required this.description,
    required this.filePath,
  });

  @override
  List<Object?> get props => [taskId, description, filePath];
}
