import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:m_gaz/core/models/task/tasks_model.dart';
import 'package:m_gaz/ui/home/tasks/widgets/task_item.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    SharedPreferences.setMockInitialValues({});
    await EasyLocalization.ensureInitialized();
    EasyLocalization.logger.enableLevels = [];
  });

  testWidgets('task item onTap works for pending expired and completed tasks', (
    tester,
  ) async {
    final tapped = <String>[];
    final now = DateTime(2026, 5, 24, 10);

    await _pumpTaskItems(tester, [
      TaskItemWidget(
        task: _task(
          employee: 'Pending User',
          deadline: now.add(const Duration(days: 1)),
        ),
        onTap: () => tapped.add('pending'),
      ),
      TaskItemWidget(
        task: _task(
          employee: 'Expired User',
          deadline: now.subtract(const Duration(days: 1)),
        ),
        onTap: () => tapped.add('expired'),
      ),
      TaskItemWidget(
        task: _task(employee: 'Completed User', isDone: true, doneDate: now),
        onTap: () => tapped.add('completed'),
      ),
    ]);

    await tester.tap(find.text('Pending User'));
    await tester.tap(find.text('Expired User'));
    await tester.tap(find.text('Completed User'));
    await tester.pumpAndSettle();

    expect(tapped, ['pending', 'expired', 'completed']);
  });
}

Future<void> _pumpTaskItems(WidgetTester tester, List<Widget> children) async {
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
        builder: (context) {
          return MaterialApp(
            localizationsDelegates: context.localizationDelegates,
            supportedLocales: context.supportedLocales,
            locale: context.locale,
            home: Scaffold(body: ListView(children: children)),
          );
        },
      ),
    ),
  );
  await tester.pumpAndSettle();
}

TaskModel _task({
  required String employee,
  DateTime? deadline,
  DateTime? doneDate,
  bool isDone = false,
}) {
  return TaskModel(
    id: employee.hashCode,
    employee: employee,
    typeTask: 'Tekshiruv',
    status: 'Yangi',
    situation: "O'rta",
    description: 'Test description',
    deadline: deadline,
    doneDate: doneDate,
    approvedDate: null,
    canceledDate: null,
    created: DateTime(2026, 5, 20, 9),
    isDone: isDone,
    isApproved: false,
    isCanceled: false,
    isAnswerFile: false,
    consumerDocument: null,
  );
}
