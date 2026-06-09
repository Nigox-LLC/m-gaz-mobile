import 'package:equatable/equatable.dart';
import 'package:m_gaz/core/models/task/task_analysis.dart';
import 'package:m_gaz/core/models/task/tasks_model.dart';

enum TaskLoadStatus { initial, loading, success, fail, taskAnalysis }

class TaskState extends Equatable {
  final TaskLoadStatus status;
  final List<TaskModel> tasks;
  final TaskAnalysisModel? taskAnalysis;
  final String? nextUrl;
  final bool hasReachedMax;
  final bool isLoadingMore;
  final String? errorMessage;
  final String? profileUsername;
  final String? profilePhotoUrl;
  final String searchQuery;
  final String? filterType;

  final TaskModel? selectedTask;
  final TaskModel? taskDetail;

  final bool isCompletingTask;
  final bool isCancelingTask;

  const TaskState({
    this.status = TaskLoadStatus.initial,
    this.tasks = const [],
    this.taskAnalysis,
    this.nextUrl,
    this.hasReachedMax = false,
    this.isLoadingMore = false,
    this.errorMessage,
    this.profileUsername,
    this.profilePhotoUrl,
    this.searchQuery = '',
    this.filterType,
    this.selectedTask,
    this.taskDetail,
    this.isCompletingTask = false,
    this.isCancelingTask = false,
  });

  TaskState copyWith({
    TaskLoadStatus? status,
    List<TaskModel>? tasks,
    TaskAnalysisModel? taskAnalysis,
    String? nextUrl,
    bool? hasReachedMax,
    bool? isLoadingMore,
    String? errorMessage,
    String? profileUsername,
    String? profilePhotoUrl,
    String? searchQuery,
    String? filterType,
    TaskModel? selectedTask,
    TaskModel? taskDetail,
    bool? isCompletingTask,
    bool? isCancelingTask,
    bool clearNextUrl = false,
    bool clearFilterType = false,
  }) {
    return TaskState(
      status: status ?? this.status,
      tasks: tasks ?? this.tasks,
      taskAnalysis: taskAnalysis ?? this.taskAnalysis,
      nextUrl: clearNextUrl ? null : (nextUrl ?? this.nextUrl),
      hasReachedMax: hasReachedMax ?? this.hasReachedMax,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      errorMessage: errorMessage ?? this.errorMessage,
      profileUsername: profileUsername ?? this.profileUsername,
      profilePhotoUrl: profilePhotoUrl ?? this.profilePhotoUrl,
      searchQuery: searchQuery ?? this.searchQuery,
      filterType: clearFilterType ? null : (filterType ?? this.filterType),
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
    profileUsername,
    profilePhotoUrl,
    searchQuery,
    filterType,
    selectedTask,
    taskDetail,
    isCompletingTask,
    isCancelingTask,
  ];
}
