import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:m_gaz/core/models/global/base_model.dart';
import 'package:m_gaz/core/models/working_with_consumers_document/working_with_consumers_document_detail.dart';
import 'package:m_gaz/core/models/working_with_consumers_document/working_with_consumers_list.dart';
import 'package:m_gaz/features/actions/data/datasources/eghu_indicator_api.dart';
import 'package:m_gaz/features/actions/data/models/eghu_action_attachment.dart';
import 'package:m_gaz/features/actions/data/models/eghu_indicator_create_request.dart';
import 'package:m_gaz/features/actions/data/models/eghu_indicator_document.dart';
import 'package:m_gaz/features/actions/presentation/pages/eghu/presentation/bloc/eghu_indicator_detail_bloc.dart';

void main() {
  group('EghuIndicatorDetailBloc', () {
    late File basicFile;
    late _FakeDetailApi api;
    late EghuIndicatorDetailBloc bloc;

    setUp(() {
      basicFile = _tempFile('basic.pdf');
      api = _FakeDetailApi(detail: _document());
      bloc = EghuIndicatorDetailBloc(api: api, id: 8);
    });

    tearDown(() async {
      await bloc.close();
      if (basicFile.existsSync()) basicFile.deleteSync();
    });

    test('loads detail into editable state with remote files', () async {
      bloc.add(const EghuIndicatorDetailStarted());
      await pumpEventQueue();

      expect(bloc.state.status, EghuIndicatorDetailStatus.success);
      expect(bloc.state.selectedConsumer?.id, 68424);
      expect(bloc.state.selectedConsumer?.facial, '1430200078');
      expect(bloc.state.selectedEghu?.id, 1436318);
      expect(bloc.state.value, '50.00');
      expect(bloc.state.basicFile?.isRemote, isTrue);
      expect(bloc.state.basicFile?.remoteAktId, 2);
      expect(bloc.state.printFile?.remoteAktId, 3);
      expect(bloc.state.canSubmit, isFalse);
    });

    test('marks dirty when value and file changes', () async {
      bloc.add(const EghuIndicatorDetailStarted());
      await pumpEventQueue();

      bloc
        ..add(const EghuIndicatorDetailValueChanged('55,5'))
        ..add(EghuIndicatorDetailBasicFileSet(_attachment(basicFile.path)));
      await pumpEventQueue();

      expect(bloc.state.isDirty, isTrue);
      expect(bloc.state.canSubmit, isTrue);
      expect(bloc.state.toRequest()?.value, '55.50');
      expect(bloc.state.toRequest()?.basicFileChanged, isTrue);
    });

    test('clears EGHU when consumer changes', () async {
      bloc.add(const EghuIndicatorDetailStarted());
      await pumpEventQueue();

      bloc.add(EghuIndicatorDetailConsumerSelected(_consumer()));
      await pumpEventQueue();

      expect(bloc.state.selectedConsumer?.id, 12);
      expect(bloc.state.selectedEghu, isNull);
      expect(bloc.state.canSubmit, isFalse);
    });

    test('submits changed main data and local file update', () async {
      bloc.add(const EghuIndicatorDetailStarted());
      await pumpEventQueue();

      bloc
        ..add(const EghuIndicatorDetailValueChanged('55'))
        ..add(EghuIndicatorDetailBasicFileSet(_attachment(basicFile.path)))
        ..add(
          EghuIndicatorDetailEghuSelected(_eghu(), consumerDetail: _detail()),
        );
      await pumpEventQueue();

      bloc.add(const EghuIndicatorDetailSubmitted());
      await pumpEventQueue();

      expect(bloc.state.status, EghuIndicatorDetailStatus.successSaved);
      expect(api.updateRequest, isNotNull);
      expect(api.updateRequest!.mainChanged, isTrue);
      expect(api.updateRequest!.basicFileChanged, isTrue);
      expect(api.updateRequest!.basicFileId, 2);
      expect(api.updateRequest!.printFileChanged, isFalse);
      expect(api.updateRequest!.egxuId, 44);
    });
  });
}

class _FakeDetailApi implements EghuIndicatorDetailApi {
  _FakeDetailApi({required this.detail});

  final EghuIndicatorDocument detail;
  EghuIndicatorUpdateRequest? updateRequest;

  @override
  Future<EghuIndicatorDocument> getDetail(int id) async => detail;

  @override
  Future<void> update(EghuIndicatorUpdateRequest request) async {
    updateRequest = request;
  }
}

EghuIndicatorDocument _document() {
  return EghuIndicatorDocument.fromJson({
    'id': 8,
    'created_at': '2026-05-31T18:01:23.057508+05:00',
    'value': '50.00',
    'consumer': 68424,
    'consumer_info': {
      'id': 68424,
      'name': '"ZO`R SHASHLIK" OILAVIY KORXONA',
      'region_info': {'id': 7, 'name': '"Hududgaz Samarqand" GTF'},
      'district_info': {'id': 88, 'name': 'Samarqand shahar'},
      'facial': '1430200078',
    },
    'egxu': 1436318,
    'egxu_info': {'one_factory': '11140', 'egxu_type': 'СТГ 80/400'},
    'files': [
      {
        'id': 3,
        'egxu_indicator': 8,
        'file': 'https://example.com/print.jpg',
        'file_type': 'print',
        'created_at': '2026-05-31T18:01:23.614209+05:00',
      },
      {
        'id': 2,
        'egxu_indicator': 8,
        'file': 'https://example.com/basic.jpg',
        'file_type': 'basic',
        'created_at': '2026-05-31T18:01:23.386457+05:00',
      },
    ],
  });
}

WorkingWithConsumersList _consumer() {
  return WorkingWithConsumersList(
    id: 12,
    region: 'Andijon',
    district: 'Andijon tumani',
    employee: 'Doston Dostonov',
    consumers: 'Tashkilot nomi',
    facial: '1651512649',
    datetime: DateTime(2026, 5, 23),
    excelId: '42',
  );
}

ConsumersEgxuItem _eghu() {
  return ConsumersEgxuItem(id: 44, oneFactory: 'Zavod 1');
}

WorkingWithConsumersDetailModel _detail() {
  return WorkingWithConsumersDetailModel(
    region: Region(id: 3, name: 'Andijon'),
    district: District(id: 50, name: 'Andijon tumani'),
    employee: Employee(id: 77, fio: 'Tester'),
  );
}

EghuActionAttachment _attachment(String path) {
  return EghuActionAttachment(
    path: path,
    name: path.split(Platform.pathSeparator).last,
    sizeBytes: 64,
    isImage: false,
    sourceLabel: 'Test',
    createdAt: DateTime(2026, 5, 31),
  );
}

File _tempFile(String name) {
  return File(
    '${Directory.systemTemp.path}/eghu-indicator-detail-${DateTime.now().microsecondsSinceEpoch}-$name',
  )..writeAsBytesSync(List<int>.filled(64, 1));
}
