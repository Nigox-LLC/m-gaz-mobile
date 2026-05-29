import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:m_gaz/core/models/paginated_response/paginated_response.dart';
import 'package:m_gaz/core/models/working_with_consumers_document/working_with_consumers_document_detail.dart';
import 'package:m_gaz/core/models/working_with_consumers_document/working_with_consumers_list.dart';
import 'package:m_gaz/features/actions/data/datasources/eghu_action_api.dart';
import 'package:m_gaz/features/actions/data/models/eghu_action_attachment.dart';
import 'package:m_gaz/features/actions/data/models/eghu_action_create_request.dart';
import 'package:m_gaz/features/actions/data/models/eghu_working_document.dart';
import 'package:m_gaz/features/actions/domain/entities/action_menu_item.dart';
import 'package:m_gaz/features/actions/presentation/pages/eghu/presentation/bloc/eghu_action_create_bloc.dart';
import 'package:m_gaz/features/actions/presentation/pages/eghu/presentation/bloc/eghu_action_list_bloc.dart';
import 'package:m_gaz/features/actions/presentation/pages/eghu/presentation/pages/eghu_action_create_page.dart';
import 'package:m_gaz/features/actions/presentation/pages/eghu/presentation/widgets/create/eghu_action_bottom_sheets.dart';
import 'package:m_gaz/features/actions/presentation/pages/eghu/presentation/widgets/create/eghu_action_form_fields.dart';
import 'package:m_gaz/features/actions/presentation/pages/eghu/presentation/widgets/create/eghu_action_upload_widgets.dart';
import 'package:m_gaz/features/actions/presentation/pages/eghu/presentation/widgets/eghu_action_card.dart';
import 'package:m_gaz/features/actions/presentation/pages/eghu/presentation/widgets/eghu_action_list_page.dart';

