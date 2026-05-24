import 'package:flutter_test/flutter_test.dart';
import 'package:m_gaz/core/utils/app_date_formatter.dart';

void main() {
  group('AppDateFormatter', () {
    final value = DateTime(2026, 5, 23, 9, 7, 5);

    test('formats date only as dd.MM.yyyy', () {
      expect(AppDateFormatter.date(value), '23.05.2026');
    });

    test('formats time only as HH:mm:ss', () {
      expect(AppDateFormatter.time(value), '09:07:05');
    });

    test('formats date and time as dd.MM.yyyy HH:mm:ss', () {
      expect(AppDateFormatter.dateTime(value), '23.05.2026 09:07:05');
    });

    test('returns fallback for null values', () {
      expect(AppDateFormatter.date(null), '-');
      expect(AppDateFormatter.time(null), '-');
      expect(AppDateFormatter.dateTime(null), '-');
      expect(AppDateFormatter.date(null, fallback: 'unknown'), 'unknown');
    });

    test('parses ISO strings and formats them', () {
      const rawValue = '2026-05-23T09:07:05';

      expect(AppDateFormatter.dateFromString(rawValue), '23.05.2026');
      expect(
        AppDateFormatter.dateTimeFromString(rawValue),
        '23.05.2026 09:07:05',
      );
    });

    test('parses backend date-only strings and formats them', () {
      expect(AppDateFormatter.dateFromString('2026-01-02'), '02.01.2026');
    });

    test('parses display date and datetime strings', () {
      expect(AppDateFormatter.parseDate('23.05.2026'), DateTime(2026, 5, 23));
      expect(
        AppDateFormatter.parseDateTime('23.05.2026 09:07:05'),
        DateTime(2026, 5, 23, 9, 7, 5),
      );
    });

    test('returns fallback for empty and invalid strings', () {
      expect(AppDateFormatter.dateFromString(''), '-');
      expect(AppDateFormatter.dateTimeFromString('not-a-date'), '-');
      expect(
        AppDateFormatter.dateFromString('not-a-date', fallback: 'unknown'),
        'unknown',
      );
    });
  });
}
