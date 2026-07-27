import '../../domain/entities/eimzo_status.dart';

class EImzoStatusModel extends EImzoStatus {
  const EImzoStatusModel({required super.code, super.message});

  factory EImzoStatusModel.fromJson(Map<String, dynamic> json) {
    final rawStatus = json['status'];
    final code = rawStatus is int
        ? rawStatus
        : int.tryParse(rawStatus?.toString() ?? '');
    if (code == null) {
      throw const FormatException('E-Imzo status response is invalid.');
    }
    return EImzoStatusModel(
      code: code,
      message: (json['message'] ?? json['error'] ?? '').toString(),
    );
  }
}
