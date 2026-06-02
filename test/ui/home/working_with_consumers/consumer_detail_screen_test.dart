import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:m_gaz/core/api/working_with_consumers_api/consumer_relations_api.dart';
import 'package:m_gaz/core/common/words.dart';
import 'package:m_gaz/core/models/working_with_consumers_document/consumer_file_models.dart';
import 'package:m_gaz/core/models/working_with_consumers_document/working_with_consumers_document_detail.dart';
import 'package:m_gaz/ui/home/working_with_consumers/bloc/consumer_detail_bloc.dart';
import 'package:m_gaz/ui/home/working_with_consumers/bloc/consumer_detail_state.dart';
import 'package:m_gaz/ui/home/working_with_consumers/sub_page/detail.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _documentId = 69483;
const _egxuId = 1438386;
const _consumerId = 68625;

Map<String, dynamic> _detailJson({
  String? oneFactory = '909',
  String? twoFactory = '808',
}) => {
  'id': _documentId,
  'consumers': {'id': _consumerId, 'name': 'Test korxona'},
  'region': {'id': 3, 'name': 'Andijon'},
  'district': {'id': 50, 'name': 'Andijon tumani'},
  'employee': {'id': 110, 'fio': 'Toshmatov A.'},
  'facial': '1730320128',
  'datetime': '2026-02-17T03:49:47.653451+05:00',
  'egxu_list': [
    {
      'id': _egxuId,
      'company_info': {
        'id': 14,
        'account_number': '1730320128',
        'is_active': true,
      },
      'egxu_type': {'id': 46, 'name': 'SARF'},
      'one_factory': oneFactory,
      'two_factory': twoFactory,
      'is_active': true,
    },
  ],
};

class _FakeApi implements ConsumerRelationsApi {
  _FakeApi({this.oneFactory = '909', this.twoFactory = '808'});

  final String? oneFactory;
  final String? twoFactory;
  int consumerUploadCalls = 0;

  @override
  Future<WorkingWithConsumersDetailModel> getDocumentById(int id) async {
    return WorkingWithConsumersDetailModel.fromJson(
      _detailJson(oneFactory: oneFactory, twoFactory: twoFactory),
    );
  }

  @override
  Future<List<EgxuCertificate>> getEgxuCertificates({
    required int egxuId,
  }) async {
    return const [];
  }

  @override
  Future<List<ConsumerFile>> getConsumerFiles({
    required int consumerId,
    String? fileType,
  }) async {
    return const [];
  }

  @override
  Future<void> uploadConsumerFiles({
    required int consumerId,
    List<String> technicalPaths = const [],
    List<String> contractPaths = const [],
  }) async {
    consumerUploadCalls++;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) =>
      throw UnimplementedError(invocation.memberName.toString());
}

class _Host extends StatelessWidget {
  const _Host({required this.api});

  final _FakeApi api;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Builder(
        builder: (context) {
          return Scaffold(
            body: Center(
              child: ElevatedButton(
                key: const Key('open-detail'),
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) => ConsumerRelationsDetailScreen(
                        documentId: _documentId,
                        api: api,
                      ),
                    ),
                  );
                },
                child: const Text('home'),
              ),
            ),
          );
        },
      ),
    );
  }
}

ConsumerUploadFile _localFile() => ConsumerUploadFile.local(
  path: '/tmp/photo.png',
  name: 'photo.png',
  sizeBytes: 1024,
);

Future<void> _openDetail(WidgetTester tester, _FakeApi api) async {
  await tester.pumpWidget(_Host(api: api));
  await tester.tap(find.byKey(const Key('open-detail')));
  await tester.pumpAndSettle();
  expect(find.byKey(const Key('consumer-detail-back-button')), findsOneWidget);
}

void _addPendingTechnicalFile(WidgetTester tester) {
  final context = tester.element(
    find.byKey(const Key('consumer-detail-back-button')),
  );
  context.read<ConsumerDetailBloc>().add(
    ConsumerDetailFileAdded(
      slot: ConsumerFileSlot.technical,
      file: _localFile(),
    ),
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    SharedPreferences.setMockInitialValues({});
    await EasyLocalization.ensureInitialized();
    EasyLocalization.logger.enableLevels = [];
    GoogleFonts.config.allowRuntimeFetching = false;
  });

  testWidgets('unsaved back shows discard sheet and discard pops screen', (
    tester,
  ) async {
    final api = _FakeApi();
    await _openDetail(tester, api);

    _addPendingTechnicalFile(tester);
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('consumer-detail-back-button')));
    await tester.pumpAndSettle();

    expect(
      find.byKey(const Key('consumer-unsaved-exit-sheet')),
      findsOneWidget,
    );

    await tester.tap(find.byKey(const Key('consumer-unsaved-discard')));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('consumer-detail-back-button')), findsNothing);
    expect(find.text('home'), findsOneWidget);
  });

  testWidgets('unsaved sheet save uploads and pops after success', (
    tester,
  ) async {
    final api = _FakeApi();
    await _openDetail(tester, api);

    _addPendingTechnicalFile(tester);
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('consumer-detail-back-button')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('consumer-unsaved-save')));
    await tester.pumpAndSettle();
    await tester.pump(const Duration(seconds: 3));

    expect(api.consumerUploadCalls, 1);
    expect(find.byKey(const Key('consumer-detail-back-button')), findsNothing);
    expect(find.text('home'), findsOneWidget);
  });

  testWidgets('EGHU header shows two factory numbers on separate lines', (
    tester,
  ) async {
    await _openDetail(tester, _FakeApi());

    expect(find.text('${Words.factoryOne.tr()}: 909'), findsOneWidget);
    expect(find.text('${Words.factoryTwo.tr()}: 808'), findsOneWidget);
  });

  testWidgets('EGHU header hides missing factory numbers', (tester) async {
    await _openDetail(tester, _FakeApi(oneFactory: '909', twoFactory: null));

    expect(find.text('${Words.factoryOne.tr()}: 909'), findsOneWidget);
    expect(find.textContaining('${Words.factoryTwo.tr()}:'), findsNothing);
  });

  testWidgets('EGHU header hides factory block when both numbers are missing', (
    tester,
  ) async {
    await _openDetail(tester, _FakeApi(oneFactory: '', twoFactory: null));

    expect(find.textContaining('${Words.factoryOne.tr()}:'), findsNothing);
    expect(find.textContaining('${Words.factoryTwo.tr()}:'), findsNothing);
  });
}