void main() {
  testWidgets('list header add callback is called', (tester) async {
    var addCount = 0;
    await tester.pumpWidget(
      MaterialApp(
        home: EghuActionListPage(
          title: 'EGHU qayta o\'rnatish',
          items: const [
            EghuActionCardData(
              personalAccount: '1',
              factoryNumber: '2',
              region: 'Andijon',
              district: 'Andijon',
              date: '01.01.2026',
              employee: 'Tester',
            ),
          ],
          onAdd: () => addCount++,
        ),
      ),
    );

    await tester.tap(find.text("Qo'shish"));
    await tester.pump();

    expect(addCount, 1);
  });

  testWidgets('remote list renders working-with-egxu API data', (tester) async {
    final bloc = EghuActionListBloc(
      api: _FakeListApi(
        PaginatedResponse(
          count: 1,
          next: null,
          previous: null,
          results: [
            EghuWorkingDocument(
              id: 1,
              datetime: DateTime(2026, 5, 28, 10),
              region: 'Andijon',
              district: 'Andijon tumani',
              typeOfActivity: 'Sanoat',
              documentType: 'consumer',
              documentTypeDisplay: "Iste'molchi",
              employee: 'Tester',
              isActive: true,
            ),
          ],
        ),
      ),
    );
    addTearDown(bloc.close);

    await tester.pumpWidget(
      MaterialApp(
        home: EghuActionListPage(
          title: "EGHU qayta o'rnatish",
          useRemoteList: true,
          bloc: bloc,
        ),
      ),
    );
    await tester.pump();
    await tester.pump();

    expect(
      find.textContaining("Iste'molchi", findRichText: true),
      findsOneWidget,
    );
    expect(find.text('Andijon'), findsOneWidget);
    expect(find.text('Andijon tumani'), findsOneWidget);
  });

  testWidgets('create page enables submit when all required fields are set', (
    tester,
  ) async {
    final api = _FakeSubmitApi();
    final source = _FakeSource();
    final bloc =
        EghuActionCreateBloc(
            actionType: ActionMenuType.detach,
            api: api,
            employeeId: 7,
            employeeName: 'Tester',
            initialStampDateTime: DateTime(2026, 5, 28, 17, 38),
          )
          ..add(EghuActionConsumerSelected(_consumer()))
          ..add(EghuActionEghuSelected(_eghu()))
          ..add(
            EghuActionAttachmentSet(
              slot: EghuActionAttachmentSlot.act,
              file: _attachment('/tmp/act.jpg', true),
            ),
          )
          ..add(
            EghuActionAttachmentSet(
              slot: EghuActionAttachmentSlot.comparison,
              file: _attachment('/tmp/comparison.pdf', false),
            ),
          )
          ..add(const EghuActionStampNumberChanged('234543245675432'));

    addTearDown(bloc.close);

    await tester.pumpWidget(
      MaterialApp(
        home: EghuActionCreatePage(
          actionType: ActionMenuType.detach,
          bloc: bloc,
          consumerSource: source,
          api: api,
        ),
      ),
    );

    await tester.pump();

    expect(find.text('EGHU yechib olish'), findsOneWidget);
    expect(
      tester.widget<ElevatedButton>(find.byType(ElevatedButton)).enabled,
      isTrue,
    );

    expect(api.request, isNull);
  });

  testWidgets('stamp section shows current user and date without sublabel', (
    tester,
  ) async {
    final controller = TextEditingController(text: '123');
    addTearDown(controller.dispose);

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: EghuStampSection(
            controller: controller,
            employeeName: 'Current User',
            selectedDate: DateTime(2026, 5, 28, 17, 38),
            onNumberChanged: (_) {},
            onPickDate: () {},
          ),
        ),
      ),
    );

    expect(find.text('Current User'), findsOneWidget);
    expect(find.text('Doston Dostonov'), findsNothing);
    expect(find.text('28.05.2026 17:38'), findsOneWidget);
    expect(find.text("Tamg'a sanasi"), findsNothing);
  });

  testWidgets('consumer sheet supports loading, search, empty, and selection', (
    tester,
  ) async {
    final source = _FakeSource(consumers: [_consumer()]);

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(body: EghuConsumerPickerSheet(source: source)),
      ),
    );

    await tester.pumpAndSettle();

    expect(
      find.textContaining('1651512649', findRichText: true),
      findsOneWidget,
    );
    await tester.enterText(
      find.byKey(const Key('eghu-picker-search-field')),
      'test',
    );
    await tester.pump(const Duration(milliseconds: 450));
    await tester.pumpAndSettle();
    expect(source.lastSearch, 'test');

    await tester.tap(find.textContaining('1651512649', findRichText: true));
    await tester.pumpAndSettle();
  });

  testWidgets('consumer sheet shows empty state', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: EghuConsumerPickerSheet(source: _FakeSource(consumers: [])),
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text("Iste'molchi topilmadi"), findsOneWidget);
  });

  testWidgets('consumer sheet shows error with retry action', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: EghuConsumerPickerSheet(
            source: _FakeSource(error: Exception('Network error')),
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('Network error'), findsOneWidget);
    expect(find.text('Qayta urinish'), findsOneWidget);
  });

  testWidgets('EGHU sheet loads detail and selects an item', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: EghuDevicePickerSheet(
            source: _FakeSource(egxus: [_eghu()]),
            consumer: _consumer(),
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.textContaining('Eghu id:', findRichText: true), findsOneWidget);
    expect(find.textContaining('Zavod 1', findRichText: true), findsOneWidget);
    await tester.enterText(
      find.byKey(const Key('eghu-picker-search-field')),
      'Zavod',
    );
    await tester.pump();
    expect(find.textContaining('Zavod 1', findRichText: true), findsOneWidget);
  });

  testWidgets('attachment source sheet returns camera/device options', (
    tester,
  ) async {
    EghuAttachmentSource? selected;
    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) {
            return Scaffold(
              body: ElevatedButton(
                onPressed: () async {
                  selected = await showModalBottomSheet<EghuAttachmentSource>(
                    context: context,
                    isScrollControlled: true,
                    backgroundColor: Colors.transparent,
                    builder: (_) => const EghuAttachmentSourceSheet(),
                  );
                },
                child: const Text('open'),
              ),
            );
          },
        ),
      ),
    );

    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
    expect(find.text('Kamerani ochish'), findsOneWidget);
    expect(find.text('Telefonda yuklash'), findsOneWidget);
    await tester.tap(find.text('Telefonda yuklash'));
    await tester.pumpAndSettle();
    expect(selected, EghuAttachmentSource.device);
  });

  testWidgets('uploaded file preview can be removed', (tester) async {
    final file = File(
      '${Directory.systemTemp.path}/eghu-widget-${DateTime.now().microsecondsSinceEpoch}.jpg',
    )..writeAsBytesSync(List<int>.filled(64, 1));
    EghuActionAttachment? attachment = _attachment(file.path, true);
    addTearDown(() {
      if (file.existsSync()) file.deleteSync();
    });

    await tester.pumpWidget(
      MaterialApp(
        home: StatefulBuilder(
          builder: (context, setState) {
            return Scaffold(
              body: EghuUploadSection(
                slot: EghuActionAttachmentSlot.act,
                attachment: attachment,
                onAdd: () {},
                onRemove: () => setState(() => attachment = null),
              ),
            );
          },
        ),
      ),
    );

    expect(find.byKey(const Key('eghu-upload-image-preview')), findsOneWidget);
    await tester.tap(find.byKey(const Key('eghu-upload-remove-button')));
    await tester.pump();
    expect(find.byKey(const Key('eghu-upload-drop-zone')), findsOneWidget);
  });

  testWidgets('uploaded attachment help opens inline metadata for both slots', (
    tester,
  ) async {
    for (final slot in EghuActionAttachmentSlot.values) {
      EghuActionAttachment? attachment = _attachment(
        '/tmp/${slot.name}.pdf',
        false,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: StatefulBuilder(
            builder: (context, setState) {
              return Scaffold(
                body: EghuUploadSection(
                  slot: slot,
                  attachment: attachment,
                  showHelp: true,
                  uploaderName: 'Current User',
                  onAdd: () {},
                  onRemove: () => setState(() => attachment = null),
                ),
              );
            },
          ),
        ),
      );

      expect(find.byKey(Key('eghu-upload-help-${slot.name}')), findsOneWidget);
      expect(find.byType(AlertDialog), findsNothing);
      expect(find.byKey(Key('eghu-upload-info-${slot.name}')), findsNothing);

      await tester.tap(find.byKey(Key('eghu-upload-help-${slot.name}')));
      await tester.pump();

      expect(find.byType(AlertDialog), findsNothing);
      expect(find.byKey(Key('eghu-upload-info-${slot.name}')), findsOneWidget);
      expect(
        find.textContaining('Yukladi: Current User', findRichText: true),
        findsOneWidget,
      );
      expect(
        find.textContaining('Sanasi: 28.05.2026 09:00', findRichText: true),
        findsOneWidget,
      );
      expect(
        find.textContaining('Hajmi: 0.1 KB', findRichText: true),
        findsOneWidget,
      );

      await tester.tap(find.byKey(const Key('eghu-upload-file-remove-button')));
      await tester.pump();

      expect(find.byKey(Key('eghu-upload-info-${slot.name}')), findsNothing);
      expect(find.byKey(const Key('eghu-upload-drop-zone')), findsOneWidget);
    }
  });
}

