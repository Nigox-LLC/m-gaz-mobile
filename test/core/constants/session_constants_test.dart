import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:m_gaz/core/constants/session_constants.dart';

void main() {
  test('session timeout is 30 seconds', () {
    expect(kSessionTimeout, const Duration(seconds: 30));
  });

  group('isAppBackgrounded', () {
    test('only paused counts as backgrounded', () {
      expect(isAppBackgrounded(AppLifecycleState.paused), isTrue);
    });

    test('hidden is NOT backgrounded (fires on resume too)', () {
      // Regression guard: `hidden` yuborilganda sessiya vaqtini yangilash 30s
      // timeout'ni buzgan edi (Home tugmasi yo'li doim `hidden` orqali o'tadi).
      expect(isAppBackgrounded(AppLifecycleState.hidden), isFalse);
    });

    test('inactive / resumed / detached are not backgrounded', () {
      expect(isAppBackgrounded(AppLifecycleState.inactive), isFalse);
      expect(isAppBackgrounded(AppLifecycleState.resumed), isFalse);
      expect(isAppBackgrounded(AppLifecycleState.detached), isFalse);
    });
  });
}
