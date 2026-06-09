import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:m_gaz/core/api/task/task_api.dart';
import 'package:m_gaz/core/models/paginated_response/paginated_response.dart';
import 'package:m_gaz/core/models/task/task_analysis.dart';
import 'package:m_gaz/core/models/task/tasks_model.dart';
import 'package:m_gaz/core/models/user/user_model.dart' as legacy_user;
import 'package:m_gaz/ui/home/tasks/bloc/task_bloc.dart';
import 'package:m_gaz/ui/home/tasks/bloc/task_event.dart';
import 'package:m_gaz/ui/home/tasks/bloc/task_state.dart';

void main() {
  test(
    'TaskProfileLoad stores profile username without changing status',
    () async {
      final bloc = TaskBloc(
        api: _FakeTaskApi(),
        profileLoader: () async => legacy_user.UserModel(
          id: 1,
          username: 'Doston Dostonov',
          role: 'employee',
        ),
        minimumAnalysisDuration: Duration.zero,
      );
      final expectation = expectLater(
        bloc.stream,
        emits(
          predicate<TaskState>(
            (state) =>
                state.status == TaskLoadStatus.initial &&
                state.profileUsername == 'Doston Dostonov',
          ),
        ),
      );

      bloc.add(TaskProfileLoad());

      await expectation;
      await bloc.close();
    },
  );

  test('TaskAnalysisLoad forwards selected date range to API', () async {
    final api = _FakeTaskApi();
    final bloc = TaskBloc(api: api, minimumAnalysisDuration: Duration.zero);
    final expectation = expectLater(
      bloc.stream,
      emitsInOrder([
        predicate<TaskState>((state) => state.status == TaskLoadStatus.loading),
        predicate<TaskState>(
          (state) =>
              state.status == TaskLoadStatus.success &&
              state.taskAnalysis?.allTask == 27,
        ),
      ]),
    );

    bloc.add(
      TaskAnalysisLoad(dateFrom: DateTime(2026, 3), dateTo: DateTime(2026, 6)),
    );

    await expectation;

    expect(api.lastDateFrom, DateTime(2026, 3));
    expect(api.lastDateTo, DateTime(2026, 6));

    await bloc.close();
  });

  test('TaskFilterChanged forwards selected type to API', () async {
    final api = _FakeTaskApi();
    final bloc = TaskBloc(api: api, minimumAnalysisDuration: Duration.zero);
    final expectation = expectLater(
      bloc.stream,
      emitsInOrder([
        predicate<TaskState>(
          (state) =>
              state.status == TaskLoadStatus.initial &&
              state.filterType == 'done-list',
        ),
        predicate<TaskState>((state) => state.status == TaskLoadStatus.loading),
        predicate<TaskState>(
          (state) =>
              state.status == TaskLoadStatus.success && state.tasks.length == 1,
        ),
      ]),
    );

    bloc.add(const TaskFilterChanged(type: 'done-list'));

    await expectation;
    expect(api.lastType, 'done-list');
    expect(api.lastSearch, isEmpty);

    await bloc.close();
  });

  test('TaskSearchChanged forwards search query to API', () async {
    final api = _FakeTaskApi();
    final bloc = TaskBloc(api: api, minimumAnalysisDuration: Duration.zero);
    final expectation = expectLater(
      bloc.stream,
      emitsInOrder([
        predicate<TaskState>(
          (state) =>
              state.status == TaskLoadStatus.initial && state.searchQuery == 'abc',
        ),
        predicate<TaskState>((state) => state.status == TaskLoadStatus.loading),
        predicate<TaskState>(
          (state) =>
              state.status == TaskLoadStatus.success && state.tasks.length == 1,
        ),
      ]),
    );

    bloc.add(const TaskSearchChanged('abc'));

    await expectation;
    expect(api.lastSearch, 'abc');

    await bloc.close();
  });

  test('TaskLoadMore appends next page results', () async {
    final api = _FakeTaskApi()
      ..nextUrl = 'https://backend.m-gaz.uz/api/task/list/?limit=20&offset=20';
    final bloc = TaskBloc(api: api, minimumAnalysisDuration: Duration.zero);
    final initialLoad = expectLater(
      bloc.stream,
      emitsInOrder([
        predicate<TaskState>((state) => state.status == TaskLoadStatus.loading),
        predicate<TaskState>(
          (state) =>
              state.status == TaskLoadStatus.success &&
              state.tasks.length == 1 &&
              !state.hasReachedMax,
        ),
      ]),
    );

    bloc.add(TaskLoad());
    await initialLoad;

    final loadMore = expectLater(
      bloc.stream,
      emitsInOrder([
        predicate<TaskState>((state) => state.isLoadingMore),
        predicate<TaskState>(
          (state) =>
              state.status == TaskLoadStatus.success &&
              state.tasks.length == 2 &&
              state.hasReachedMax,
        ),
      ]),
    );

    bloc.add(TaskLoadMore());
    await loadMore;
    expect(api.lastNextPageUrl, api.nextUrl);

    await bloc.close();
  });
}

class _FakeTaskApi extends TaskApi {
  _FakeTaskApi() : super.fromDio(Dio());

  DateTime? lastDateFrom;
  DateTime? lastDateTo;
  String lastSearch = '';
  String? lastType;
  String? nextUrl;
  String? lastNextPageUrl;

  @override
  Future<PaginatedResponse<TaskModel>> getTasks({
    int limit = 20,
    int offset = 0,
    String? type,
    String? search,
  }) async {
    lastType = type;
    lastSearch = search ?? '';
    return PaginatedResponse<TaskModel>(
      count: 2,
      next: nextUrl,
      previous: null,
      results: [_task(1)],
    );
  }

  @override
  Future<PaginatedResponse<TaskModel>> getNextPage(String url) async {
    lastNextPageUrl = url;
    return PaginatedResponse<TaskModel>(
      count: 2,
      next: null,
      previous: null,
      results: [_task(2)],
    );
  }

  @override
  Future<TaskAnalysisModel> getTaskAnalysis({
    DateTime? dateFrom,
    DateTime? dateTo,
  }) async {
    lastDateFrom = dateFrom;
    lastDateTo = dateTo;
    return TaskAnalysisModel(
      allTask: 27,
      doneTask: 10,
      notDoneTask: 17,
      expiredTask: 20,
      consumerCount: 4,
    );
  }
}

TaskModel _task(int id) {
  return TaskModel(
    id: id,
    employee: 'Employee $id',
    typeTask: 'Task type',
    status: 'Status',
    situation: 'Situation',
    description: 'Description',
    deadline: null,
    doneDate: null,
    approvedDate: null,
    canceledDate: null,
    created: DateTime(2026),
    isDone: false,
    isApproved: false,
    isCanceled: false,
    isOverdue: false,
    isAnswerFile: false,
    consumerDocument: null,
  );
}
