import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:m_gaz/core/api/task/task_api.dart';
import 'package:m_gaz/core/models/task/task_analysis.dart';
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
                state.status == TaskStatus.initial &&
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
        predicate<TaskState>((state) => state.status == TaskStatus.loading),
        predicate<TaskState>(
          (state) =>
              state.status == TaskStatus.success &&
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
}

class _FakeTaskApi extends TaskApi {
  _FakeTaskApi() : super.fromDio(Dio());

  DateTime? lastDateFrom;
  DateTime? lastDateTo;

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
