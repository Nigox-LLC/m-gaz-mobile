import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:m_gaz/core/common/words.dart';

void main() {
  test('translation files contain every Words key', () {
    final expectedKeys = Words.values.map((word) => word.name).toSet();

    for (final path in const [
      'assets/tr/uz-UZ.json',
      'assets/tr/uz-Cyrl.json',
      'assets/tr/ru-RU.json',
    ]) {
      final content = File(path).readAsStringSync();
      final translations = jsonDecode(content) as Map<String, dynamic>;
      final missingKeys = expectedKeys.difference(translations.keys.toSet());

      expect(
        missingKeys,
        isEmpty,
        reason: '$path is missing localization keys',
      );
    }
  });
}
