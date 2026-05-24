import 'dart:io';

import 'package:easy_localization/easy_localization.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:geolocator/geolocator.dart';
import 'package:m_gaz/core/models/task/tasks_model.dart';
import 'package:m_gaz/ui/home/tasks/widgets/task_action_modal.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    SharedPreferences.setMockInitialValues({});
    await EasyLocalization.ensureInitialized();
    EasyLocalization.logger.enableLevels = [];
  });

  testWidgets('task action modal covers required file and no-file states', (
    tester,
  ) async {
    var completedCount = 0;
    var canceledCount = 0;
    String? cancelDescription;
    String? cancelFilePath;
    final file = File(
      '${Directory.systemTemp.path}/task-cancel-proof-${DateTime.now().microsecondsSinceEpoch}.pdf',
    )..writeAsBytesSync(List<int>.filled(64, 1));
    FilePicker.platform = _FakeFilePicker(file.path);
    addTearDown(() {
      if (file.existsSync()) file.deleteSync();
    });

    await _pumpTaskActionModal(
      tester,
      task: _task(isAnswerFile: true),
      locationProvider: () async => _position(),
      locationAddressResolver: (_) async =>
          "Farg'ona viloyati, Qo'shtepa tumani, Qizilariq",
      onComplete: ({required taskId, filePath, latitude, longitude}) {
        completedCount++;
      },
      onCancelTask:
          ({required taskId, required description, required filePath}) {
            canceledCount++;
            cancelDescription = description;
            cancelFilePath = filePath;
          },
    );

    expect(find.byKey(const Key('task-action-modal')), findsOneWidget);
    expect(find.byKey(const Key('task-location-section')), findsOneWidget);
    expect(find.byKey(const Key('task-upload-basis-tile')), findsNothing);

    await tester.tap(find.byKey(const Key('task-location-pick-button')));
    await tester.pumpAndSettle();

    expect(
      find.byKey(const Key('task-location-address-field')),
      findsOneWidget,
    );
    await tester.tap(find.byKey(const Key('task-location-confirm-button')));
    await tester.pumpAndSettle();

    expect(
      find.text("Farg'ona viloyati, Qo'shtepa tumani, Qizilariq"),
      findsOneWidget,
    );
    expect(find.textContaining('41.326500'), findsNothing);

    await tester.tap(find.byKey(const Key('task-done-button')));
    await tester.pumpAndSettle();

    expect(completedCount, 0);
    expect(find.byKey(const Key('task-attachment-dialog')), findsOneWidget);
    expect(find.byKey(const Key('task-upload-basis-tile')), findsOneWidget);

    await tester.tap(find.byKey(const Key('task-dialog-back-button')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('task-cancel-todo-button')));
    await tester.pumpAndSettle();

    expect(completedCount, 0);
    expect(find.byKey(const Key('task-cancel-dialog')), findsOneWidget);
    expect(find.text('Bekor qilishda avval asos yuboring!'), findsOneWidget);
    expect(
      find.text('Iltimos, bekor qilish sababni yozing. Bu majburiy'),
      findsOneWidget,
    );

    await tester.tap(find.byKey(const Key('task-cancel-confirm-button')));
    await tester.pumpAndSettle();
    expect(canceledCount, 0);

    await tester.enterText(
      find.byKey(const Key('task-cancel-reason-field')),
      'Test sabab',
    );
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('task-cancel-confirm-button')));
    await tester.pumpAndSettle();
    expect(canceledCount, 0);

    await tester.tap(find.byKey(const Key('task-upload-basis-tile')));
    await tester.pumpAndSettle();
    expect(find.text('Telefondan yuklash'), findsOneWidget);
    expect(find.text('fayl nomi'), findsNothing);
    expect(find.byType(LinearProgressIndicator), findsNothing);
    await tester.tap(find.text('Telefondan yuklash'));
    await tester.pumpAndSettle();

    expect(
      find.byKey(const Key('task-attachment-preview-tile')),
      findsOneWidget,
    );

    await tester.tap(find.byKey(const Key('task-attachment-remove-button')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('task-cancel-confirm-button')));
    await tester.pumpAndSettle();
    expect(canceledCount, 0);

    await tester.tap(find.byKey(const Key('task-upload-basis-tile')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Telefondan yuklash'));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('task-cancel-confirm-button')));
    await tester.pumpAndSettle();

    expect(canceledCount, 1);
    expect(cancelDescription, 'Test sabab');
    expect(cancelFilePath, file.path);

    await tester.tap(find.byKey(const Key('task-cancel-dialog-back-button')));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('task-action-modal')), findsOneWidget);

    await _pumpTaskActionModal(
      tester,
      task: _task(isAnswerFile: false),
      onComplete: ({required taskId, filePath, latitude, longitude}) {
        completedCount++;
      },
    );

    expect(find.text('Vazifa harakati'), findsOneWidget);
    expect(find.text('Vazifa holati'), findsOneWidget);
    expect(find.text('Vazifa turi'), findsOneWidget);
    expect(find.text('Izoh'), findsOneWidget);
    expect(find.byKey(const Key('task-location-section')), findsNothing);

    await tester.tap(find.byKey(const Key('task-done-button')));
    await tester.pumpAndSettle();

    expect(completedCount, 1);
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pumpAndSettle();
  });
}

