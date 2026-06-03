import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:m_gaz/core/models/global/base_model.dart';
import 'package:m_gaz/core/models/working_with_consumers_document/working_with_consumers_document_detail.dart';
import 'package:m_gaz/core/models/working_with_consumers_document/working_with_consumers_list.dart';
import 'package:m_gaz/features/actions/data/datasources/eghu_action_api.dart';
import 'package:m_gaz/features/actions/data/models/eghu_action_attachment.dart';
import 'package:m_gaz/features/actions/data/models/eghu_action_create_request.dart';
import 'package:m_gaz/features/actions/data/models/eghu_removal_detail.dart';
import 'package:m_gaz/features/actions/domain/entities/action_menu_item.dart';
import 'package:m_gaz/features/actions/presentation/pages/eghu/presentation/bloc/eghu_action_create_bloc/eghu_action_create_bloc.dart';

void main() {
  group('EghuActionCreateBloc', () {
    late _FakeSubmitApi api;
    late EghuActionCreateBloc bloc;
    late File actFile;
    late File comparisonFile;

    setUp(() {
      api = _FakeSubmitApi();
      bloc = EghuActionCreateBloc(
        actionType: ActionMenuType.reinstall,
        api: api,
        employeeId: 77,
        employeeName: 'Tester',
        regionId: 3,
        districtId: 50,
        initialStampDateTime: DateTime(2026, 5, 28, 17, 38),
      );
      actFile = _tempFile('act.jpg');
      comparisonFile = _tempFile('comparison.pdf');
    });

    tearDown(() async {
      await bloc.close();
      if (actFile.existsSync()) actFile.deleteSync();
      if (comparisonFile.existsSync()) comparisonFile.deleteSync();
    });

    test('initializes stamp date automatically', () async {
      final freshBloc = EghuActionCreateBloc(
        actionType: ActionMenuType.reinstall,
        api: _FakeSubmitApi(),
      );
      addTearDown(freshBloc.close);

      expect(bloc.state.stampDateTime, DateTime(2026, 5, 28, 17, 38));
      expect(freshBloc.state.stampDateTime, isNotNull);
      expect(freshBloc.state.stampDateTime!.second, 0);
      expect(freshBloc.state.stampDateTime!.millisecond, 0);
    });

    test('validates required fields before submit', () async {
      expect(bloc.state.canSubmit, isFalse);

      bloc
        ..add(EghuActionConsumerSelected(_consumer()))
        ..add(EghuActionEghuSelected(_eghu(), consumerDetail: _detail()))
        ..add(
          EghuActionAttachmentSet(
            slot: EghuActionAttachmentSlot.act,
            file: _attachment(actFile.path, true),
          ),
        )
        ..add(
          EghuActionAttachmentSet(
            slot: EghuActionAttachmentSlot.comparison,
            file: _attachment(comparisonFile.path, false),
          ),
        )
        ..add(const EghuActionStampNumberChanged('234543245675432'));

      await pumpEventQueue();

      // Reinstall requires a stamp installation place before submit is allowed.
      expect(bloc.state.canSubmit, isFalse);

      bloc.add(
        EghuActionStampPlaceChanged(
          localId: bloc.state.stamps.first.localId,
          placeId: 5,
          placeName: 'Quvur kirishi',
        ),
      );
      await pumpEventQueue();

      expect(bloc.state.canSubmit, isTrue);
      final request = bloc.state.toRequest();
      expect(request, isNotNull);
      expect(request!.consumerDocumentId, 12);
      expect(request.egxuItemId, 44);
      expect(request.employeeId, 77);
      expect(request.stampNumber, '234543245675432');
      expect(request.regionId, 3);
      expect(request.districtId, 50);
      expect(request.typeOfActivityId, 110);
      final real = (request.toJson()['reals'] as List).single as Map;
      expect(real['seal_initalled_location'], 5);

      bloc.add(EghuActionStampPlaceCleared(bloc.state.stamps.first.localId));
      await pumpEventQueue();
      expect(bloc.state.canSubmit, isFalse);
    });

    test('profile update preserves existing form values', () async {
      bloc
        ..add(EghuActionConsumerSelected(_consumer()))
        ..add(EghuActionEghuSelected(_eghu(), consumerDetail: _detail()))
        ..add(
          EghuActionAttachmentSet(
            slot: EghuActionAttachmentSlot.act,
            file: _attachment(actFile.path, true),
          ),
        )
        ..add(
          EghuActionAttachmentSet(
            slot: EghuActionAttachmentSlot.comparison,
            file: _attachment(comparisonFile.path, false),
          ),
        )
        ..add(const EghuActionStampNumberChanged('234543245675432'));

      await pumpEventQueue();

      final stampDate = bloc.state.stampDateTime;
      bloc.add(
        const EghuActionProfileChanged(
          employeeId: 91,
          employeeName: 'Current User',
          regionId: 8,
          districtId: 23,
        ),
      );

      await pumpEventQueue();

      expect(bloc.state.employeeId, 91);
      expect(bloc.state.employeeName, 'Current User');
      expect(bloc.state.profileRegionId, 8);
      expect(bloc.state.profileDistrictId, 23);
      expect(bloc.state.selectedConsumer, isNotNull);
      expect(bloc.state.selectedEghu, isNotNull);
      expect(bloc.state.actFile, isNotNull);
      expect(bloc.state.comparisonFile, isNotNull);
      expect(bloc.state.stampNumber, '234543245675432');
      expect(bloc.state.stampDateTime, stampDate);
    });

    test('selecting consumer clears selected EGHU', () async {
      bloc
        ..add(EghuActionConsumerSelected(_consumer()))
        ..add(EghuActionEghuSelected(_eghu()));

      await pumpEventQueue();

      expect(bloc.state.selectedEghu, isNotNull);

      bloc.add(EghuActionConsumerSelected(_consumer(id: 13)));
      await pumpEventQueue();

      expect(bloc.state.selectedConsumer!.id, 13);
      expect(bloc.state.selectedEghu, isNull);
    });

    test('submit sends built request and emits success', () async {
      bloc
        ..add(EghuActionConsumerSelected(_consumer()))
        ..add(EghuActionEghuSelected(_eghu(), consumerDetail: _detail()))
        ..add(
          EghuActionAttachmentSet(
            slot: EghuActionAttachmentSlot.act,
            file: _attachment(actFile.path, true),
          ),
        )
        ..add(
          EghuActionAttachmentSet(
            slot: EghuActionAttachmentSlot.comparison,
            file: _attachment(comparisonFile.path, false),
          ),
        )
        ..add(const EghuActionStampNumberChanged('123'));
      await pumpEventQueue();

      bloc.add(
        EghuActionStampPlaceChanged(
          localId: bloc.state.stamps.first.localId,
          placeId: 5,
          placeName: 'Quvur kirishi',
        ),
      );
      await pumpEventQueue();

      bloc.add(const EghuActionSubmitted());
      await pumpEventQueue();

      expect(bloc.state.status, EghuActionSubmitStatus.success);
      expect(api.request, isNotNull);
      expect(api.request!.actionCode, 'reinstall');
      final json = api.request!.toJson();
      expect(json['consumer'], 12);
      expect(json['egxu'], 44);
      expect(json['document_type'], 'reinstall');
      expect(json['reason'], 'eghu_improvement');
      expect(json['seal_status'], 'working');
      expect(json['gas_supply_stopped'], 'no');
      expect(json['akt_ids'], isEmpty);
      final real = (json['reals'] as List).single as Map<String, Object?>;
      expect(real['id'], isNull);
      expect(real['real_number_value'], '123');
      expect(real['installed_date'], '2026-05-28');
      expect(real['seal_initalled_location'], 5);
    });

    test('detach request maps to removal document type', () async {
      final detachBloc = EghuActionCreateBloc(
        actionType: ActionMenuType.detach,
        api: api,
        initialStampDateTime: DateTime(2026, 5, 28, 17, 38),
      );
      addTearDown(detachBloc.close);

      detachBloc
        ..add(EghuActionConsumerSelected(_consumer()))
        ..add(EghuActionEghuSelected(_eghu(), consumerDetail: _detail()))
        ..add(
          EghuActionAttachmentSet(
            slot: EghuActionAttachmentSlot.act,
            file: _attachment(actFile.path, true),
          ),
        )
        ..add(
          EghuActionAttachmentSet(
            slot: EghuActionAttachmentSlot.comparison,
            file: _attachment(comparisonFile.path, false),
          ),
        )
        ..add(const EghuActionStampNumberChanged('456'));
      await pumpEventQueue();

      detachBloc.add(const EghuActionSubmitted());
      await pumpEventQueue();

      expect(detachBloc.state.status, EghuActionSubmitStatus.success);
      final json = api.request!.toJson();
      expect(json['document_type'], 'removal');
      expect(json['reason'], 'repair');
    });

    test('submit emits failure when API fails', () async {
      api.error = Exception('Server error');
      bloc
        ..add(EghuActionConsumerSelected(_consumer()))
        ..add(EghuActionEghuSelected(_eghu(), consumerDetail: _detail()))
        ..add(
          EghuActionAttachmentSet(
            slot: EghuActionAttachmentSlot.act,
            file: _attachment(actFile.path, true),
          ),
        )
        ..add(
          EghuActionAttachmentSet(
            slot: EghuActionAttachmentSlot.comparison,
            file: _attachment(comparisonFile.path, false),
          ),
        )
        ..add(const EghuActionStampNumberChanged('123'));
      await pumpEventQueue();

      bloc.add(
        EghuActionStampPlaceChanged(
          localId: bloc.state.stamps.first.localId,
          placeId: 5,
          placeName: 'Quvur kirishi',
        ),
      );
      await pumpEventQueue();

      bloc.add(const EghuActionSubmitted());
      await pumpEventQueue();

      expect(bloc.state.status, EghuActionSubmitStatus.failure);
      expect(bloc.state.errorMessage, 'Server error');
    });

    test('submit succeeds when type of activity is missing', () async {
      bloc
        ..add(EghuActionConsumerSelected(_consumer()))
        ..add(
          EghuActionEghuSelected(_eghuWithoutType(), consumerDetail: _detail()),
        )
        ..add(
          EghuActionAttachmentSet(
            slot: EghuActionAttachmentSlot.act,
            file: _attachment(actFile.path, true),
          ),
        )
        ..add(
          EghuActionAttachmentSet(
            slot: EghuActionAttachmentSlot.comparison,
            file: _attachment(comparisonFile.path, false),
          ),
        )
        ..add(const EghuActionStampNumberChanged('123'));
      await pumpEventQueue();

      bloc.add(
        EghuActionStampPlaceChanged(
          localId: bloc.state.stamps.first.localId,
          placeId: 5,
          placeName: 'Quvur kirishi',
        ),
      );
      await pumpEventQueue();

      bloc.add(const EghuActionSubmitted());
      await pumpEventQueue();

      expect(bloc.state.status, EghuActionSubmitStatus.success);
      expect(api.request, isNotNull);
    });

    test('add creates a new stamp and unsaved stamp can be removed', () async {
      expect(bloc.state.stamps, hasLength(1));
      final previousFirstId = bloc.state.stamps.first.localId;

      bloc.add(const EghuActionStampAdded());
      await pumpEventQueue();

      expect(bloc.state.stamps, hasLength(2));
      expect(bloc.state.stamps.first.employeeName, 'Tester');
      expect(bloc.state.stamps.first.installedAt.second, 0);
      expect(bloc.state.stamps.first.installedAt.millisecond, 0);
      expect(bloc.state.stamps[1].localId, previousFirstId);

      final localId = bloc.state.stamps.first.localId;
      bloc.add(EghuActionStampRemoved(localId));
      await pumpEventQueue();

      expect(bloc.state.stamps, hasLength(1));
    });

    test('update request sends only changed and new stamps', () async {
      final detailApi = _FakeDetailApi();
      final editBloc = EghuActionCreateBloc(
        actionType: ActionMenuType.reinstall,
        api: api,
        detailApi: detailApi,
        employeeName: 'Tester',
        initialStampDateTime: DateTime(2026, 5, 30, 10, 45),
        detail: EghuRemovalDetail(
          id: 99,
          documentType: 'reinstall',
          consumerId: 12,
          consumerName: 'Tashkilot nomi',
          egxuId: 44,
          egxuSerialNumber: 'Zavod 1',
          reals: const [
            EghuRemovalReal(
              id: 1,
              realNumberValue: '111',
              installedDate: '2026-05-28',
              installationPlaceId: 9,
              installationPlaceName: 'Joy',
            ),
            EghuRemovalReal(
              id: 2,
              realNumberValue: '222',
              installedDate: '2026-05-29',
              installationPlaceId: 9,
              installationPlaceName: 'Joy',
            ),
          ],
          akts: const [
            EghuRemovalAkt(
              id: 7,
              fileUrl: 'https://example.com/act.jpg',
              aktFileType: 'akt',
            ),
            EghuRemovalAkt(
              id: 8,
              fileUrl: 'https://example.com/comparison.pdf',
              aktFileType: 'calibration',
            ),
          ],
        ),
      );
      addTearDown(editBloc.close);

      final changedStampId = editBloc.state.stamps[1].localId;
      editBloc
        ..add(
          EghuActionStampNumberChanged('222-CHANGED', localId: changedStampId),
        )
        ..add(const EghuActionStampAdded());
      await pumpEventQueue();

      final newStampId = editBloc.state.stamps.first.localId;
      editBloc.add(EghuActionStampNumberChanged('333', localId: newStampId));
      await pumpEventQueue();

      // New stamp needs an installation place; the existing stamps already
      // carry one from the loaded detail.
      editBloc.add(
        EghuActionStampPlaceChanged(
          localId: newStampId,
          placeId: 9,
          placeName: 'Joy',
        ),
      );
      await pumpEventQueue();

      editBloc.add(const EghuActionSubmitted());
      await pumpEventQueue();

      expect(editBloc.state.status, EghuActionSubmitStatus.success);
      final json = detailApi.request!.toJson(aktIds: const [7, 8]);
      final reals = json['reals'] as List;
      expect(reals, hasLength(2));
      expect(reals[0], containsPair('id', null));
      expect(reals[0], containsPair('real_number_value', '333'));
      expect(reals[1], containsPair('id', 2));
      expect(reals[1], containsPair('real_number_value', '222-CHANGED'));
    });
  });
}

