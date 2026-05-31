import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:m_gaz/core/models/global/base_model.dart';
import 'package:m_gaz/core/models/working_with_consumers_document/working_with_consumers_document_detail.dart';
import 'package:m_gaz/core/models/working_with_consumers_document/working_with_consumers_list.dart';
import 'package:m_gaz/features/actions/data/datasources/eghu_action_api.dart';
import 'package:m_gaz/features/actions/data/models/eghu_action_attachment.dart';
import 'package:m_gaz/features/actions/data/models/eghu_action_create_request.dart';
import 'package:m_gaz/features/actions/presentation/pages/eghu/presentation/bloc/eghu_detach_create_bloc.dart';

void main() {
  group('EghuDetachCreateBloc', () {
    late _FakeSubmitApi api;
    late EghuDetachCreateBloc bloc;
    late File actFile;
    late File proofFile;
    late File protocolFile;

    setUp(() {
      api = _FakeSubmitApi();
      bloc = EghuDetachCreateBloc(
        api: api,
        employeeId: 77,
        employeeName: 'Tester',
        regionId: 3,
        districtId: 50,
        now: DateTime(2026, 5, 28, 17, 38),
      );
      actFile = _tempFile('act.jpg');
      proofFile = _tempFile('proof.jpg');
      protocolFile = _tempFile('protocol.pdf');
    });

    tearDown(() async {
      await bloc.close();
      if (actFile.existsSync()) actFile.deleteSync();
      if (proofFile.existsSync()) proofFile.deleteSync();
      if (protocolFile.existsSync()) protocolFile.deleteSync();
    });

    test(
      'working seal requires proof and defaults gas stopped to no',
      () async {
        bloc
          ..add(EghuDetachConsumerSelected(_consumer()))
          ..add(EghuDetachEghuSelected(_eghu(), consumerDetail: _detail()))
          ..add(const EghuDetachReasonSelected(EghuDetachReason.repair))
          ..add(
            const EghuDetachSealStatusSelected(EghuDetachSealStatus.working),
          );

        await pumpEventQueue();

        expect(bloc.state.canSubmit, isFalse);
        expect(bloc.state.shouldShowProof, isTrue);
        expect(bloc.state.shouldShowGasSupplyStopped, isFalse);

        bloc.add(EghuDetachProofFileSet(_attachment(proofFile.path)));
        await pumpEventQueue();

        expect(bloc.state.canSubmit, isTrue);
        expect(bloc.state.actFile, isNull);

        bloc.add(const EghuDetachSubmitted());
        await pumpEventQueue();

        expect(bloc.state.status, EghuDetachSubmitStatus.success);
        final request = api.request;
        expect(request, isNotNull);
        expect(request!.actFile, isNull);
        expect(request.proofFile, isNotNull);
        expect(request.protocolFile, isNull);
        final json = request.toJson();
        expect(json['document_type'], 'removal');
        expect(json['reason'], 'repair');
        expect(json['seal_status'], 'working');
        expect(json['gas_supply_stopped'], 'no');
        expect(json.containsKey('reals'), isFalse);
      },
    );

    test('requires other reason text when reason is other', () async {
      bloc
        ..add(EghuDetachConsumerSelected(_consumer()))
        ..add(EghuDetachEghuSelected(_eghu()))
        ..add(const EghuDetachReasonSelected(EghuDetachReason.other))
        ..add(const EghuDetachSealStatusSelected(EghuDetachSealStatus.working))
        ..add(EghuDetachProofFileSet(_attachment(proofFile.path)));

      await pumpEventQueue();
      expect(bloc.state.canSubmit, isFalse);

      bloc.add(const EghuDetachOtherReasonChanged('Abonent arizasi'));
      await pumpEventQueue();

      expect(bloc.state.canSubmit, isTrue);
      final json = bloc.state
          .toRequest(now: DateTime(2026, 5, 28, 17, 38))!
          .toJson();
      expect(json['reason'], 'other');
      expect(json['other_reason'], 'Abonent arizasi');
    });

    test(
      'defective seal with gas stopped yes requires akt and stamp',
      () async {
        bloc
          ..add(EghuDetachConsumerSelected(_consumer()))
          ..add(EghuDetachEghuSelected(_eghu(), consumerDetail: _detail()))
          ..add(
            const EghuDetachReasonSelected(EghuDetachReason.periodicComparison),
          )
          ..add(
            const EghuDetachSealStatusSelected(EghuDetachSealStatus.defective),
          )
          ..add(
            const EghuDetachGasSupplyStoppedSelected(EghuGasSupplyStopped.yes),
          );

        await pumpEventQueue();
        expect(bloc.state.canSubmit, isFalse);
        expect(bloc.state.shouldShowGasSupplyStopped, isFalse);

        bloc.add(EghuDetachActFileSet(_attachment(actFile.path)));
        await pumpEventQueue();

        expect(bloc.state.canSubmit, isFalse);
        expect(bloc.state.shouldShowGasSupplyStopped, isTrue);
        expect(bloc.state.shouldShowStamp, isTrue);

        bloc.add(const EghuDetachStampNumberChanged('998877'));
        await pumpEventQueue();

        expect(bloc.state.canSubmit, isTrue);

        bloc.add(const EghuDetachSubmitted());
        await pumpEventQueue();

        final request = api.request;
        expect(request, isNotNull);
        expect(request!.actFile, isNotNull);
        expect(request.proofFile, isNull);
        expect(request.protocolFile, isNull);
        expect(request.comparisonFile, isNull);
        final json = request.toJson(aktIds: const [5]);
        expect(json['reason'], 'periodic_comparison');
        expect(json['seal_status'], 'defective');
        expect(json['gas_supply_stopped'], 'yes');
        final real = (json['reals'] as List).single as Map<String, Object?>;
        expect(real['real_number_value'], '998877');
        expect(real['installed_date'], '2026-05-28');
        expect(json['akt_ids'], [5]);
      },
    );

    test('defective seal with gas stopped no requires protocol file', () async {
      bloc
        ..add(EghuDetachConsumerSelected(_consumer()))
        ..add(EghuDetachEghuSelected(_eghu(), consumerDetail: _detail()))
        ..add(const EghuDetachReasonSelected(EghuDetachReason.repair))
        ..add(
          const EghuDetachSealStatusSelected(EghuDetachSealStatus.defective),
        )
        ..add(EghuDetachActFileSet(_attachment(actFile.path)))
        ..add(
          const EghuDetachGasSupplyStoppedSelected(EghuGasSupplyStopped.no),
        );

      await pumpEventQueue();

      expect(bloc.state.canSubmit, isFalse);
      expect(bloc.state.shouldShowProtocol, isTrue);

      bloc.add(EghuDetachProtocolFileSet(_attachment(protocolFile.path)));
      await pumpEventQueue();

      expect(bloc.state.canSubmit, isTrue);

      bloc.add(const EghuDetachSubmitted());
      await pumpEventQueue();

      final request = api.request;
      expect(request, isNotNull);
      expect(request!.actFile, isNotNull);
      expect(request.protocolFile, isNotNull);
      expect(request.proofFile, isNull);
      final json = request.toJson(aktIds: const [5, 8]);
      expect(json['gas_supply_stopped'], 'no');
      expect(json.containsKey('reals'), isFalse);
      expect(json['akt_ids'], [5, 8]);
    });

    test('stamp add and remove works for gas stopped yes flow', () async {
      bloc
        ..add(
          const EghuDetachSealStatusSelected(EghuDetachSealStatus.defective),
        )
        ..add(
          const EghuDetachGasSupplyStoppedSelected(EghuGasSupplyStopped.yes),
        );
      await pumpEventQueue();

      expect(bloc.state.stamps, hasLength(1));
      final previousFirstId = bloc.state.stamps.first.localId;

      bloc.add(const EghuDetachStampAdded());
      await pumpEventQueue();

      expect(bloc.state.stamps, hasLength(2));
      expect(bloc.state.stamps.first.installedAt.second, 0);
      expect(bloc.state.stamps.first.installedAt.millisecond, 0);
      expect(bloc.state.stamps[1].localId, previousFirstId);

      final localId = bloc.state.stamps.first.localId;
      bloc.add(EghuDetachStampRemoved(localId));
      await pumpEventQueue();

      expect(bloc.state.stamps, hasLength(1));
    });
  });
}

