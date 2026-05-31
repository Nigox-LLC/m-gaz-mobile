import 'package:equatable/equatable.dart';

class EghuIndicatorDocument extends Equatable {
  const EghuIndicatorDocument({
    required this.id,
    required this.createdAt,
    required this.updatedAt,
    required this.isActive,
    required this.value,
    required this.consumerId,
    required this.egxuId,
    required this.personalAccount,
    required this.consumerName,
    required this.factoryNumber,
    required this.egxuType,
    required this.region,
    required this.district,
    required this.employee,
    this.files = const [],
  });

  final int id;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final bool isActive;
  final String value;
  final int consumerId;
  final int egxuId;
  final String personalAccount;
  final String consumerName;
  final String factoryNumber;
  final String egxuType;
  final String region;
  final String district;
  final String employee;
  final List<EghuIndicatorFileDocument> files;

  factory EghuIndicatorDocument.fromJson(Map<String, dynamic> json) {
    final consumer = _mapValue(json['consumer']);
    final consumerInfo = _mapValue(json['consumer_info']);
    final regionInfo = _mapValue(consumerInfo?['region_info']);
    final districtInfo = _mapValue(consumerInfo?['district_info']);
    final egxu = _mapValue(json['egxu']);
    final egxuInfo = _mapValue(json['egxu_info']);

    return EghuIndicatorDocument(
      id: _parseInt(json['id']) ?? 0,
      createdAt:
          DateTime.tryParse(_firstText([json['created_at']])) ?? DateTime.now(),
      updatedAt: DateTime.tryParse(_firstText([json['updated_at']])),
      isActive: json['is_active'] == true,
      value: _firstText([json['value']]),
      consumerId:
          _parseInt(json['consumer']) ??
          _parseInt(consumerInfo?['id']) ??
          _parseInt(consumer?['id']) ??
          0,
      egxuId: _parseInt(json['egxu']) ?? _parseInt(egxu?['id']) ?? 0,
      personalAccount: _firstText([
        json['personal_account'],
        json['facial'],
        consumerInfo?['facial'],
        consumer?['facial'],
        consumer?['personal_account'],
        consumer?['account_number'],
        json['consumer'],
      ]),
      consumerName: _firstText([
        json['consumer_name'],
        consumerInfo?['name'],
        consumer?['name'],
      ]),
      factoryNumber: _firstText([
        json['factory_number'],
        egxuInfo?['one_factory'],
        egxuInfo?['two_factory'],
        egxu?['one_factory'],
        egxu?['two_factory'],
        egxu?['serial_number'],
        json['egxu'],
      ]),
      egxuType: _firstText([json['egxu_type'], egxuInfo?['egxu_type']]),
      region: _firstText([
        json['region'],
        regionInfo?['name'],
        consumerInfo?['region'],
        consumerInfo?['region_name'],
        consumer?['region'],
        consumer?['region_name'],
      ]),
      district: _firstText([
        json['district'],
        districtInfo?['name'],
        consumerInfo?['district'],
        consumerInfo?['district_name'],
        consumer?['district'],
        consumer?['district_name'],
      ]),
      employee: _firstText([
        json['employee'],
        json['employee_full_name'],
        json['created_by'],
        consumerInfo?['employee'],
      ]),
      files: _filesFromJson(json['files']),
    );
  }

  @override
  List<Object?> get props => [
    id,
    createdAt,
    updatedAt,
    isActive,
    value,
    consumerId,
    egxuId,
    personalAccount,
    consumerName,
    factoryNumber,
    egxuType,
    region,
    district,
    employee,
    files,
  ];
}

class EghuIndicatorFileDocument extends Equatable {
  const EghuIndicatorFileDocument({
    required this.id,
    required this.egxuIndicatorId,
    required this.file,
    required this.fileType,
    required this.createdAt,
  });

  final int id;
  final int egxuIndicatorId;
  final String file;
  final String fileType;
  final DateTime? createdAt;

  factory EghuIndicatorFileDocument.fromJson(Map<String, dynamic> json) {
    return EghuIndicatorFileDocument(
      id: _parseInt(json['id']) ?? 0,
      egxuIndicatorId: _parseInt(json['egxu_indicator']) ?? 0,
      file: _firstText([json['file']]),
      fileType: _firstText([json['file_type']]),
      createdAt: DateTime.tryParse(_firstText([json['created_at']])),
    );
  }

  @override
  List<Object?> get props => [id, egxuIndicatorId, file, fileType, createdAt];
}

Map<String, dynamic>? _mapValue(Object? value) {
  if (value is Map) return Map<String, dynamic>.from(value);
  return null;
}

int? _parseInt(Object? value) {
  if (value is int) return value;
  if (value is num) return value.toInt();
  if (value is String) return int.tryParse(value);
  return null;
}

String _firstText(List<Object?> values) {
  for (final value in values) {
    final text = value?.toString().trim();
    if (text != null && text.isNotEmpty && text != 'null') return text;
  }
  return '';
}

List<EghuIndicatorFileDocument> _filesFromJson(Object? value) {
  if (value is! List) return const [];
  return value
      .whereType<Map>()
      .map(
        (item) =>
            EghuIndicatorFileDocument.fromJson(Map<String, dynamic>.from(item)),
      )
      .toList();
}
