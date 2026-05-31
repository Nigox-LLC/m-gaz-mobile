import 'eghu_action_attachment.dart';

class EghuIndicatorCreateRequest {
  const EghuIndicatorCreateRequest({
    required this.createdAt,
    required this.value,
    required this.consumerId,
    required this.egxuId,
    required this.basicFile,
    required this.printFile,
  });

  final DateTime createdAt;
  final String value;
  final int consumerId;
  final int egxuId;
  final EghuActionAttachment basicFile;
  final EghuActionAttachment printFile;

  Map<String, Object?> toJson() {
    return {
      'created_at': createdAt.toUtc().toIso8601String(),
      'is_active': true,
      'value': value,
      'consumer': consumerId,
      'egxu': egxuId,
    };
  }
}

class EghuIndicatorUpdateRequest {
  const EghuIndicatorUpdateRequest({
    required this.id,
    required this.value,
    required this.consumerId,
    required this.egxuId,
    required this.mainChanged,
    required this.basicFileChanged,
    required this.printFileChanged,
    this.basicFile,
    this.printFile,
    this.basicFileId,
    this.printFileId,
  });

  final int id;
  final String value;
  final int consumerId;
  final int egxuId;
  final bool mainChanged;
  final bool basicFileChanged;
  final bool printFileChanged;
  final EghuActionAttachment? basicFile;
  final EghuActionAttachment? printFile;
  final int? basicFileId;
  final int? printFileId;

  Map<String, Object?> toJson() {
    return {'value': value, 'consumer': consumerId, 'egxu': egxuId};
  }
}
