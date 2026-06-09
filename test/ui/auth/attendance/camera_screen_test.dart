import 'dart:io';

import 'package:camera/camera.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import 'package:m_gaz/core/api/attendance/attendance_api.dart';
import 'package:m_gaz/ui/auth/attendance/bloc/attendance_bloc.dart';
import 'package:m_gaz/ui/auth/attendance/camera_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    SharedPreferences.setMockInitialValues({});
    await EasyLocalization.ensureInitialized();
    EasyLocalization.logger.enableLevels = [];
    GoogleFonts.config.allowRuntimeFetching = false;
  });

  group('attendance face detection helpers', () {
    test('calculates Android camera rotation compensation', () {
      expect(
        attendanceRotationCompensation(
          sensorOrientation: 90,
          deviceOrientation: DeviceOrientation.portraitUp,
          lensDirection: CameraLensDirection.front,
          isAndroid: true,
          isIOS: false,
        ),
        90,
      );
      expect(
        attendanceRotationCompensation(
          sensorOrientation: 90,
          deviceOrientation: DeviceOrientation.landscapeLeft,
          lensDirection: CameraLensDirection.front,
          isAndroid: true,
          isIOS: false,
        ),
        180,
      );
      expect(
        attendanceRotationCompensation(
          sensorOrientation: 90,
          deviceOrientation: DeviceOrientation.landscapeLeft,
          lensDirection: CameraLensDirection.back,
          isAndroid: true,
          isIOS: false,
        ),
        0,
      );
      expect(
        attendanceRotationCompensation(
          sensorOrientation: 90,
          deviceOrientation: DeviceOrientation.portraitUp,
          lensDirection: CameraLensDirection.front,
          isAndroid: false,
          isIOS: false,
        ),
        isNull,
      );
    });

    test('validates largest face and open eyes', () {
      final smallFace = _face(
        rect: const Rect.fromLTWH(0, 0, 20, 20),
        leftEye: 0.91,
        rightEye: 0.92,
      );
      final largeFace = _face(
        rect: const Rect.fromLTWH(0, 0, 40, 40),
        leftEye: 0.91,
        rightEye: 0.92,
      );

      expect(attendanceLargestFace(const []), isNull);
      expect(attendanceLargestFace([smallFace, largeFace]), same(largeFace));
      expect(attendanceHasOpenEyes(_face()), isFalse);
      expect(
        attendanceHasOpenEyes(_face(leftEye: 0.91, rightEye: 0.2)),
        isFalse,
      );
      expect(
        attendanceHasOpenEyes(_face(leftEye: 0.81, rightEye: 0.82)),
        isTrue,
      );
    });

    test('validates face centered via head euler angles', () {
      expect(attendanceFaceCentered(_face(yaw: 5, pitch: 5)), isTrue);
      expect(attendanceFaceCentered(_face(yaw: 30, pitch: 0)), isFalse);
      expect(attendanceFaceCentered(_face(yaw: 0, pitch: 25)), isFalse);
      // Burchaklar aniqlanmagan (null) — markazda emas.
      expect(attendanceFaceCentered(_face()), isFalse);
    });

    test('validates full face fills enough of the frame', () {
      const imageSize = Size(100, 100);
      // 40x40 = 0.16 ratio >= 0.10 → yetarli.
      expect(
        attendanceFaceLargeEnough(
          const Rect.fromLTWH(0, 0, 40, 40),
          imageSize,
        ),
        isTrue,
      );
      // 20x20 = 0.04 ratio < 0.10 → juda uzoq.
      expect(
        attendanceFaceLargeEnough(
          const Rect.fromLTWH(0, 0, 20, 20),
          imageSize,
        ),
        isFalse,
      );
    });

    test('computes average luminance and brightness balance', () {
      expect(attendanceAverageLuminance(const [0, 100, 200]), 100);
      expect(attendanceAverageLuminance(const []), 0);
      expect(attendanceBrightnessBalanced(120), isTrue);
      expect(attendanceBrightnessBalanced(30), isFalse); // juda qorong'i
      expect(attendanceBrightnessBalanced(230), isFalse); // juda yorug'
    });

    test('detects blur via laplacian variance', () {
      // Tekis (bir xil) to'r — qirralar yo'q → variansiya 0 → xira.
      final flat = List<int>.filled(16, 128);
      expect(attendanceLaplacianVariance(flat, 4, 4), 0);
      expect(attendanceSharpEnough(attendanceLaplacianVariance(flat, 4, 4)),
          isFalse);

      // Shахmat naqshi — keskin qirralar → yuqori variansiya → aniq.
      final checker = <int>[
        for (var y = 0; y < 4; y++)
          for (var x = 0; x < 4; x++) (x + y).isEven ? 0 : 255,
      ];
      expect(attendanceLaplacianVariance(checker, 4, 4), greaterThan(8.0));
      expect(
        attendanceSharpEnough(attendanceLaplacianVariance(checker, 4, 4)),
        isTrue,
      );
    });

    test('stability tracker requires 2s continuous same-face validity', () {
      final tracker = AttendanceStabilityTracker(
        holdDuration: const Duration(seconds: 2),
      );
      final t0 = DateTime(2026, 1, 1, 12, 0, 0);

      // Birinchi valid kadr — taymer boshlanadi, hali tayyor emas.
      expect(tracker.update(valid: true, trackingId: 1, now: t0), isFalse);
      // 1.9s — hali yetmadi.
      expect(
        tracker.update(
          valid: true,
          trackingId: 1,
          now: t0.add(const Duration(milliseconds: 1900)),
        ),
        isFalse,
      );
      // 2.0s — tayyor.
      expect(
        tracker.update(
          valid: true,
          trackingId: 1,
          now: t0.add(const Duration(seconds: 2)),
        ),
        isTrue,
      );
    });

    test('stability tracker resets on invalid frame or trackingId change', () {
      final tracker = AttendanceStabilityTracker();
      final t0 = DateTime(2026, 1, 1, 12, 0, 0);

      tracker.update(valid: true, trackingId: 1, now: t0);
      // Invalid kadr — taymer nolga qaytadi.
      expect(
        tracker.update(
          valid: false,
          trackingId: 1,
          now: t0.add(const Duration(seconds: 1)),
        ),
        isFalse,
      );
      // Qaytadan valid, lekin 2s qaytadan boshlandi.
      tracker.update(valid: true, trackingId: 1, now: t0.add(const Duration(seconds: 1)));
      // Boshqa yuz (trackingId o'zgardi) — taymer qayta boshlanadi.
      expect(
        tracker.update(
          valid: true,
          trackingId: 2,
          now: t0.add(const Duration(seconds: 3)),
        ),
        isFalse,
      );
      expect(
        tracker.update(
          valid: true,
          trackingId: 2,
          now: t0.add(const Duration(seconds: 5)),
        ),
        isTrue,
      );
    });
  });

  testWidgets('camera redesign renders intro and scanner status states', (
    tester,
  ) async {
    await _pumpLocalized(
      tester,
      const ColoredBox(
        color: Colors.black,
        child: Center(child: AttendanceScannerStatusBadge(isValidFace: false)),
      ),
    );

    expect(find.text('Yuz topilmadi'), findsOneWidget);
    expect(find.byIcon(Icons.cancel_outlined), findsOneWidget);

    await _pumpLocalized(
      tester,
      const ColoredBox(
        color: Colors.black,
        child: Center(child: AttendanceScannerStatusBadge(isValidFace: true)),
      ),
    );

    expect(find.text('Tasdiqlandi'), findsOneWidget);
    expect(find.byIcon(Icons.check_circle_outline), findsOneWidget);

    await _pumpLocalized(
      tester,
      BlocProvider<AttendanceBloc>(
        create: (_) => AttendanceBloc(api: _FakeAttendanceApi()),
        child: const CameraScreen(),
      ),
    );

    expect(find.byKey(const Key('attendance-intro-title')), findsOneWidget);
    expect(find.text('Haqiqiy yuzni aniqlash'), findsOneWidget);
    expect(
      find.text('Shaxsingizni tasdiqlash uchun yuzingizni skanerlang.'),
      findsOneWidget,
    );
    expect(find.text('Ochiq yuz'), findsOneWidget);
    expect(find.text('Yaxshi yoritish'), findsOneWidget);
    expect(find.byKey(const Key('attendance-intro-start')), findsOneWidget);
    expect(find.byType(CircularProgressIndicator), findsNothing);
  });
}

Future<void> _pumpLocalized(WidgetTester tester, Widget child) async {
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
            home: Scaffold(body: child),
          );
        },
      ),
    ),
  );
  await tester.pumpAndSettle();
}

Face _face({
  Rect rect = const Rect.fromLTWH(0, 0, 20, 20),
  double? leftEye,
  double? rightEye,
  double? yaw,
  double? pitch,
  int? trackingId,
}) {
  return Face(
    boundingBox: rect,
    landmarks: const <FaceLandmarkType, FaceLandmark?>{},
    contours: const <FaceContourType, FaceContour?>{},
    leftEyeOpenProbability: leftEye,
    rightEyeOpenProbability: rightEye,
    headEulerAngleY: yaw,
    headEulerAngleX: pitch,
    trackingId: trackingId,
  );
}

class _FakeAttendanceApi implements AttendanceApi {
  @override
  Future<bool> checkAlreadyAttended() async => false;

  @override
  Future<Map<String, dynamic>> sendAttendance({
    required File photo,
    Map<String, dynamic>? data,
  }) async => <String, dynamic>{};

  @override
  noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}
