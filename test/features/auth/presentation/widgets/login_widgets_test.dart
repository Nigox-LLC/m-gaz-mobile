import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:m_gaz/features/auth/presentation/widgets/login_button.dart';
import 'package:m_gaz/features/auth/presentation/widgets/login_text_field.dart';

void main() {
  Widget wrap(Widget child) {
    return MaterialApp(
      home: Scaffold(body: Center(child: child)),
    );
  }

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
