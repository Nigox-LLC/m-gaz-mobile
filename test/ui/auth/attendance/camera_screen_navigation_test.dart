import 'dart:io';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:m_gaz/core/api/attendance/attendance_api.dart';
import 'package:m_gaz/ui/auth/attendance/bloc/attendance_bloc.dart';
import 'package:m_gaz/ui/auth/attendance/camera_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    SharedPreferences.setMockInitialValues({});
    await EasyLocalization.ensureInitialized();
    EasyLocalization.logger.enableLevels = [];
    GoogleFonts.config.allowRuntimeFetching = false;
  });

  testWidgets('intro back returns to login route', (tester) async {
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
              routes: {'/login': (_) => const _LoginRouteMarker()},
              home: Scaffold(
                body: BlocProvider<AttendanceBloc>(
                  create: (_) => AttendanceBloc(api: _FakeAttendanceApi()),
                  child: const CameraScreen(),
                ),
              ),
            );
          },
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('attendance-intro-back')));
    await tester.pumpAndSettle();

    expect(find.byType(_LoginRouteMarker), findsOneWidget);
    expect(find.byType(CameraScreen), findsNothing);
  });
}

class _LoginRouteMarker extends StatelessWidget {
  const _LoginRouteMarker();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: Text('login route'));
  }
}

class _FakeAttendanceApi implements AttendanceApi {
  @override
  Future<bool> checkAlreadyAttended() async => false;

  @override
  Future<Map<String, dynamic>> sendAttendance({
    required File photo,
    Map<String, dynamic>? data,
  }) async => <String, dynamic>{};

  @override
  noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}
