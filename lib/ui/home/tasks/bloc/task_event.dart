import 'package:equatable/equatable.dart';

abstract class TaskEvent extends Equatable {
  const TaskEvent();

  @override
  List<Object?> get props => [];
}

class TaskLoad extends TaskEvent {}

class TaskProfileLoad extends TaskEvent {}

class TaskAnalysisLoad extends TaskEvent {
  final DateTime? dateFrom;
  final DateTime? dateTo;

  const TaskAnalysisLoad({this.dateFrom, this.dateTo});

  @override
  List<Object?> get props => [dateFrom, dateTo];
}

class TaskLoadMore extends TaskEvent {}

class TaskSearchChanged extends TaskEvent {
  final String query;

  const TaskSearchChanged(this.query);

  @override
  List<Object?> get props => [query];
}

class TaskFilterChanged extends TaskEvent {
  final String? type;
  final bool clearFilter;

  const TaskFilterChanged({this.type, this.clearFilter = false});

  @override
  List<Object?> get props => [type, clearFilter];
}

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
