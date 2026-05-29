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
    return EghuWorkingDocument(
      id: json['id'] as int? ?? 0,
      datetime: DateTime.tryParse(json['datetime']?.toString() ?? '') ??
          DateTime.now(),
      region: json['region']?.toString() ?? '',
      district: json['district']?.toString() ?? '',
      typeOfActivity: json['type_of_activity']?.toString() ?? '',
      documentType: json['document_type']?.toString() ?? '',
      documentTypeDisplay: json['document_type_display']?.toString() ?? '',
      employee: json['employee']?.toString() ?? '',
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