Future<void> _pumpTaskActionModal(
  WidgetTester tester, {
  required TaskModel task,
  required TaskCompletionCallback onComplete,
  TaskCancelCallback? onCancelTask,
  Future<Position?> Function()? locationProvider,
  TaskLocationAddressResolver? locationAddressResolver,
}) async {
  await tester.pumpWidget(
    EasyLocalization(
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
              body: TaskActionModal(
                task: task,
                onComplete: onComplete,
                onCancelTask: onCancelTask,
                locationProvider: locationProvider,
                locationAddressResolver: locationAddressResolver,
              ),
            ),
          );
        },
      ),
    ),
  );
  await tester.pumpAndSettle();
}

Position _position() {
  return Position(
    latitude: 41.3265,
    longitude: 69.2288,
    timestamp: DateTime(2026, 5, 24, 10),
    accuracy: 5,
    altitude: 0,
    altitudeAccuracy: 0,
    heading: 0,
    headingAccuracy: 0,
    speed: 0,
    speedAccuracy: 0,
  );
}

class _FakeFilePicker extends FilePicker {
  final String path;

  _FakeFilePicker(this.path);

  @override
  Future<FilePickerResult?> pickFiles({
    String? dialogTitle,
    String? initialDirectory,
    FileType type = FileType.any,
    List<String>? allowedExtensions,
    Function(FilePickerStatus)? onFileLoading,
    bool allowCompression = true,
    int compressionQuality = 30,
    bool allowMultiple = false,
    bool withData = false,
    bool withReadStream = false,
    bool lockParentWindow = false,
    bool readSequential = false,
  }) async {
    return FilePickerResult([
      PlatformFile(
        path: path,
        name: path.split(Platform.pathSeparator).last,
        size: 64,
      ),
    ]);
  }
}

TaskModel _task({required bool isAnswerFile}) {
  return TaskModel(
    id: 7,
    employee: 'Mark Leonidov',
    typeTask: isAnswerFile
        ? 'Joylashuv aniqlash'
        : "Sertifikat muddati o'tib ketgan",
    status: 'Yangi',
    situation: "O'rta",
    description:
        "CRM tizimida yangi “Hisobotlar” bo‘limini qo‘shish. Admin barcha ma’lumotlarni ko‘ra olishi kerak.",
    deadline: DateTime(2026, 5, 25, 20, 32),
    doneDate: null,
    approvedDate: null,
    canceledDate: null,
    created: DateTime(2026, 5, 24, 10),
    isDone: false,
    isApproved: false,
    isCanceled: false,
    isAnswerFile: isAnswerFile,
    consumerDocument: null,
  );
}
