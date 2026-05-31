import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:dartz/dartz.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:m_gaz/core/common/words.dart';
import 'package:m_gaz/core/models/paginated_response/paginated_response.dart';
import 'package:m_gaz/core/models/working_with_consumers_document/working_with_consumers_document_detail.dart';
import 'package:m_gaz/core/models/working_with_consumers_document/working_with_consumers_list.dart';
import 'package:m_gaz/core/error/failures.dart';
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
import 'package:m_gaz/features/auth/domain/entities/auth_token.dart';
import 'package:m_gaz/features/auth/domain/entities/user.dart';
import 'package:m_gaz/features/auth/domain/repositories/auth_repository.dart';
import 'package:m_gaz/features/auth/domain/usecases/check_daily_agreement_usecase.dart';
import 'package:m_gaz/features/auth/domain/usecases/load_user_profile_usecase.dart';
import 'package:m_gaz/features/auth/domain/usecases/login_usecase.dart';
import 'package:m_gaz/features/auth/presentation/bloc/login_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    SharedPreferences.setMockInitialValues({});
    await EasyLocalization.ensureInitialized();
    EasyLocalization.logger.enableLevels = [];
  });

  testWidgets('list header add callback is called', (tester) async {
    var addCount = 0;
    await tester.pumpWidget(
      _LocalizedTestApp(
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
          onAdd: () {
            addCount++;
            return null;
          },
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text(Words.add.tr()));
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
      _LocalizedTestApp(
        home: EghuActionListPage(
          title: "EGHU qayta o'rnatish",
          useRemoteList: true,
          bloc: bloc,
        ),
      ),
    );
    await tester.pumpAndSettle();
    await tester.pump();
    await tester.pump();

    expect(
      find.textContaining("Iste'molchi", findRichText: true),
      findsOneWidget,
    );
    expect(find.text('Andijon'), findsOneWidget);
    expect(find.text('Andijon tumani'), findsOneWidget);
  });

  testWidgets('remote list refreshes when add callback returns true', (
    tester,
  ) async {
    final api = _FakeListApi(
      _listResponse([
        _workingDocument(id: 1, region: 'Andijon', district: 'Andijon tumani'),
      ]),
      additionalResponses: [
        _listResponse([
          _workingDocument(id: 2, region: 'Buxoro', district: 'Buxoro tumani'),
        ]),
      ],
    );
    final bloc = EghuActionListBloc(api: api);
    addTearDown(bloc.close);

    await tester.pumpWidget(
      _LocalizedTestApp(
        home: EghuActionListPage(
          title: "EGHU qayta o'rnatish",
          useRemoteList: true,
          bloc: bloc,
          onAdd: () => true,
        ),
      ),
    );
    await tester.pumpAndSettle();
    await tester.pump();
    await tester.pump();

    expect(api.getDocumentsCallCount, 1);
    expect(find.text('Andijon'), findsOneWidget);

    await tester.tap(find.text(Words.add.tr()));
    await tester.pump();
    await tester.pump();

    expect(api.getDocumentsCallCount, 2);
    expect(find.text('Buxoro'), findsOneWidget);
    expect(find.text('Andijon'), findsNothing);
  });

  testWidgets('remote list does not refresh when add callback is cancelled', (
    tester,
  ) async {
    final api = _FakeListApi(
      _listResponse([
        _workingDocument(id: 1, region: 'Andijon', district: 'Andijon tumani'),
      ]),
      additionalResponses: [
        _listResponse([
          _workingDocument(id: 2, region: 'Buxoro', district: 'Buxoro tumani'),
        ]),
      ],
    );
    final bloc = EghuActionListBloc(api: api);
    addTearDown(bloc.close);

    await tester.pumpWidget(
      _LocalizedTestApp(
        home: EghuActionListPage(
          title: "EGHU qayta o'rnatish",
          useRemoteList: true,
          bloc: bloc,
          onAdd: () => false,
        ),
      ),
    );
    await tester.pumpAndSettle();
    await tester.pump();
    await tester.pump();

    await tester.tap(find.text(Words.add.tr()));
    await tester.pump();
    await tester.pump();

    expect(api.getDocumentsCallCount, 1);
    expect(find.text('Andijon'), findsOneWidget);
    expect(find.text('Buxoro'), findsNothing);
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
      _LocalizedTestApp(
        home: EghuActionCreatePage(
          actionType: ActionMenuType.detach,
          bloc: bloc,
          consumerSource: source,
          api: api,
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.pump();

    expect(find.text(Words.actionEghuDetach.tr()), findsOneWidget);
    expect(
      tester.widget<ElevatedButton>(find.byType(ElevatedButton)).enabled,
      isTrue,
    );

    expect(api.request, isNull);
  });

  testWidgets('create page renders EGHU labels in Russian locale', (
    tester,
  ) async {
    final bloc = EghuActionCreateBloc(
      actionType: ActionMenuType.reinstall,
      api: _FakeSubmitApi(),
      employeeName: 'Tester',
      initialStampDateTime: DateTime(2026, 5, 28, 17, 38),
    );
    addTearDown(bloc.close);

    await _pumpCreatePage(tester, bloc: bloc, locale: const Locale('ru', 'RU'));

    expect(find.text(Words.actionEghuReinstall.tr()), findsOneWidget);
    expect(find.text(Words.selectConsumer.tr()), findsOneWidget);
    expect(find.text(Words.selectEghu.tr()), findsOneWidget);
    expect(find.text(Words.actInformation.tr()), findsOneWidget);
    expect(find.text(Words.add.tr()), findsWidgets);
  });

  testWidgets('create page pops true after successful submit', (tester) async {
    final api = _FakeSubmitApi();
    final source = _FakeSource();
    final bloc =
        EghuActionCreateBloc(
            actionType: ActionMenuType.reinstall,
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

    bool? result;
    await tester.pumpWidget(
      _LocalizedTestApp(
        home: Builder(
          builder: (context) {
            return TextButton(
              onPressed: () async {
                result = await Navigator.of(context).push<bool>(
                  MaterialPageRoute(
                    builder: (_) => EghuActionCreatePage(
                      actionType: ActionMenuType.reinstall,
                      bloc: bloc,
                      consumerSource: source,
                      api: api,
                    ),
                  ),
                );
              },
              child: const Text('open create'),
            );
          },
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('open create'));
    await tester.pumpAndSettle();
    await tester.tap(find.byType(ElevatedButton));
    await tester.pumpAndSettle();
    await tester.pump(const Duration(seconds: 3));

    expect(result, isTrue);
    expect(api.request, isNotNull);
  });

  testWidgets('stamp section shows current user and date without sublabel', (
    tester,
  ) async {
    final controller = TextEditingController(text: '123');
    addTearDown(controller.dispose);

    await tester.pumpWidget(
      _LocalizedTestApp(
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
    await tester.pumpAndSettle();

    expect(find.text('Current User'), findsOneWidget);
    expect(find.text('Doston Dostonov'), findsNothing);
    expect(find.text('28.05.2026 17:38'), findsOneWidget);
    expect(find.text("Tamg'a sanasi"), findsNothing);
  });

  testWidgets('create page replaces stamp fallback after profile loads', (
    tester,
  ) async {
    final api = _FakeSubmitApi();
    final source = _FakeSource();
    final repository = _FakeAuthRepository(
      profileFuture: Completer<User>(),
      profile: const User(
        id: 1,
        username: 'Current User',
        role: 'inspector',
        employeeId: 91,
        regionId: 8,
        districtId: 23,
      ),
    );
    final loginBloc = LoginBloc(
      LoginUseCase(repository),
      LoadUserProfileUseCase(repository),
      CheckDailyAgreementUseCase(repository),
    );
    addTearDown(loginBloc.close);

    await tester.pumpWidget(
      _LocalizedTestApp(
        home: BlocProvider.value(
          value: loginBloc,
          child: EghuActionCreatePage(
            actionType: ActionMenuType.reinstall,
            consumerSource: source,
            api: api,
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text(Words.fallbackUser.tr()), findsOneWidget);
    expect(find.text('Current User'), findsNothing);

    repository.profileFuture!.complete(repository.profile);
    await tester.pumpAndSettle();

    expect(find.text('Current User'), findsOneWidget);
    expect(find.text(Words.fallbackUser.tr()), findsNothing);
  });

  testWidgets('create header help icon toggles Figma styled tooltip', (
    tester,
  ) async {
    final bloc = EghuActionCreateBloc(
      actionType: ActionMenuType.reinstall,
      api: _FakeSubmitApi(),
      employeeName: 'Tester',
    );
    addTearDown(bloc.close);

    await _pumpCreatePage(tester, bloc: bloc);

    expect(find.byKey(const Key('eghu-create-help-tooltip')), findsNothing);

    await tester.tap(find.byKey(const Key('eghu-create-help-button')));
    await tester.pump();

    expect(find.byKey(const Key('eghu-create-help-tooltip')), findsOneWidget);
    expect(find.text(Words.eghuCreateHelpTooltip.tr()), findsOneWidget);
    expect(
      find.byKey(const Key('eghu-create-help-tooltip-dot')),
      findsOneWidget,
    );

    await tester.tap(find.byKey(const Key('eghu-create-help-button')));
    await tester.pump();

    expect(find.byKey(const Key('eghu-create-help-tooltip')), findsNothing);
  });

  testWidgets(
    'stamp calendar blocks future dates and opens time for past dates',
    (tester) async {
      final today = _dateOnly(DateTime.now());
      final tomorrow = today.add(const Duration(days: 1));
      final yesterday = today.subtract(const Duration(days: 1));
      final bloc = EghuActionCreateBloc(
        actionType: ActionMenuType.reinstall,
        api: _FakeSubmitApi(),
        initialStampDateTime: DateTime(
          today.year,
          today.month,
          today.day,
          9,
          30,
        ),
      );
      addTearDown(bloc.close);

      await _pumpCreatePage(tester, bloc: bloc);

      await tester.tap(find.byKey(const Key('eghu-stamp-date-field')));
      await tester.pumpAndSettle();

      expect(
        find.byKey(const Key('eghu-stamp-calendar-dialog')),
        findsOneWidget,
      );

      final tomorrowFinder = find.byKey(
        Key('eghu-calendar-day-${_dateKey(tomorrow)}'),
      );
      if (tomorrow.month == today.month) {
        expect(tomorrowFinder, findsOneWidget);
        await tester.tap(tomorrowFinder);
        await tester.pump();

        expect(
          find.byKey(const Key('eghu-stamp-calendar-dialog')),
          findsOneWidget,
        );
        expect(find.byKey(const Key('eghu-stamp-time-dialog')), findsNothing);
      } else {
        final nextButton = tester.widget<IconButton>(
          find.descendant(
            of: find.byKey(const Key('eghu-calendar-next-month')),
            matching: find.byType(IconButton),
          ),
        );
        expect(nextButton.onPressed, isNull);
      }

      await tester.tap(
        find.byKey(Key('eghu-calendar-day-${_dateKey(yesterday)}')),
      );
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('eghu-stamp-calendar-dialog')), findsNothing);
      expect(find.byKey(const Key('eghu-stamp-time-dialog')), findsOneWidget);
    },
  );

  testWidgets('stamp picker applies selected past date and time', (
    tester,
  ) async {
    final today = _dateOnly(DateTime.now());
    final yesterday = today.subtract(const Duration(days: 1));
    final bloc = EghuActionCreateBloc(
      actionType: ActionMenuType.reinstall,
      api: _FakeSubmitApi(),
      initialStampDateTime: DateTime(today.year, today.month, today.day, 9, 30),
    );
    addTearDown(bloc.close);

    await _pumpCreatePage(tester, bloc: bloc);

    await tester.tap(find.byKey(const Key('eghu-stamp-date-field')));
    await tester.pumpAndSettle();
    await tester.tap(
      find.byKey(Key('eghu-calendar-day-${_dateKey(yesterday)}')),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('eghu-time-hour-00')));
    await tester.pump();
    await tester.tap(find.byKey(const Key('eghu-time-minute-00')));
    await tester.pump();
    await tester.tap(find.byKey(const Key('eghu-time-confirm')));
    await tester.pumpAndSettle();

    expect(
      find.text(
        '${_twoDigits(yesterday.day)}.${_twoDigits(yesterday.month)}.${yesterday.year} 00:00',
      ),
      findsOneWidget,
    );
    expect(
      bloc.state.stampDateTime,
      DateTime(yesterday.year, yesterday.month, yesterday.day),
    );
  });

  testWidgets('stamp time picker does not allow future time today', (
    tester,
  ) async {
    final now = DateTime.now();
    final today = _dateOnly(now);
    final bloc = EghuActionCreateBloc(
      actionType: ActionMenuType.reinstall,
      api: _FakeSubmitApi(),
      initialStampDateTime: now,
    );
    addTearDown(bloc.close);

    await _pumpCreatePage(tester, bloc: bloc);

    await tester.tap(find.byKey(const Key('eghu-stamp-date-field')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(Key('eghu-calendar-day-${_dateKey(today)}')));
    await tester.pumpAndSettle();

    final selectedTimeLabel = find.byKey(const Key('eghu-selected-time-label'));
    final originalLabel = tester.widget<Text>(selectedTimeLabel).data!;
    final originalParts = originalLabel.split(':');
    final selectedHour = int.parse(originalParts[0]);
    final selectedMinute = int.parse(originalParts[1]);
    expect(find.text(originalLabel), findsOneWidget);

    if (selectedHour < 23) {
      final futureHour = _twoDigits(selectedHour + 1);
      final futureHourFinder = find.byKey(
        Key('eghu-time-hour-$futureHour'),
        skipOffstage: false,
      );
      expect(futureHourFinder, findsOneWidget);
      expect(tester.widget<InkWell>(futureHourFinder).onTap, isNull);
    } else if (selectedMinute < 59) {
      final futureMinute = _twoDigits(selectedMinute + 1);
      final futureMinuteFinder = find.byKey(
        Key('eghu-time-minute-$futureMinute'),
        skipOffstage: false,
      );
      expect(futureMinuteFinder, findsOneWidget);
      expect(tester.widget<InkWell>(futureMinuteFinder).onTap, isNull);
    } else {
      expect(
        find.byKey(
          Key(
            'eghu-calendar-day-${_dateKey(today.add(const Duration(days: 1)))}',
          ),
        ),
        findsNothing,
      );
    }
  });

  testWidgets('consumer sheet supports loading, search, empty, and selection', (
    tester,
  ) async {
    final source = _FakeSource(consumers: [_consumer()]);

    await tester.pumpWidget(
      _LocalizedTestApp(
        home: Scaffold(body: EghuConsumerPickerSheet(source: source)),
      ),
    );
    await tester.pumpAndSettle();

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
      _LocalizedTestApp(
        home: Scaffold(
          body: EghuConsumerPickerSheet(source: _FakeSource(consumers: [])),
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.pumpAndSettle();

    expect(find.text(Words.noInformationFound.tr()), findsOneWidget);
  });

  testWidgets('consumer sheet shows error with retry action', (tester) async {
    await tester.pumpWidget(
      _LocalizedTestApp(
        home: Scaffold(
          body: EghuConsumerPickerSheet(
            source: _FakeSource(error: Exception('Network error')),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.pumpAndSettle();

    expect(find.text('Network error'), findsOneWidget);
    expect(find.text(Words.retry.tr()), findsOneWidget);
  });

  testWidgets('EGHU sheet loads detail and selects an item', (tester) async {
    await tester.pumpWidget(
      _LocalizedTestApp(
        home: Scaffold(
          body: EghuDevicePickerSheet(
            source: _FakeSource(egxus: [_eghu()]),
            consumer: _consumer(),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.pumpAndSettle();

    expect(find.textContaining('EGHU ID:', findRichText: true), findsOneWidget);
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
      _LocalizedTestApp(
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
    await tester.pumpAndSettle();

    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
    expect(find.text(Words.openCamera.tr()), findsOneWidget);
    expect(find.text(Words.uploadFromPhone.tr()), findsOneWidget);
    await tester.tap(find.text(Words.uploadFromPhone.tr()));
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
      _LocalizedTestApp(
        home: StatefulBuilder(
          builder: (context, setState) {
            return Scaffold(
              body: EghuUploadSection(
                slot: EghuActionAttachmentSlot.act,
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
    await tester.pumpAndSettle();

    final imagePreview = find.byKey(const Key('eghu-upload-image-preview'));
    final infoPanel = find.byKey(const Key('eghu-upload-info-act'));

    expect(imagePreview, findsOneWidget);
    expect(infoPanel, findsNothing);

    await tester.tap(find.byKey(const Key('eghu-upload-help-act')));
    await tester.pump();

    expect(imagePreview, findsOneWidget);
    expect(infoPanel, findsOneWidget);
    expect(find.byKey(const Key('eghu-upload-info-dot')), findsOneWidget);
    expect(
      tester.getTopLeft(infoPanel).dy,
      greaterThanOrEqualTo(tester.getTopLeft(imagePreview).dy),
    );
    expect(
      tester.getTopLeft(infoPanel).dy,
      lessThan(tester.getBottomRight(imagePreview).dy),
    );

    await tester.tap(find.byKey(const Key('eghu-upload-remove-button')));
    await tester.pump();

    expect(infoPanel, findsNothing);
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
        _LocalizedTestApp(
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
      await tester.pumpAndSettle();

      expect(find.byKey(Key('eghu-upload-help-${slot.name}')), findsOneWidget);
      expect(find.byType(AlertDialog), findsNothing);
      expect(find.byKey(Key('eghu-upload-info-${slot.name}')), findsNothing);
      expect(find.byKey(const Key('eghu-upload-info-dot')), findsNothing);

      await tester.tap(find.byKey(Key('eghu-upload-help-${slot.name}')));
      await tester.pump();

      final infoPanel = find.byKey(Key('eghu-upload-info-${slot.name}'));
      final filePreview = find.byKey(const Key('eghu-upload-file-preview'));

      expect(find.byType(AlertDialog), findsNothing);
      expect(filePreview, findsOneWidget);
      expect(infoPanel, findsOneWidget);
      expect(find.byKey(const Key('eghu-upload-info-dot')), findsOneWidget);
      expect(
        tester.getTopLeft(infoPanel).dy,
        tester.getTopLeft(filePreview).dy,
      );
      expect(
        find.textContaining(
          '${Words.uploadedBy.tr()}: Current User',
          findRichText: true,
        ),
        findsOneWidget,
      );
      expect(
        find.textContaining(
          '${Words.fileDate.tr()}: 28.05.2026 09:00',
          findRichText: true,
        ),
        findsOneWidget,
      );
      expect(
        find.textContaining(
          '${Words.fileSizeLabel.tr()}: 0.1 KB',
          findRichText: true,
        ),
        findsOneWidget,
      );

      await tester.tap(find.byKey(const Key('eghu-upload-file-remove-button')));
      await tester.pump();

      expect(infoPanel, findsNothing);
      expect(find.byKey(const Key('eghu-upload-info-dot')), findsNothing);
      expect(find.byKey(const Key('eghu-upload-drop-zone')), findsOneWidget);
    }
  });
}

class _LocalizedTestApp extends StatelessWidget {
  const _LocalizedTestApp({
    required this.home,
    this.locale = const Locale('uz', 'UZ'),
  });

  final Widget home;
  final Locale locale;

  @override
  Widget build(BuildContext context) {
    return EasyLocalization(
      key: UniqueKey(),
      supportedLocales: const [
        Locale('uz', 'UZ'),
        Locale('uz', 'Cyrl'),
        Locale('ru', 'RU'),
      ],
      path: 'assets/tr',
      fallbackLocale: const Locale('uz', 'UZ'),
      startLocale: locale,
      saveLocale: false,
      assetLoader: const _FileAssetLoader(),
      child: Builder(
        builder: (context) {
          return MaterialApp(
            key: UniqueKey(),
            localizationsDelegates: context.localizationDelegates,
            supportedLocales: context.supportedLocales,
            locale: context.locale,
            home: home,
          );
        },
      ),
    );
  }
}

class _FileAssetLoader extends AssetLoader {
  const _FileAssetLoader();

  @override
  Future<Map<String, dynamic>?> load(String path, Locale locale) async {
    final localePath =
        '$path/${locale.toStringWithSeparator(separator: '-')}.json';
    return jsonDecode(File(localePath).readAsStringSync())
        as Map<String, dynamic>;
  }
}

Future<void> _pumpCreatePage(
  WidgetTester tester, {
  required EghuActionCreateBloc bloc,
  Locale locale = const Locale('uz', 'UZ'),
}) async {
  await tester.pumpWidget(
    _LocalizedTestApp(
      locale: locale,
      home: EghuActionCreatePage(
        actionType: ActionMenuType.reinstall,
        bloc: bloc,
        consumerSource: _FakeSource(),
        api: _FakeSubmitApi(),
      ),
    ),
  );
  await tester.pumpAndSettle();
  await tester.pump();
}

DateTime _dateOnly(DateTime value) =>
    DateTime(value.year, value.month, value.day);

String _dateKey(DateTime day) =>
    '${day.year}-${_twoDigits(day.month)}-${_twoDigits(day.day)}';

String _twoDigits(int value) => value.toString().padLeft(2, '0');

class _FakeSubmitApi implements EghuActionSubmitApi {
  EghuActionCreateRequest? request;

  @override
  Future<void> create(EghuActionCreateRequest request) async {
    this.request = request;
  }
}

class _FakeListApi implements EghuActionListApi {
  _FakeListApi(
    PaginatedResponse<EghuWorkingDocument> response, {
    List<PaginatedResponse<EghuWorkingDocument>> additionalResponses = const [],
  }) : _responses = [response, ...additionalResponses];

  final List<PaginatedResponse<EghuWorkingDocument>> _responses;
  int getDocumentsCallCount = 0;

  @override
  Future<PaginatedResponse<EghuWorkingDocument>> getDocuments({
    int limit = 10,
    int offset = 0,
    ActionMenuType? actionType,
  }) async {
    final responseIndex = getDocumentsCallCount < _responses.length
        ? getDocumentsCallCount
        : _responses.length - 1;
    getDocumentsCallCount++;
    return _responses[responseIndex];
  }

  @override
  Future<PaginatedResponse<EghuWorkingDocument>> getNextPage(String url) async {
    return _responses.last;
  }
}

class _FakeAuthRepository implements AuthRepository {
  const _FakeAuthRepository({required this.profile, this.profileFuture});

  final User profile;
  final Completer<User>? profileFuture;

  @override
  Future<Either<Failure, AuthToken>> login({
    required String userName,
    required String password,
  }) async {
    return const Right(AuthToken(access: 'access', refresh: 'refresh'));
  }

  @override
  Future<Either<Failure, User>> loadProfile() async {
    return Right(await (profileFuture?.future ?? Future.value(profile)));
  }

  @override
  Future<Either<Failure, Unit>> logout() async {
    return const Right(unit);
  }

  @override
  Future<Either<Failure, bool>> requiresDailyAgreement() async {
    return const Right(false);
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
    consumerRelationEgxu: ConsumerRelationEgxu(typeOfActivityId: 110),
    oneFactory: 'Zavod 1',
    twoFactory: 'Zavod 2',
  );
}

PaginatedResponse<EghuWorkingDocument> _listResponse(
  List<EghuWorkingDocument> documents,
) {
  return PaginatedResponse(
    count: documents.length,
    next: null,
    previous: null,
    results: documents,
  );
}

EghuWorkingDocument _workingDocument({
  required int id,
  required String region,
  required String district,
}) {
  return EghuWorkingDocument(
    id: id,
    datetime: DateTime(2026, 5, 28, 10),
    region: region,
    district: district,
    typeOfActivity: 'Sanoat',
    documentType: 'consumer',
    documentTypeDisplay: "Iste'molchi",
    employee: 'Tester',
    isActive: true,
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
