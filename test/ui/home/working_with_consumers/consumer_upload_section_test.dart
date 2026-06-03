import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:m_gaz/core/common/words.dart';
import 'package:m_gaz/core/models/working_with_consumers_document/consumer_file_models.dart';
import 'package:m_gaz/ui/home/working_with_consumers/widget/consumer_upload_widgets.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    SharedPreferences.setMockInitialValues({});
    await EasyLocalization.ensureInitialized();
    EasyLocalization.logger.enableLevels = [];
    GoogleFonts.config.allowRuntimeFetching = false;
  });

  // EasyLocalization widget'isiz pump qilamiz: .tr() ikkala tomonda ham
  // kalitni qaytaradi, shuning uchun matn solishtiruvlari mos keladi.
  Future<void> pump(
    WidgetTester tester, {
    required List<ConsumerUploadFile> files,
    void Function(ConsumerUploadFile)? onRemove,
    String? helpText,
  }) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SizedBox(
            width: 320,
            child: ConsumerUploadSection(
              title: Words.eghuCertificate.tr(),
              files: files,
              onAdd: () {},
              onRemove: onRemove ?? (_) {},
              onView: (_) {},
              helpText: helpText,
              helpKey: const Key('consumer-upload-help-test'),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('shows dropzone when empty', (tester) async {
    await pump(tester, files: const []);

    expect(find.byKey(const Key('consumer-upload-drop-zone')), findsOneWidget);
    expect(find.text(Words.addInformation.tr()), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets(
    'shows help icon and file info panel when help text is provided',
    (tester) async {
      const helpText = 'Upload JPG, PNG or PDF files.';
      final pending = ConsumerUploadFile.local(
        path: '/tmp/a.pdf',
        name: 'a.pdf',
        sizeBytes: 1024,
      );

      await pump(tester, files: [pending], helpText: helpText);

      final helpIcon = find.byKey(const Key('consumer-upload-help-test'));
      expect(helpIcon, findsOneWidget);

      await tester.tap(helpIcon);
      await tester.pumpAndSettle();

      expect(
        find.byKey(const Key('consumer-upload-info-section')),
        findsOneWidget,
      );
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('renders file tiles when populated, remote has no remove', (
    tester,
  ) async {
    final remote = ConsumerUploadFile.fromConsumerFile(
      const ConsumerFile(
        id: 1,
        file: 'https://example.com/contract.pdf',
        fileType: 'CONTRACT',
      ),
    );

    await pump(tester, files: [remote]);

    expect(find.byKey(const Key('consumer-upload-drop-zone')), findsNothing);
    expect(find.byType(Wrap), findsOneWidget);
    expect(find.text('PDF'), findsOneWidget);
    // remote fayl o'chirilmaydi (DELETE endpoint yo'q)
    expect(find.byKey(const Key('consumer-file-remove')), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('pending file can be removed', (tester) async {
    ConsumerUploadFile? removed;
    final pending = ConsumerUploadFile.local(
      path: '/tmp/a.pdf',
      name: 'a.pdf',
      sizeBytes: 10,
    );

    await pump(tester, files: [pending], onRemove: (f) => removed = f);

    final removeButton = find.byKey(const Key('consumer-file-remove'));
    expect(removeButton, findsOneWidget);

    await tester.tap(removeButton);
    await tester.pump();
    expect(removed, pending);
  });
}
