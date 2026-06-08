import 'package:dio/dio.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:m_gaz/core/api/task/task_api.dart';
import 'package:m_gaz/core/models/task/task_analysis.dart';
import 'package:m_gaz/core/models/user/user_model.dart' as legacy_user;
import 'package:m_gaz/ui/home/main/dashboard_screen.dart';
import 'package:m_gaz/ui/home/tasks/bloc/task_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    SharedPreferences.setMockInitialValues({});
    await EasyLocalization.ensureInitialized();
    EasyLocalization.logger.enableLevels = [];
    GoogleFonts.config.allowRuntimeFetching = false;
  });

  testWidgets(
    'dashboard renders redesigned top widgets and opens calendar',
    (tester) async {
      final taskApi = _FakeTaskApi();
      final taskBloc = TaskBloc(
        api: taskApi,
        profileLoader: () async => legacy_user.UserModel(
          id: 1,
          username: 'Doston Dostonov',
          role: 'employee',
        ),
        minimumAnalysisDuration: Duration.zero,
      );

      await _pumpDashboard(tester, taskBloc: taskBloc);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 200));

      expect(find.byKey(const Key('dashboard-user-header')), findsOneWidget);
      expect(find.text('Doston Dostonov'), findsOneWidget);
      expect(find.text('Foydalanuvchi'), findsNothing);
      expect(find.byKey(const Key('dashboard-ai-card')), findsOneWidget);
      expect(find.text('Davrni tanlang'), findsOneWidget);
      expect(
        find.byKey(const Key('dashboard-task-chart-card')),
        findsOneWidget,
      );
      expect(find.text('Topshiriqlar'), findsOneWidget);
      expect(find.text('Bajarilgan'), findsOneWidget);
      expect(find.text('Kutilmoqda'), findsOneWidget);
      expect(find.text('Iyn'), findsOneWidget);
      expect(find.text('Muddati o‘tgan'), findsOneWidget);

      await tester.tap(find.byKey(const Key('dashboard-period-3-months')));
      await tester.pump(const Duration(milliseconds: 50));

      expect(taskApi.ranges.last.dateFrom, DateTime(2026, 3));
      expect(taskApi.ranges.last.dateTo, DateTime(2026, 6));
      expect(find.text('Mar-Iyn'), findsOneWidget);

      await tester.tap(find.byKey(const Key('dashboard-calendar-button')));
      await tester.pump(const Duration(milliseconds: 200));

      expect(find.byKey(const Key('dashboard-range-calendar')), findsOneWidget);

      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pump(const Duration(milliseconds: 50));
    },
    timeout: const Timeout(Duration(seconds: 20)),
  );
}

Future<void> _pumpDashboard(
  WidgetTester tester, {
  required TaskBloc taskBloc,
  DateTime Function()? nowProvider,
  bool useRealCalendar = false,
}) async {
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
          return MultiBlocProvider(
            providers: [BlocProvider<TaskBloc>.value(value: taskBloc)],
            child: MaterialApp(
              localizationsDelegates: context.localizationDelegates,
              supportedLocales: context.supportedLocales,
              locale: context.locale,
              home: DashboardPage(
                nowProvider: nowProvider ?? () => DateTime(2026, 6, 1, 20, 18),
                calendarBuilder: useRealCalendar
                    ? null
                    : (_) => Container(
                        key: const Key('dashboard-range-calendar'),
                        width: 320,
                        height: 280,
                        color: Colors.white,
                      ),
              ),
            ),
          );
        },
      ),
    ),
  );
}

class _FakeTaskApi extends TaskApi {
  _FakeTaskApi() : super.fromDio(Dio());

  final List<DashboardDateRange> ranges = [];

  @override
  Future<TaskAnalysisModel> getTaskAnalysis({
    DateTime? dateFrom,
    DateTime? dateTo,
  }) async {
    ranges.add(DashboardDateRange(dateFrom: dateFrom!, dateTo: dateTo!));
    return TaskAnalysisModel(
      allTask: 27,
      doneTask: 10,
      notDoneTask: 17,
      expiredTask: 20,
      consumerCount: 4,
    );
  }
}
