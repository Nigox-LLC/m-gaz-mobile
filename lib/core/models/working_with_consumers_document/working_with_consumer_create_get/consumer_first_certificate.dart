import 'package:equatable/equatable.dart';

class ConsumerFirstCertificate extends Equatable {
  final String numberCertificate;
  final String givenDate;
  final String expirationDate;
  final String warningLetter;
  final String? warningDate;
  final String? warningReason;

  const ConsumerFirstCertificate({
    required this.numberCertificate,
    required this.givenDate,
    required this.expirationDate,
    required this.warningLetter,
    this.warningDate,
    this.warningReason,
  });

  factory ConsumerFirstCertificate.fromJson(Map<String, dynamic> json) {
    return ConsumerFirstCertificate(
      numberCertificate: json['number_certificate'] as String,
      givenDate: json['given_date'] as String,
      expirationDate: json['expiration_date'] as String,
      warningLetter: json['warning_letter'] as String,
      warningDate: json['warning_date'] as String?,
      warningReason: json['warning_reason'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'number_certificate': numberCertificate,
      'given_date': givenDate,
      'expiration_date': expirationDate,
      'warning_letter': warningLetter,
      'warning_date': warningDate,
      'warning_reason': warningReason,
    };
  }

  @override
  List<Object?> get props => [
    numberCertificate,
    givenDate,
    expirationDate,
    warningLetter,
    warningDate,
    warningReason,
  ];
}