import 'package:dio/dio.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:m_gaz/core/api/task/task_api.dart';
import 'package:m_gaz/core/models/paginated_response/paginated_response.dart';
import 'package:m_gaz/core/models/task/tasks_model.dart';
import 'package:m_gaz/ui/home/tasks/bloc/task_bloc.dart';
import 'package:m_gaz/ui/home/tasks/task_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    SharedPreferences.setMockInitialValues({});
    await EasyLocalization.ensureInitialized();
    EasyLocalization.logger.enableLevels = [];
  });

  testWidgets('overdue task opens with available actions', (tester) async {
    final bloc = TaskBloc(
      api: _FakeTaskApi([
        _task(employee: 'Expired User', isOverdue: true),
        _task(employee: 'Completed User', isDone: true),
      ]),
      minimumAnalysisDuration: Duration.zero,
    );
    addTearDown(bloc.close);

    await _pumpTaskScreen(tester, bloc);

    await tester.tap(find.text('Expired User'));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('task-done-button')), findsOneWidget);
    expect(find.byKey(const Key('task-cancel-todo-button')), findsOneWidget);

    await tester.tap(find.byIcon(Icons.close).first);
    await tester.pumpAndSettle();

    await tester.tap(find.text('Completed User'));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('task-detail-section')), findsOneWidget);
    expect(find.byKey(const Key('task-done-button')), findsNothing);
  });
}

Future<void> _pumpTaskScreen(WidgetTester tester, TaskBloc bloc) async {
  await tester.pumpWidget(
    EasyLocalization(
      supportedLocales: const [
        Locale('uz', 'UZ'),
        Locale('uz', 'Cyrl'),
        Locale('ru', 'RU'),
      ],
      path: 'assets/tr',
      fallbackLocale: const Locale('uz', 'UZ'),
      startLocale: const Locale('uz', 'UZ'),
      saveLocale: false,
      child: Builder(
        builder: (context) => BlocProvider.value(
          value: bloc,
          child: MaterialApp(
            localizationsDelegates: context.localizationDelegates,
            supportedLocales: context.supportedLocales,
            locale: context.locale,
            home: TaskListScreen(key: UniqueKey()),
          ),
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

class _FakeTaskApi extends TaskApi {
  _FakeTaskApi(this.tasks) : super.fromDio(Dio());

  final List<TaskModel> tasks;

  @override
  Future<PaginatedResponse<TaskModel>> getTasks({
    int limit = 20,
    int offset = 0,
    String? type,
    String? search,
  }) async {
    return PaginatedResponse<TaskModel>(
      count: tasks.length,
      next: null,
      previous: null,
      results: tasks,
    );
  }
}

TaskModel _task({
  required String employee,
  bool isDone = false,
  bool isApproved = false,
  bool isCanceled = false,
  bool isOverdue = false,
}) {
  return TaskModel(
    id: employee.hashCode,
    employee: employee,
    typeTask: 'Tekshiruv',
    status: 'Yangi',
    situation: "O'rta",
    description: 'Test description',
    deadline: DateTime(2026, 5, 20, 9),
    doneDate: null,
    approvedDate: null,
    canceledDate: null,
    created: DateTime(2026, 5, 19, 9),
    isDone: isDone,
    isApproved: isApproved,
    isCanceled: isCanceled,
    isOverdue: isOverdue,
    isAnswerFile: false,
    consumerDocument: null,
  );
}