class _FakeSubmitApi implements EghuActionSubmitApi {
  EghuActionCreateRequest? request;

  @override
  Future<void> create(EghuActionCreateRequest request) async {
    this.request = request;
  }
}

class _FakeListApi implements EghuActionListApi {
  _FakeListApi(this.response);

  final PaginatedResponse<EghuWorkingDocument> response;

  @override
  Future<PaginatedResponse<EghuWorkingDocument>> getDocuments({
    int limit = 10,
    int offset = 0,
  }) async {
    return response;
  }

  @override
  Future<PaginatedResponse<EghuWorkingDocument>> getNextPage(String url) async {
    return response;
  }
}

class _FakeSource implements EghuActionConsumerSource {
  _FakeSource({this.consumers = const [], this.egxus = const [], this.error});

  final List<WorkingWithConsumersList> consumers;
  final List<ConsumersEgxuItem> egxus;
  final Object? error;
  String? lastSearch;

  @override
  Future<PaginatedResponse<WorkingWithConsumersList>> getDocuments({
    int limit = 20,
    String? search,
  }) async {
    lastSearch = search;
    final error = this.error;
    if (error != null) throw error;
    return PaginatedResponse(
      count: consumers.length,
      next: null,
      previous: null,
      results: consumers,
    );
  }

  @override
  Future<PaginatedResponse<WorkingWithConsumersList>> getNextPage(String url) {
    return getDocuments();
  }

  @override
  Future<WorkingWithConsumersDetailModel> getDocumentById(int id) async {
    final error = this.error;
    if (error != null) throw error;
    return WorkingWithConsumersDetailModel(egxuList: egxus);
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
  return ConsumersEgxuItem(
    id: 44,
    oneFactory: 'Zavod 1',
    twoFactory: 'Zavod 2',
  );
}

EghuActionAttachment _attachment(String path, bool isImage) {
  return EghuActionAttachment(
    path: path,
    name: path.replaceAll('\\', '/').split('/').last,
    sizeBytes: 64,
    isImage: isImage,
    sourceLabel: 'Test',
    createdAt: DateTime(2026, 5, 28, 9),
  );
}
