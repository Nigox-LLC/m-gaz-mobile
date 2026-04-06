import 'package:equatable/equatable.dart';

class ConsumerCertificate extends Equatable {
  final String certificateType;
  final String certificateNumber;
  final String issuedDate;
  final String expiryDate;

  const ConsumerCertificate({
    required this.certificateType,
    required this.certificateNumber,
    required this.issuedDate,
    required this.expiryDate,
  });

  factory ConsumerCertificate.fromJson(Map<String, dynamic> json) {
    return ConsumerCertificate(
      certificateType: json['certificate_type'] as String,
      certificateNumber: json['certificate_number'] as String,
      issuedDate: json['issued_date'] as String,
      expiryDate: json['expiry_date'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'certificate_type': certificateType,
      'certificate_number': certificateNumber,
      'issued_date': issuedDate,
      'expiry_date': expiryDate,
    };
  }

  @override
  List<Object?> get props => [
    certificateType,
    certificateNumber,
    issuedDate,
    expiryDate,
  ];
}