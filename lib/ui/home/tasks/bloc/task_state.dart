import 'package:equatable/equatable.dart';
import 'package:m_gaz/core/models/task/task_analysis.dart';
import 'package:m_gaz/core/models/task/tasks_model.dart';

enum TaskStatus { initial, loading, success, fail, taskAnalysis }

class TaskState extends Equatable {
  final TaskStatus status;
  final List<TaskModel> tasks;
  final TaskAnalysisModel? taskAnalysis;
  final String? nextUrl;
  final bool hasReachedMax;
  final bool isLoadingMore;
  final String? errorMessage;

  final TaskModel? selectedTask;
  final TaskModel? taskDetail;

  final bool isCompletingTask;
  final bool isCancelingTask;

  const TaskState({
    this.status = TaskStatus.initial,
    this.tasks = const [],
    this.taskAnalysis,
    this.nextUrl,
    this.hasReachedMax = false,
    this.isLoadingMore = false,
    this.errorMessage,
    this.selectedTask,
    this.taskDetail,
    this.isCompletingTask = false,
    this.isCancelingTask = false,
  });

  TaskState copyWith({
    TaskStatus? status,
    List<TaskModel>? tasks,
    TaskAnalysisModel? taskAnalysis,
    String? nextUrl,
    bool? hasReachedMax,
    bool? isLoadingMore,
    String? errorMessage,
    TaskModel? selectedTask,
    TaskModel? taskDetail,
    bool? isCompletingTask,
    bool? isCancelingTask,
  }) {
    return TaskState(
      status: status ?? this.status,
      tasks: tasks ?? this.tasks,
      taskAnalysis: taskAnalysis ?? this.taskAnalysis,
      nextUrl: nextUrl ?? this.nextUrl,
      hasReachedMax: hasReachedMax ?? this.hasReachedMax,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      errorMessage: errorMessage ?? this.errorMessage,
      taskDetail: taskDetail ?? this.taskDetail,
      selectedTask: selectedTask ?? this.selectedTask,
      isCompletingTask: isCompletingTask ?? this.isCompletingTask,
      isCancelingTask: isCancelingTask ?? this.isCancelingTask,
    );
  }

  @override
  List<Object?> get props => [
    status,
    tasks,
    taskAnalysis,
    nextUrl,
    hasReachedMax,
    isLoadingMore,
    errorMessage,
    selectedTask,
    taskDetail,
    isCompletingTask,
    isCancelingTask,
  ];
}
