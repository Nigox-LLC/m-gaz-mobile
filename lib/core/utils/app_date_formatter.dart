import 'package:intl/intl.dart';

class AppDateFormatter {
  AppDateFormatter._();

  static final DateFormat _dateFormat = DateFormat('dd.MM.yyyy');
  static final DateFormat _timeFormat = DateFormat('HH:mm:ss');
  static final DateFormat _dateTimeFormat = DateFormat('dd.MM.yyyy HH:mm:ss');

  static String date(DateTime? value, {String fallback = '-'}) {
    if (value == null) return fallback;
    return _dateFormat.format(value);
  }

  static String time(DateTime? value, {String fallback = '-'}) {
    if (value == null) return fallback;
    return _timeFormat.format(value);
  }

  static String dateTime(DateTime? value, {String fallback = '-'}) {
    if (value == null) return fallback;
    return _dateTimeFormat.format(value);
  }

  static DateTime? parseDate(String? value) => _parse(value);

  static DateTime? parseDateTime(String? value) => _parse(value);

  static String dateFromString(String? value, {String fallback = '-'}) {
    return date(parseDate(value), fallback: fallback);
  }

  static String dateTimeFromString(String? value, {String fallback = '-'}) {
    return dateTime(parseDateTime(value), fallback: fallback);
  }

  static DateTime? _parse(String? value) {
    final normalized = value?.trim();
    if (normalized == null || normalized.isEmpty) return null;

    final isoParsed = DateTime.tryParse(normalized);
    if (isoParsed != null) return isoParsed;

    for (final format in _inputFormats) {
      try {
        return format.parseStrict(normalized);
      } on FormatException {
        continue;
      }
    }

    return null;
  }

  static final List<DateFormat> _inputFormats = [
    DateFormat('dd.MM.yyyy HH:mm:ss'),
    DateFormat('dd.MM.yyyy HH:mm'),
    DateFormat('dd.MM.yyyy'),
  ];
}
