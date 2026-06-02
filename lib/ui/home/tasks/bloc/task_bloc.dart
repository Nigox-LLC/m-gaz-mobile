import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:m_gaz/core/api/user/user_api.dart';
import 'package:m_gaz/core/models/user/user_model.dart' as legacy_user;
import 'package:m_gaz/core/api/task/task_api.dart';
import 'package:m_gaz/ui/home/tasks/bloc/task_event.dart';
import 'package:m_gaz/ui/home/tasks/bloc/task_state.dart';
import '../../../../di.dart';

class TaskBloc extends Bloc<TaskEvent, TaskState> {
  final TaskApi api;
  final Duration minimumAnalysisDuration;
  final Future<legacy_user.UserModel?> Function() _profileLoader;

  TaskBloc({
    TaskApi? api,
    Future<legacy_user.UserModel?> Function()? profileLoader,
    this.minimumAnalysisDuration = const Duration(seconds: 5),
  }) : api = api ?? di.get<TaskApi>(),
       _profileLoader =
           profileLoader ?? (() => di.get<UserApi>().loadUserProfile()),
       super(const TaskState()) {
    on<TaskLoad>(_onFetched);
    on<TaskProfileLoad>(_onProfileLoad);
    on<TaskAnalysisLoad>(_onFetchAnalysis);
    on<TaskLoadMore>(_onLoadMore);
    on<TaskDetailFetched>(_onDocumentFetched);
    on<TaskComplete>(_onTaskComplete);
    on<TaskCancel>(_onTaskCancel);
  }

  Future<void> _onFetched(TaskLoad event, Emitter<TaskState> emit) async {
    emit(state.copyWith(status: TaskStatus.loading));
    try {
      final response = await api.getTasks(limit: 20);

      emit(
        state.copyWith(
          status: TaskStatus.success,
          tasks: response.results,
          nextUrl: response.next,
          hasReachedMax: response.next == null,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          status: TaskStatus.fail,
          errorMessage: e.toString().replaceAll('Exception: ', ''),
        ),
      );
    }
  }

  Future<void> _onProfileLoad(
    TaskProfileLoad event,
    Emitter<TaskState> emit,
  ) async {
    try {
      final profile = await _profileLoader();
      final username = profile?.username.trim();
      if (username == null || username.isEmpty) return;
      emit(state.copyWith(profileUsername: username));
    } catch (e) {
      debugPrint("Dashboard profile yuklanmadi: $e");
    }
  }

  Future<void> _onFetchAnalysis(
    TaskAnalysisLoad event,
    Emitter<TaskState> emit,
  ) async {
    emit(state.copyWith(status: TaskStatus.loading, errorMessage: ''));

    try {
      debugPrint("🚀 TRY ICHIGA KIRDI");

      final startTime = DateTime.now();

      final response = await api.getTaskAnalysis(
        dateFrom: event.dateFrom,
        dateTo: event.dateTo,
      );
      debugPrint("📦 RESPONSE BLOCDAN: $response");

      final diff = DateTime.now().difference(startTime).inMilliseconds;
      if (diff < minimumAnalysisDuration.inMilliseconds) {
        await Future.delayed(
          Duration(milliseconds: minimumAnalysisDuration.inMilliseconds - diff),
        );
      }

      emit(state.copyWith(status: TaskStatus.success, taskAnalysis: response));
    } catch (e) {
      debugPrint("❌ XATO TUTILDI: $e");
      emit(state.copyWith(status: TaskStatus.fail, errorMessage: e.toString()));
    }
  }

  Future<void> _onLoadMore(TaskLoadMore event, Emitter<TaskState> emit) async {
    if (state.hasReachedMax || state.isLoadingMore || state.nextUrl == null) {
      return;
    }

    emit(state.copyWith(isLoadingMore: true));
    try {
      final response = await api.getNextPage(state.nextUrl!);
      emit(
        state.copyWith(
          status: TaskStatus.success,
          tasks: [...state.tasks, ...response.results],
          nextUrl: response.next,
          hasReachedMax: response.next == null,
          isLoadingMore: false,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          status: TaskStatus.fail,
          errorMessage: e.toString().replaceAll('Exception: ', ''),
          isLoadingMore: false,
        ),
      );
    }
  }

  Future<void> _onDocumentFetched(
    TaskDetailFetched event,
    Emitter<TaskState> emit,
  ) async {
    emit(state.copyWith(status: TaskStatus.loading));
    try {
      final document = await api.getDocumentById(event.documentId);
      emit(state.copyWith(status: TaskStatus.success, taskDetail: document));
    } catch (e) {
      emit(
        state.copyWith(
          status: TaskStatus.fail,
          errorMessage: e.toString().replaceAll('Exception: ', ''),
        ),
      );
    }
  }

  Future<void> _onTaskComplete(
    TaskComplete event,
    Emitter<TaskState> emit,
  ) async {
    emit(state.copyWith(isCompletingTask: true));
    try {
      await api.completeTask(
        taskId: event.taskId,
        filePath: event.filePath,
        latitude: event.latitude,
        longitude: event.longitude,
      );

      emit(state.copyWith(status: TaskStatus.success, isCompletingTask: false));

      debugPrint("✅ Task bajarildi: ${event.taskId}");

      add(TaskLoad());
    } catch (e) {
      emit(
        state.copyWith(
          status: TaskStatus.fail,
          errorMessage: e.toString().replaceAll('Exception: ', ''),
          isCompletingTask: false,
        ),
      );
    }
  }

  Future<void> _onTaskCancel(TaskCancel event, Emitter<TaskState> emit) async {
    emit(state.copyWith(isCancelingTask: true));
    try {
      await api.cancelTask(
        taskId: event.taskId,
        description: event.description,
        filePath: event.filePath,
      );

      emit(state.copyWith(status: TaskStatus.success, isCancelingTask: false));

      debugPrint("Task bekor qilindi: ${event.taskId}");

      add(TaskLoad());
    } catch (e) {
      emit(
        state.copyWith(
          status: TaskStatus.fail,
          errorMessage: e.toString().replaceAll('Exception: ', ''),
          isCancelingTask: false,
        ),
      );
    }
  }
}