class _FakeSubmitApi implements EghuActionSubmitApi {
  EghuActionCreateRequest? request;

  @override
  Future<void> create(EghuActionCreateRequest request) async {
    this.request = request;
  }
}

WorkingWithConsumersList _consumer({int id = 12}) {
  return WorkingWithConsumersList(
    id: id,
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
  return ConsumersEgxuItem(
    id: 44,
    consumerRelationEgxu: ConsumerRelationEgxu(typeOfActivityId: 110),
    egxuType: ConsumersEgxuType(id: 9, name: 'Rotary'),
    gasEquipmentList: [
      ConsumersGasEquipmentItem(
        quantity: 2,
        gasEquipment: ConsumersGasEquipment(
          id: 1,
          name: 'Qozon',
          hourlyGasConsumption: 1.5,
        ),
      ),
    ],
    oneFactory: 'Zavod 1',
    twoFactory: 'Zavod 2',
  );
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
    isImage: true,
    sourceLabel: 'Test',
    createdAt: DateTime(2026, 5, 28, 9),
  );
}

File _tempFile(String name) {
  return File(
    '${Directory.systemTemp.path}/eghu-detach-${DateTime.now().microsecondsSinceEpoch}-$name',
  )..writeAsBytesSync(List<int>.filled(64, 1));
}
