import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:m_gaz/core/common/words.dart';
import 'package:m_gaz/core/models/working_with_consumers_document/working_with_consumers_list.dart';
import 'package:m_gaz/ui/home/working_with_consumers/widget/document_card.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    SharedPreferences.setMockInitialValues({});
    await EasyLocalization.ensureInitialized();
    EasyLocalization.logger.enableLevels = [];
    GoogleFonts.config.allowRuntimeFetching = false;
  });

  testWidgets('renders consumer document details', (tester) async {
    await _pumpCard(
      tester,
      _document(facial: '754561687545616875456168'),
      width: 300,
    );

    expect(
      find.text('AS-SOBIR Xususiy korxona', findRichText: true),
      findsOneWidget,
    );
    expect(find.text(Words.status.tr()), findsOneWidget);
    expect(find.text(Words.stampNotInstalled.tr()), findsOneWidget);
    expect(find.text(Words.area.tr()), findsOneWidget);
    expect(find.text('Hududgaz Andijon GTF, Andijon shahar'), findsOneWidget);
    expect(find.text('ID: 75756'), findsOneWidget);
    expect(
      find.text(
        '${Words.accountNumber.tr()}: 754561687545616875456168',
        skipOffstage: false,
      ),
      findsOneWidget,
    );
    expect(tester.takeException(), isNull);
  });
}

Future<void> _pumpCard(
  WidgetTester tester,
  WorkingWithConsumersList document, {
  double width = 350,
}) async {
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
            home: Scaffold(
              body: Center(
                child: SizedBox(
                  width: width,
                  child: DocumentCard(
                    document: DocumentCardData.fromConsumer(document),
                    index: 0,
                    onTap: () {},
                  ),
                ),
              ),
            ),
          );
        },
      ),
    ),
  );
  await tester.pumpAndSettle();
}

WorkingWithConsumersList _document({
  String consumers = 'AS-SOBIR Xususiy korxona',
  String region = 'Hududgaz Andijon GTF',
  String district = 'Andijon shahar',
  String facial = '75456168',
}) {
  return WorkingWithConsumersList(
    id: 75756,
    region: region,
    district: district,
    employee: 'Doston Dostonov',
    consumers: consumers,
    facial: facial,
    datetime: DateTime(2026, 6, 2),
    excelId: '123',
  );
}
