import 'dart:convert';
import 'dart:io';

import 'package:dartz/dartz.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:m_gaz/app/injection.dart';
import 'package:m_gaz/core/error/failures.dart';
import 'package:m_gaz/features/auth/domain/entities/auth_token.dart';
import 'package:m_gaz/features/auth/domain/entities/user.dart';
import 'package:m_gaz/features/auth/domain/repositories/auth_repository.dart';
import 'package:m_gaz/features/auth/domain/usecases/check_daily_agreement_usecase.dart';
import 'package:m_gaz/features/auth/domain/usecases/get_saved_username_usecase.dart';
import 'package:m_gaz/features/auth/domain/usecases/load_user_profile_usecase.dart';
import 'package:m_gaz/features/auth/domain/usecases/login_usecase.dart';
import 'package:m_gaz/features/auth/presentation/bloc/login_bloc.dart';
import 'package:m_gaz/features/auth/presentation/pages/login_screen.dart';
import 'package:m_gaz/features/auth/presentation/widgets/login_button.dart';
import 'package:m_gaz/features/auth/presentation/widgets/login_text_field.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    SharedPreferences.setMockInitialValues({});
    await EasyLocalization.ensureInitialized();
    EasyLocalization.logger.enableLevels = [];
  });

  Widget wrap(Widget child) {
    return MaterialApp(
      home: Scaffold(body: Center(child: child)),
    );
  }

  group('LoginScreen localization', () {
    testWidgets('renders Uzbek labels instead of localization keys', (
      tester,
    ) async {
      await _pumpLoginScreen(tester);

      expect(find.text('Kirish'), findsWidgets);
      expect(find.text('Foydalanuvchi nomi'), findsOneWidget);
      expect(find.text('Login'), findsOneWidget);
      expect(find.text('Parolingizni kiriting'), findsOneWidget);
      expect(find.text('Parol'), findsOneWidget);

      expect(find.text('loginTitle'), findsNothing);
      expect(find.text('loginUsernameLabel'), findsNothing);
      expect(find.text('loginUsernameHint'), findsNothing);
      expect(find.text('loginPasswordLabel'), findsNothing);
      expect(find.text('loginPasswordHint'), findsNothing);
      expect(find.text('loginSubmit'), findsNothing);
    });

    test('contains login translations for every supported locale', () {
      expect(_translations('uz-UZ.json'), containsPair('loginTitle', 'Kirish'));
      expect(
        _translations('uz-Cyrl.json'),
        containsPair('loginTitle', 'Кириш'),
      );
      expect(_translations('ru-RU.json'), containsPair('loginTitle', 'Вход'));

      for (final localeFile in ['uz-UZ.json', 'uz-Cyrl.json', 'ru-RU.json']) {
        final values = _translations(localeFile);
        for (final key in _loginTranslationKeys) {
          expect(values[key], isA<String>());
          expect((values[key] as String).trim(), isNotEmpty);
          expect(values[key], isNot(key));
        }
      }
    });
  });

  group('LoginButton', () {
    testWidgets('does not call onPressed when disabled', (tester) async {
      var taps = 0;

      await tester.pumpWidget(
        wrap(
          LoginButton(
            title: 'Kirish',
            isEnabled: false,
            isLoading: false,
            onPressed: () => taps++,
          ),
        ),
      );

      await tester.tap(find.byType(LoginButton));
      await tester.pump();

      expect(taps, 0);
      expect(find.text('Kirish'), findsOneWidget);
    });

    testWidgets('calls onPressed when enabled', (tester) async {
      var taps = 0;

      await tester.pumpWidget(
        wrap(
          LoginButton(
            title: 'Kirish',
            isEnabled: true,
            isLoading: false,
            onPressed: () => taps++,
          ),
        ),
      );

      await tester.tap(find.byType(LoginButton));
      await tester.pump();

      expect(taps, 1);
    });

    testWidgets('shows loading indicator and blocks taps', (tester) async {
      var taps = 0;

      await tester.pumpWidget(
        wrap(
          LoginButton(
            title: 'Kirish',
            isEnabled: true,
            isLoading: true,
            onPressed: () => taps++,
          ),
        ),
      );

      await tester.tap(find.byType(LoginButton));
      await tester.pump();

      expect(taps, 0);
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });
  });

  group('LoginTextField', () {
    testWidgets('shows error text and clear action', (tester) async {
      final controller = TextEditingController(text: 'Admin');
      addTearDown(controller.dispose);

      await tester.pumpWidget(
        wrap(
          SizedBox(
            width: 350,
            child: LoginTextField(
              controller: controller,
              label: 'Foydalanuvchi nomi',
              hintText: 'Login',
              hasError: true,
              errorText: 'Login yoki parol xato',
              onClear: controller.clear,
            ),
          ),
        ),
      );

      expect(find.text('Foydalanuvchi nomi'), findsOneWidget);
      expect(find.text('Login yoki parol xato'), findsOneWidget);
      expect(find.byIcon(Icons.close), findsOneWidget);

      await tester.tap(find.byIcon(Icons.close));
      await tester.pump();

      expect(controller.text, isEmpty);
    });
  });
}

Future<void> _pumpLoginScreen(WidgetTester tester) async {
  final repository = _FakeAuthRepository();

  // LoginScreen storage'dan username'ni getIt orqali to'g'ridan-to'g'ri o'qiydi.
  if (getIt.isRegistered<GetSavedUsernameUseCase>()) {
    getIt.unregister<GetSavedUsernameUseCase>();
  }
  getIt.registerFactory<GetSavedUsernameUseCase>(
    () => GetSavedUsernameUseCase(repository),
  );
  addTearDown(() {
    if (getIt.isRegistered<GetSavedUsernameUseCase>()) {
      getIt.unregister<GetSavedUsernameUseCase>();
    }
  });

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
            home: BlocProvider(
              create: (_) => LoginBloc(
                LoginUseCase(repository),
                LoadUserProfileUseCase(repository),
                CheckDailyAgreementUseCase(repository),
                GetSavedUsernameUseCase(repository),
              ),
              child: const LoginScreen(),
            ),
          );
        },
      ),
    ),
  );
  await tester.pumpAndSettle();
}

Map<String, Object?> _translations(String fileName) {
  final file = File('assets/tr/$fileName');
  return jsonDecode(file.readAsStringSync()) as Map<String, Object?>;
}

const _loginTranslationKeys = [
  'loginTitle',
  'loginUsernameLabel',
  'loginUsernameHint',
  'loginPasswordLabel',
  'loginPasswordHint',
  'loginSubmit',
];

class _FakeAuthRepository implements AuthRepository {
  @override
  Future<Either<Failure, AuthToken>> login({
    required String userName,
    required String password,
  }) async {
    return const Right(AuthToken(access: 'access', refresh: 'refresh'));
  }

  @override
  Future<Either<Failure, User>> loadProfile() async {
    return const Right(User(id: 1, username: 'tester', role: 'tester'));
  }

  @override
  Future<Either<Failure, Unit>> logout() async {
    return const Right(unit);
  }

  @override
  Future<Either<Failure, bool>> requiresDailyAgreement() async {
    return const Right(false);
  }

  @override
  Future<Either<Failure, String>> getSavedUsername() async {
    return const Right('');
  }
}
