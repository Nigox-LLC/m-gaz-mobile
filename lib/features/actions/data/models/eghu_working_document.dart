import 'package:equatable/equatable.dart';

class EghuWorkingDocument extends Equatable {
  const EghuWorkingDocument({
    required this.id,
    required this.datetime,
    required this.region,
    required this.district,
    required this.typeOfActivity,
    required this.documentType,
    required this.documentTypeDisplay,
    required this.employee,
    required this.isActive,
  });

  final int id;
  final DateTime datetime;
  final String region;
  final String district;
  final String typeOfActivity;
  final String documentType;
  final String documentTypeDisplay;
  final String employee;
  final bool isActive;

  factory EghuWorkingDocument.fromJson(Map<String, dynamic> json) {
    final consumer = _mapValue(json['consumer']);
    final egxu = _mapValue(json['egxu']);
    final reals = json['reals'] is List ? json['reals'] as List : const [];
    final firstReal = reals.isNotEmpty ? _mapValue(reals.first) : null;

    return EghuWorkingDocument(
      id: json['id'] as int? ?? 0,
      datetime:
          DateTime.tryParse(
            _firstText([
              json['datetime'],
              json['created_at'],
              json['updated_at'],
              firstReal?['installed_date'],
            ]),
          ) ??
          DateTime.now(),
      region: _firstText([
        json['region'],
        consumer?['region'],
        consumer?['region_name'],
      ]),
      district: _firstText([
        json['district'],
        consumer?['district'],
        consumer?['district_name'],
      ]),
      typeOfActivity: _firstText([
        json['type_of_activity'],
        json['reason_display'],
        json['reason'],
        egxu?['serial_number'],
      ]),
      documentType: json['document_type']?.toString() ?? '',
      documentTypeDisplay: _firstText([
        json['document_type_display'],
        json['document_type'],
      ]),
      employee: _firstText([
        json['employee'],
        json['employee_full_name'],
        firstReal?['employee_full_name'],
      ]),
      isActive: json['is_active'] == true,
    );
  }

  @override
  List<Object?> get props => [
    id,
    datetime,
    region,
    district,
    typeOfActivity,
    documentType,
    documentTypeDisplay,
    employee,
    isActive,
  ];
}

Map<String, dynamic>? _mapValue(Object? value) {
  if (value is Map) return Map<String, dynamic>.from(value);
  return null;
}

String _firstText(List<Object?> values) {
  for (final value in values) {
    final text = value?.toString().trim();
    if (text != null && text.isNotEmpty && text != 'null') return text;
  }
  return '';
}
