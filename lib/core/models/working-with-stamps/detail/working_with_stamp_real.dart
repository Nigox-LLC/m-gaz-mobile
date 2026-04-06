import '../../global/global_model.dart';

class WorkingWithStampReals {
  final int id;
  final GlobalModel employee;
  final String realNumber;
  final String installedDate;
  final String sealInstalledLocation;
  final String? qrCode;
  final bool? removeSeal;
  final String? realReasonRemoval;
  final DateTime created;
  final int egxu;

  WorkingWithStampReals({
    required this.id,
    required this.employee,
    required this.realNumber,
    required this.installedDate,
    required this.sealInstalledLocation,
    this.qrCode,
    this.removeSeal,
    this.realReasonRemoval,
    required this.created,
    required this.egxu,
  });

  factory WorkingWithStampReals.fromJson(Map<String, dynamic> json) {
    return WorkingWithStampReals(
      id: json["id"] ?? 0,
      employee: GlobalModel.fromJson(json["employee"] ?? {}),
      realNumber: json["real_number"] ?? "-",
      installedDate: json["installed_date"] ?? "-",
      sealInstalledLocation: json["seal_installed_location"] ?? "-",
      qrCode: json["qr_code"],
      removeSeal: json["remove_seal"],
      realReasonRemoval: json["real_reason_removal"],
      created: DateTime.tryParse(json["created"] ?? "") ?? DateTime.now(),
      egxu: json["a"] ?? 0,
    );
  }
}