import 'package:equatable/equatable.dart';

import '../../global/base_model.dart';

class TeachMeasureRealItem extends Equatable {
  final int id;
  final Employee employee;
  final String realNumber;
  final DateTime installedDate;
  final String sealInstalledLocation;
  final String qrCode;
  final bool removeSeal;
  final String? realReasonRemoval;
  final DateTime created;
  final bool isActive;

  const TeachMeasureRealItem({
    required this.id,
    required this.employee,
    required this.realNumber,
    required this.installedDate,
    required this.sealInstalledLocation,
    required this.qrCode,
    required this.removeSeal,
    this.realReasonRemoval,
    required this.created,
    required this.isActive,
  });

  factory TeachMeasureRealItem.fromJson(Map<String, dynamic> json) {
    return TeachMeasureRealItem(
      id: json['id'] ?? 0,

      employee: json['employee'] != null
          ? Employee.fromJson(json['employee'])
          : Employee(id: 0, fio: ""),

      realNumber: json['real_number'] ?? "",

      installedDate: json['installed_date'] != null
          ? DateTime.parse(json['installed_date'])
          : DateTime(1970),

      sealInstalledLocation: json['seal_installed_location'] ?? "",
      qrCode: json['qr_code'] ?? "",
      removeSeal: json['remove_seal'] ?? false,
      realReasonRemoval: json['real_reason_removal'],
      created: json['created'] != null
          ? DateTime.parse(json['created'])
          : DateTime(1970),
      isActive: json['is_active'] ?? false,
    );
  }


  @override
  List<Object?> get props => [
    id,
    employee,
    realNumber,
    installedDate,
    sealInstalledLocation,
    qrCode,
    removeSeal,
    realReasonRemoval,
    created,
    isActive,
  ];
}