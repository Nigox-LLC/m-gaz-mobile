import 'package:camera/camera.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
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

    await _pumpLocalized(tester, const CameraScreen());

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
}) {
  return Face(
    boundingBox: rect,
    landmarks: const <FaceLandmarkType, FaceLandmark?>{},
    contours: const <FaceContourType, FaceContour?>{},
    leftEyeOpenProbability: leftEye,
    rightEyeOpenProbability: rightEye,
  );
}