class _FakeSubmitApi implements EghuActionSubmitApi {
  EghuActionCreateRequest? request;
  Object? error;

  @override
  Future<void> create(EghuActionCreateRequest request) async {
    this.request = request;
    final error = this.error;
    if (error != null) throw error;
  }
}

class _FakeDetailApi implements EghuActionDetailApi {
  EghuActionCreateRequest? request;

  @override
  Future<EghuRemovalDetail> getDetail(int id) async {
    throw UnimplementedError();
  }

  @override
  Future<void> update(int id, EghuActionCreateRequest request) async {
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

ConsumersEgxuItem _eghuWithoutType() {
  return ConsumersEgxuItem(
    id: 44,
    consumerRelationEgxu: ConsumerRelationEgxu(),
    egxuType: ConsumersEgxuType(id: 9, name: 'Rotary'),
  );
}

EghuActionAttachment _attachment(String path, bool isImage) {
  return EghuActionAttachment(
    path: path,
    name: path.split(Platform.pathSeparator).last,
    sizeBytes: 64,
    isImage: isImage,
    sourceLabel: 'Test',
    createdAt: DateTime(2026, 5, 28, 9),
  );
}

File _tempFile(String name) {
  return File(
    '${Directory.systemTemp.path}/eghu-action-${DateTime.now().microsecondsSinceEpoch}-$name',
  )..writeAsBytesSync(List<int>.filled(64, 1));
}
