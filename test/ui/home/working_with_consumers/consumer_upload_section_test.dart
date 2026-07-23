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

  Future<void> pumpCertificate(
    WidgetTester tester, {
    required ConsumerUploadFile file,
    required bool editable,
    void Function(ConsumerUploadFile)? onChanged,
  }) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SizedBox(
            width: 320,
            child: SingleChildScrollView(
              child: ConsumerCertificateDetailsCard(
                file: file,
                editable: editable,
                onChanged: onChanged ?? (_) {},
              ),
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

  testWidgets('new certificate opens editable details and reports changes', (
    tester,
  ) async {
    final pending = ConsumerUploadFile.local(
      path: '/tmp/cert.pdf',
      name: 'cert.pdf',
      sizeBytes: 10,
    );
    ConsumerUploadFile? changed;

    await pumpCertificate(
      tester,
      file: pending,
      editable: true,
      onChanged: (file) => changed = file,
    );

    expect(find.text(Words.certificateDetails.tr()), findsOneWidget);
    expect(
      find.byKey(const Key('consumer-certificate-number-/tmp/cert.pdf')),
      findsOneWidget,
    );

    await tester.enterText(
      find.byKey(const Key('consumer-certificate-number-/tmp/cert.pdf')),
      'CERT-10',
    );

    expect(changed?.certificateNumber, 'CERT-10');

    final numberField = tester.widget<EditableText>(
      find.descendant(
        of: find.byKey(const Key('consumer-certificate-number-/tmp/cert.pdf')),
        matching: find.byType(EditableText),
      ),
    );
    expect(numberField.keyboardType, TextInputType.number);
    final warningField = tester.widget<EditableText>(
      find.descendant(
        of: find.byKey(
          const Key('consumer-certificate-warning-letter-/tmp/cert.pdf'),
        ),
        matching: find.byType(EditableText),
      ),
    );
    expect(warningField.keyboardType, TextInputType.number);
  });

  testWidgets('remote certificate starts collapsed and shows API details', (
    tester,
  ) async {
    final remote = ConsumerUploadFile.fromCertificate(
      const EgxuCertificate(
        id: 7,
        file: 'https://example.com/cert.pdf',
        certificateNumber: 'CERT-7',
        issuedDate: '2026-02-01',
      ),
    );

    await pumpCertificate(tester, file: remote, editable: false);

    expect(find.text('CERT-7'), findsNothing);
    await tester.tap(
      find.byKey(const Key('consumer-certificate-details-toggle-7')),
    );
    await tester.pumpAndSettle();

    expect(find.text('CERT-7'), findsOneWidget);
    expect(find.text('01.02.2026'), findsOneWidget);
  });
}
