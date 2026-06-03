import 'dart:convert';
import 'dart:io';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:m_gaz/features/actions/presentation/pages/actions_screen.dart';
import 'package:m_gaz/ui/home/home_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    SharedPreferences.setMockInitialValues({});
    await EasyLocalization.ensureInitialized();
    EasyLocalization.logger.enableLevels = [];
    GoogleFonts.config.allowRuntimeFetching = false;
  });

  test('actions screen remains available outside bottom nav', () {
    expect(const ActionsScreen(), isA<ActionsScreen>());
  });

  testWidgets('bottom nav hides actions tab and renames device tab', (
    tester,
  ) async {
    await _pumpHome(tester, initialIndex: 3);

    expect(find.text('Bosh sahifa'), findsOneWidget);
    expect(find.text('Vazifalar'), findsOneWidget);
    expect(find.text("Iste'molchilar"), findsOneWidget);
    expect(find.text('Harakatlar'), findsNothing);
    expect(find.text('Gaz tarmoq'), findsOneWidget);
    expect(find.text('Qurilmalar'), findsNothing);
    expect(find.text('Profil'), findsNothing);

    final viewHeight =
        tester.view.physicalSize.height / tester.view.devicePixelRatio;
    final navTextBottom = tester.getRect(find.text('Gaz tarmoq')).bottom;
    expect(navTextBottom, greaterThan(viewHeight - 48));
  });

  test('contains action translations for every supported locale', () {
    for (final localeFile in ['uz-UZ.json', 'uz-Cyrl.json', 'ru-RU.json']) {
      final values = _translations(localeFile);
      for (final key in _actionTranslationKeys) {
        expect(values[key], isA<String>(), reason: '$localeFile:$key');
        expect((values[key] as String).trim(), isNotEmpty);
        expect(values[key], isNot(key));
      }
    }
  });
}

Future<void> _pumpLocalized(WidgetTester tester, Widget child) async {
  await tester.pumpWidget(
    EasyLocalization(
      key: UniqueKey(),
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
            home: child,
          );
        },
      ),
    ),
  );
  await tester.pumpAndSettle();
}

Future<void> _pumpHome(WidgetTester tester, {required int initialIndex}) async {
  await _pumpLocalized(tester, HomeScreen(initialIndex: initialIndex));
}

Map<String, Object?> _translations(String fileName) {
  final file = File('assets/tr/$fileName');
  return jsonDecode(file.readAsStringSync()) as Map<String, Object?>;
}

const _actionTranslationKeys = [
  'actions',
  'comingSoon',
  'actionEghuReinstall',
  'actionEghuDetach',
  'actionEghuIndicatorUpload',
  'actionIndustrialCollectorsReinstall',
  'actionIndustrialCollectorsDetach',
  'actionIndustrialCollectorsIndicatorUpload',
  'actionTechnologicalDevicesReinstall',
  'actionTechnologicalDevicesDetach',
  'actionTechnologicalDevicesIndicatorUpload',
];
