import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:m_gaz/features/actions/data/models/eghu_action_stamp_entry.dart';
import 'package:m_gaz/features/actions/presentation/pages/eghu/presentation/widgets/create/eghu_action_form_fields.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    SharedPreferences.setMockInitialValues({});
    await EasyLocalization.ensureInitialized();
    EasyLocalization.logger.enableLevels = [];
    GoogleFonts.config.allowRuntimeFetching = false;
  });

  testWidgets('stamp date field opens custom calendar and time picker', (
    tester,
  ) async {
    DateTime? changedDate;
    const localId = 'stamp-test';
    final stamp = EghuActionStampEntry.newEntry(
      localId: localId,
      installedAt: DateTime(2026, 5, 28, 1, 2),
      employeeName: 'Tester',
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: EghuStampSection(
            stamps: [stamp],
            employeeName: 'Tester',
            onAdd: () {},
            onNumberChanged: (_, __) {},
            onDateChanged: (_, value) => changedDate = value,
            onRemoveUnsaved: (_) {},
          ),
        ),
      ),
    );

    await tester.tap(find.byKey(const Key('eghu-stamp-date-field-$localId')));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('eghu-stamp-calendar-dialog')), findsOneWidget);

    await tester.tap(find.byKey(const Key('eghu-calendar-day-2026-05-28')));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('eghu-stamp-time-dialog')), findsOneWidget);
    expect(find.byKey(const Key('eghu-time-hour-01')), findsOneWidget);
    expect(find.byKey(const Key('eghu-time-minute-03')), findsOneWidget);

    await tester.tap(find.byKey(const Key('eghu-time-minute-03')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('eghu-time-confirm')));
    await tester.pumpAndSettle();

    expect(changedDate, DateTime(2026, 5, 28, 1, 3));
  });
}
