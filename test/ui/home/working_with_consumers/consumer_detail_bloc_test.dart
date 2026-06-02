import 'package:flutter_test/flutter_test.dart';
import 'package:m_gaz/core/api/working_with_consumers_api/consumer_relations_api.dart';
import 'package:m_gaz/core/models/working_with_consumers_document/consumer_file_models.dart';
import 'package:m_gaz/core/models/working_with_consumers_document/working_with_consumers_document_detail.dart';
import 'package:m_gaz/ui/home/working_with_consumers/bloc/consumer_detail_bloc.dart';
import 'package:m_gaz/ui/home/working_with_consumers/bloc/consumer_detail_state.dart';

const _egxuId = 1438386;
const _consumerId = 68625;

Map<String, dynamic> _detailJson() => {
  'id': 69483,
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
      'one_factory': '909',
      'two_factory': null,
      'is_active': true,
    },
  ],
};

class _FakeApi implements ConsumerRelationsApi {
  int certUploadCalls = 0;
  int consumerUploadCalls = 0;
  bool throwOnUpload = false;

  @override
  Future<WorkingWithConsumersDetailModel> getDocumentById(int id) async {
    return WorkingWithConsumersDetailModel.fromJson(_detailJson());
  }

  @override
  Future<List<EgxuCertificate>> getEgxuCertificates({
    required int egxuId,
  }) async {
    return const [
      EgxuCertificate(
        id: 8,
        file: 'https://example.com/cert1.png',
        createdAt: '2026-06-01T20:10:00Z',
      ),
    ];
  }

  @override
  Future<List<ConsumerFile>> getConsumerFiles({
    required int consumerId,
    String? fileType,
  }) async {
    return const [
      ConsumerFile(
        id: 1,
        file: 'https://example.com/tech.pdf',
        fileType: 'TECHNICAL',
        createdAt: '2026-06-01T20:00:00Z',
      ),
      ConsumerFile(
        id: 2,
        file: 'https://example.com/contract.pdf',
        fileType: 'CONTRACT',
        createdAt: '2026-06-01T20:05:00Z',
      ),
    ];
  }

  @override
  Future<void> uploadEgxuCertificates({
    required int egxuId,
    required List<String> paths,
  }) async {
    if (throwOnUpload) throw Exception('upload failed');
    certUploadCalls++;
  }

  @override
  Future<void> uploadConsumerFiles({
    required int consumerId,
    List<String> technicalPaths = const [],
    List<String> contractPaths = const [],
  }) async {
    if (throwOnUpload) throw Exception('upload failed');
    consumerUploadCalls++;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) =>
      throw UnimplementedError(invocation.memberName.toString());
}

ConsumerUploadFile _localFile() => ConsumerUploadFile.local(
  path: '/tmp/photo.png',
  name: 'photo.png',
  sizeBytes: 1024,
);

void main() {
  late _FakeApi api;

  setUp(() => api = _FakeApi());

  ConsumerDetailBloc build() => ConsumerDetailBloc(api: api);

  Future<ConsumerDetailBloc> loaded() async {
    final bloc = build();
    bloc.add(const ConsumerDetailFetched(69483));
    await bloc.stream.firstWhere(
      (s) => s.status == ConsumerDetailStatus.loaded,
    );
    return bloc;
  }

  test('fetch loads document and remote files', () async {
    final bloc = await loaded();

    expect(bloc.state.status, ConsumerDetailStatus.loaded);
    expect(bloc.state.document?.id, 69483);
    expect(bloc.state.certsByEgxu[_egxuId]?.length, 1);
    expect(bloc.state.technicalDocs.length, 1);
    expect(bloc.state.contracts.length, 1);
    expect(bloc.state.canSave, isFalse);

    await bloc.close();
  });

  test('company info toggles', () async {
    final bloc = await loaded();
    expect(bloc.state.companyInfoExpanded, isFalse);

    bloc.add(const ConsumerDetailCompanyToggled());
    await bloc.stream.firstWhere((s) => s.companyInfoExpanded);
    expect(bloc.state.companyInfoExpanded, isTrue);

    await bloc.close();
  });

  test('adding a technical file makes save available, removing clears it',
      () async {
    final bloc = await loaded();
    final file = _localFile();

    bloc.add(
      ConsumerDetailFileAdded(slot: ConsumerFileSlot.technical, file: file),
    );
    await bloc.stream.firstWhere((s) => s.pendingTechnical.isNotEmpty);
    expect(bloc.state.canSave, isTrue);
    expect(bloc.state.technicalAll.length, 2); // 1 remote + 1 pending

    bloc.add(
      ConsumerDetailFileRemoved(slot: ConsumerFileSlot.technical, file: file),
    );
    await bloc.stream.firstWhere((s) => s.pendingTechnical.isEmpty);
    expect(bloc.state.canSave, isFalse);

    await bloc.close();
  });

  test('save uploads pending files and clears pending', () async {
    final bloc = await loaded();

    bloc.add(
      ConsumerDetailFileAdded(
        slot: ConsumerFileSlot.certificate,
        egxuId: _egxuId,
        file: _localFile(),
      ),
    );
    bloc.add(
      ConsumerDetailFileAdded(
        slot: ConsumerFileSlot.technical,
        file: _localFile(),
      ),
    );
    await bloc.stream.firstWhere((s) => s.canSave);

    bloc.add(const ConsumerDetailSaved());
    await bloc.stream.firstWhere(
      (s) => s.saveStatus == ConsumerDetailSaveStatus.success,
    );

    expect(api.certUploadCalls, 1);
    expect(api.consumerUploadCalls, 1);
    expect(bloc.state.pendingTechnical, isEmpty);
    expect(bloc.state.pendingCertsByEgxu[_egxuId] ?? const [], isEmpty);

    await bloc.close();
  });

  test('save failure sets failure status', () async {
    final bloc = await loaded();
    api.throwOnUpload = true;

    bloc.add(
      ConsumerDetailFileAdded(
        slot: ConsumerFileSlot.technical,
        file: _localFile(),
      ),
    );
    await bloc.stream.firstWhere((s) => s.canSave);

    bloc.add(const ConsumerDetailSaved());
    await bloc.stream.firstWhere(
      (s) => s.saveStatus == ConsumerDetailSaveStatus.failure,
    );

    expect(bloc.state.saveError, isNotNull);
    // pending hali saqlanib qoladi (qayta urinish uchun)
    expect(bloc.state.pendingTechnical, isNotEmpty);

    await bloc.close();
  });
}
