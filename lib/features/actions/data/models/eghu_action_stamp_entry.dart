import 'package:equatable/equatable.dart';

class EghuActionStampEntry extends Equatable {
  const EghuActionStampEntry({
    required this.localId,
    required this.number,
    required this.installedAt,
    this.realId,
    this.employeeName,
    this.isNew = true,
    this.isDirty = true,
  });

  factory EghuActionStampEntry.newEntry({
    required DateTime installedAt,
    String? employeeName,
    String? localId,
  }) {
    final normalized = _truncateToMinute(installedAt);
    return EghuActionStampEntry(
      localId: localId ?? 'stamp-${DateTime.now().microsecondsSinceEpoch}',
      number: '',
      installedAt: normalized,
      employeeName: employeeName,
    );
  }

  factory EghuActionStampEntry.existing({
    required int? realId,
    required String number,
    required DateTime installedAt,
    String? employeeName,
  }) {
    return EghuActionStampEntry(
      localId: realId != null
          ? 'real-$realId'
          : 'stamp-${installedAt.microsecondsSinceEpoch}',
      realId: realId,
      number: number,
      installedAt: _truncateToMinute(installedAt),
      employeeName: employeeName,
      isNew: false,
      isDirty: false,
    );
  }

  final String localId;
  final int? realId;
  final String number;
  final DateTime installedAt;
  final String? employeeName;
  final bool isNew;
  final bool isDirty;

  bool get isValid => number.trim().isNotEmpty;

  bool get shouldSendOnUpdate => isNew || isDirty;

  EghuActionStampEntry copyWith({
    String? number,
    DateTime? installedAt,
    String? employeeName,
    bool? isDirty,
  }) {
    return EghuActionStampEntry(
      localId: localId,
      realId: realId,
      number: number ?? this.number,
      installedAt: installedAt == null
          ? this.installedAt
          : _truncateToMinute(installedAt),
      employeeName: employeeName ?? this.employeeName,
      isNew: isNew,
      isDirty: isDirty ?? this.isDirty,
    );
  }

  Map<String, Object?> toJson() {
    return {
      'id': realId,
      'real_number_value': number.trim(),
      'installed_date': _dateOnly(installedAt),
    };
  }

  static DateTime _truncateToMinute(DateTime value) {
    return DateTime(
      value.year,
      value.month,
      value.day,
      value.hour,
      value.minute,
    );
  }

  static String _dateOnly(DateTime value) {
    final local = value.toLocal();
    return '${local.year.toString().padLeft(4, '0')}-'
        '${local.month.toString().padLeft(2, '0')}-'
        '${local.day.toString().padLeft(2, '0')}';
  }

  @override
  List<Object?> get props => [
    localId,
    realId,
    number,
    installedAt,
    employeeName,
    isNew,
    isDirty,
  ];
}
