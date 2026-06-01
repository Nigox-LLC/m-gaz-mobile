import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:m_gaz/core/models/global/base_model.dart';
import 'package:m_gaz/core/models/working_with_consumers_document/working_with_consumers_document_detail.dart';
import 'package:m_gaz/core/models/working_with_consumers_document/working_with_consumers_list.dart';
import 'package:m_gaz/features/actions/data/datasources/eghu_indicator_api.dart';
import 'package:m_gaz/features/actions/data/models/eghu_action_attachment.dart';
import 'package:m_gaz/features/actions/data/models/eghu_indicator_create_request.dart';
import 'package:m_gaz/features/actions/presentation/pages/eghu/presentation/bloc/eghu_indicator_create_bloc/eghu_indicator_create_bloc.dart';

void main() {
  group('EghuIndicatorCreateBloc', () {
    late File basicFile;
    late File printFile;
    late _FakeSubmitApi api;
    late EghuIndicatorCreateBloc bloc;

    setUp(() {
      basicFile = _tempFile('basic.pdf');
      printFile = _tempFile('print.pdf');
      api = _FakeSubmitApi();
      bloc = EghuIndicatorCreateBloc(
        api: api,
        now: DateTime.utc(2026, 5, 31, 7, 36, 58, 8),
      );
    });

    tearDown(() async {
      await bloc.close();
      if (basicFile.existsSync()) basicFile.deleteSync();
      if (printFile.existsSync()) printFile.deleteSync();
    });

    test('requires consumer, EGHU, value and both files', () async {
      bloc
        ..add(EghuIndicatorConsumerSelected(_consumer()))
        ..add(EghuIndicatorEghuSelected(_eghu(), consumerDetail: _detail()))
        ..add(const EghuIndicatorValueChanged('2924'))
        ..add(EghuIndicatorBasicFileSet(_attachment(basicFile.path)));
      await pumpEventQueue();

      expect(bloc.state.canSubmit, isFalse);

      bloc.add(EghuIndicatorPrintFileSet(_attachment(printFile.path)));
      await pumpEventQueue();

      expect(bloc.state.canSubmit, isTrue);
    });

    test('normalizes comma decimal value before submit', () async {
      bloc
        ..add(EghuIndicatorConsumerSelected(_consumer()))
        ..add(EghuIndicatorEghuSelected(_eghu(), consumerDetail: _detail()))
        ..add(const EghuIndicatorValueChanged('2924,5'))
        ..add(EghuIndicatorBasicFileSet(_attachment(basicFile.path)))
        ..add(EghuIndicatorPrintFileSet(_attachment(printFile.path)));
      await pumpEventQueue();

      bloc.add(const EghuIndicatorSubmitted());
      await pumpEventQueue();

      expect(bloc.state.status, EghuIndicatorSubmitStatus.success);
      expect(api.request, isNotNull);
      expect(api.request!.toJson()['value'], '2924.50');
      expect(api.request!.toJson()['consumer'], 12);
      expect(api.request!.toJson()['egxu'], 44);
    });

    test('rejects zero and negative values locally', () async {
      bloc
        ..add(EghuIndicatorConsumerSelected(_consumer()))
        ..add(EghuIndicatorEghuSelected(_eghu(), consumerDetail: _detail()))
        ..add(const EghuIndicatorValueChanged('0'))
        ..add(EghuIndicatorBasicFileSet(_attachment(basicFile.path)))
        ..add(EghuIndicatorPrintFileSet(_attachment(printFile.path)));
      await pumpEventQueue();

      expect(bloc.state.canSubmit, isFalse);
      expect(bloc.state.toRequest(now: DateTime.now()), isNull);
    });
  });
}

class _FakeSubmitApi implements EghuIndicatorSubmitApi {
  EghuIndicatorCreateRequest? request;

  @override
  Future<void> create(EghuIndicatorCreateRequest request) async {
    this.request = request;
  }
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
    '${Directory.systemTemp.path}/eghu-indicator-bloc-${DateTime.now().microsecondsSinceEpoch}-$name',
  )..writeAsBytesSync(List<int>.filled(64, 1));
}
