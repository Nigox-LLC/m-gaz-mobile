import 'package:m_gaz/core/models/grs/grs_detail_model/grs_connetction_point.dart';

class GrsRealDevice {
  final int? id;
  final String? employee;
  final String? realRemovalUser;
  final GrsConnectionPoint? connectionPoint;
  final String? realNumber;
  final String? installedDate;
  final String? sealInstalledLocation;
  final String? qrCode;
  final bool? removeSeal;
  final String? realReasonRemoval;
  final String? realRemovalDate;
  final double? latitude;
  final double? longitude;
  final DateTime? created;
  final bool? isActive;

  GrsRealDevice({
    this.id,
    this.employee,
    this.realRemovalUser,
    this.connectionPoint,
    this.realNumber,
    this.installedDate,
    this.sealInstalledLocation,
    this.qrCode,
    this.removeSeal,
    this.realReasonRemoval,
    this.realRemovalDate,
    this.latitude,
    this.longitude,
    this.created,
    this.isActive,
  });

  factory GrsRealDevice.fromJson(Map<String, dynamic>? json) {
    if (json == null) return GrsRealDevice();
    return GrsRealDevice(
      id: json['id'],
      employee: json['employee'],
      realRemovalUser: json['real_removal_user'],
      connectionPoint: json['connection_point'] != null ? GrsConnectionPoint.fromJson(json['connection_point']) : null,
      realNumber: json['real_number'],
      installedDate: json['installed_date'],
      sealInstalledLocation: json['seal_installed_location'],
      qrCode: json['qr_code'],
      removeSeal: json['remove_seal'],
      realReasonRemoval: json['real_reason_removal'],
      realRemovalDate: json['real_removal_date'],
      latitude: (json['latitude'] as num?)?.toDouble(),
      longitude: (json['longitude'] as num?)?.toDouble(),
      created: json['created'] != null ? DateTime.parse(json['created']) : null,
      isActive: json['is_active'],
    );
  }
}