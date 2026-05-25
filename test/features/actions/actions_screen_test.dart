import 'dart:convert';
import 'dart:io';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:m_gaz/core/common/words.dart';
import 'package:m_gaz/features/actions/domain/entities/action_menu_item.dart';
import 'package:m_gaz/ui/home/home_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    SharedPreferences.setMockInitialValues({});
    await EasyLocalization.ensureInitialized();
    EasyLocalization.logger.enableLevels = [];
  });

  testWidgets('bottom nav shows actions tab and no profile tab', (
    tester,
  ) async {
    await _pumpHome(tester, initialIndex: 4);

    expect(find.text('Bosh sahifa'), findsOneWidget);
    expect(find.text('Vazifalar'), findsOneWidget);
    expect(find.text("Iste'molchilar"), findsOneWidget);
    expect(find.text('Harakatlar'), findsOneWidget);
    expect(find.text('Qurilmalar'), findsOneWidget);
    expect(find.text('Profil'), findsNothing);

    final viewHeight =
        tester.view.physicalSize.height / tester.view.devicePixelRatio;
    final navTextBottom = tester.getRect(find.text('Qurilmalar')).bottom;
    expect(navTextBottom, greaterThan(viewHeight - 48));

    await tester.tap(find.text('Harakatlar'));
    await tester.pumpAndSettle();

    expect(find.text('Harakatlar'), findsNWidgets(2));
    expect(find.text('EGHU qayta o’rnatish'), findsOneWidget);
    expect(find.text('EGHU yechib olish'), findsOneWidget);
    expect(find.text('EGHU ko’rsatkichi yuklash'), findsOneWidget);

    for (final item in ActionMenuItem.items) {
      expect(find.text(item.title.tr()), findsOneWidget);
    }
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

Future<void> _pumpHome(WidgetTester tester, {required int initialIndex}) async {
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
            home: HomeScreen(initialIndex: initialIndex),
          );
        },
      ),
    ),
  );
  await tester.pumpAndSettle();
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
