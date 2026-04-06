import 'package:equatable/equatable.dart';

class TeachMeasureCertificate extends Equatable {
  final int id;
  final String certificateType;
  final String certificateNumber;
  final DateTime issuedDate;
  final DateTime expiryDate;
  final String? egxuImage;
  final bool isActive;

  const TeachMeasureCertificate({
    required this.id,
    required this.certificateType,
    required this.certificateNumber,
    required this.issuedDate,
    required this.expiryDate,
    this.egxuImage,
    required this.isActive,
  });

  factory TeachMeasureCertificate.fromJson(Map<String, dynamic> json) {
    return TeachMeasureCertificate(
      id: json['id'] as int,
      certificateType: json['certificate_type'] as String,
      certificateNumber: json['certificate_number'] as String,
      issuedDate: DateTime.parse(json['issued_date'] as String),
      expiryDate: DateTime.parse(json['expiry_date'] as String),
      egxuImage: json['egxu_image'] as String?,
      isActive: json['is_active'] as bool,
    );
  }

  @override
  List<Object?> get props => [
    id,
    certificateType,
    certificateNumber,
    issuedDate,
    expiryDate,
    egxuImage,
    isActive,
  ];
}