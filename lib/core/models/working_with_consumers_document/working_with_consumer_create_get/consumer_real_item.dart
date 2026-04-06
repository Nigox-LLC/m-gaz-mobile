import 'package:equatable/equatable.dart';

class ConsumerRealItem extends Equatable {
  final String realNumber;
  final String installedDate;
  final String sealInstalledLocation;
  final String qrCode;
  final bool removeSeal;
  final String? realReasonRemoval;
  final int employeeId;

  const ConsumerRealItem({
    required this.realNumber,
    required this.installedDate,
    required this.sealInstalledLocation,
    required this.qrCode,
    required this.removeSeal,
    this.realReasonRemoval,
    required this.employeeId,
  });

  factory ConsumerRealItem.fromJson(Map<String, dynamic> json) {
    return ConsumerRealItem(
      realNumber: json['real_number'] as String,
      installedDate: json['installed_date'] as String,
      sealInstalledLocation: json['seal_installed_location'] as String,
      qrCode: json['qr_code'] as String,
      removeSeal: json['remove_seal'] as bool,
      realReasonRemoval: json['real_reason_removal'] as String?,
      employeeId: json['employee_id'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'real_number': realNumber,
      'installed_date': installedDate,
      'seal_installed_location': sealInstalledLocation,
      'qr_code': qrCode,
      'remove_seal': removeSeal,
      'real_reason_removal': realReasonRemoval,
      'employee_id': employeeId,
    };
  }

  @override
  List<Object?> get props => [
    realNumber,
    installedDate,
    sealInstalledLocation,
    qrCode,
    removeSeal,
    realReasonRemoval,
    employeeId,
  ];
}