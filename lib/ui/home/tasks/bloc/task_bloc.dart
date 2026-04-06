import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:m_gaz/core/api/task/task_api.dart';
import 'package:m_gaz/ui/home/tasks/bloc/task_event.dart';
import 'package:m_gaz/ui/home/tasks/bloc/task_state.dart';
import '../../../../di.dart';

class TaskBloc extends Bloc<TaskEvent, TaskState> {
  final TaskApi api = di.get<TaskApi>();

  TaskBloc() : super(const TaskState()) {
    on<TaskLoad>(_onFetched);
    on<TaskAnalysisLoad>(_onFetchAnalysis);
    on<TaskLoadMore>(_onLoadMore);
    on<TaskDetailFetched>(_onDocumentFetched);
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

  Future<void> _onFetchAnalysis(
    TaskAnalysisLoad event,
    Emitter<TaskState> emit,
  ) async {
    emit(state.copyWith(status: TaskStatus.loading, errorMessage: ''));

    try {
      debugPrint("🚀 TRY ICHIGA KIRDI");

      final startTime = DateTime.now();

      final response = await api.getTaskAnalysis();
      debugPrint("📦 RESPONSE BLOCDAN: $response");

      final diff = DateTime.now().difference(startTime).inMilliseconds;
      if (diff < 5000) {
        await Future.delayed(Duration(milliseconds: 5000 - diff));
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
}
