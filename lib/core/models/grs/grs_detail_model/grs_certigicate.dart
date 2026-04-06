class GrsCertificate {
  final int? id;
  final String? certificateType;
  final String? certificateNumber;
  final String? issuedDate;
  final DateTime? expiryDate;
  final String? egxuImage;
  final bool? isActive;

  GrsCertificate({
    this.id,
    this.certificateType,
    this.certificateNumber,
    this.issuedDate,
    this.expiryDate,
    this.egxuImage,
    this.isActive,
  });

  factory GrsCertificate.fromJson(Map<String, dynamic>? json) {
    if (json == null) return GrsCertificate();
    return GrsCertificate(
      id: json['id'],
      certificateType: json['certificate_type'],
      certificateNumber: json['certificate_number'],
      issuedDate: json['issued_date'],
      expiryDate: json['expiry_date'] != null ? DateTime.parse(json['expiry_date']) : null,
      egxuImage: json['egxu_image'],
      isActive: json['is_active'],
    );
  }
}