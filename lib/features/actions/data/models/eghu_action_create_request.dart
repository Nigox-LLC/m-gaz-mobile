import '../../domain/entities/action_menu_item.dart';
import 'eghu_action_attachment.dart';
import 'eghu_action_stamp_entry.dart';

class EghuActionCreateRequest {
  const EghuActionCreateRequest({
    required this.actionType,
    required this.consumerDocumentId,
    required this.egxuItemId,
    required this.stamps,
    required this.regionId,
    required this.districtId,
    required this.typeOfActivityId,
    required this.documentType,
    required this.removalReason,
    required this.gasUsageStatus,
    required this.usageType,
    required this.hourlyGasConsumption,
    required this.dailyConsumption,
    required this.replacementReason,
    this.actFiles = const [],
    this.proofFiles = const [],
    this.protocolFiles = const [],
    this.comparisonFiles = const [],
    this.employeeId,
    this.egxuTypeId,
    this.oneFactory,
    this.twoFactory,
    this.reason,
    this.otherReason,
    this.sealStatus,
    this.gasSupplyStopped,
    this.recordId,
    this.existingAktIds = const [],
  });

  final ActionMenuType actionType;
  final int consumerDocumentId;
  final int egxuItemId;
  final List<EghuActionStampEntry> stamps;
  final int regionId;
  final int districtId;
  final int typeOfActivityId;
  final String documentType;
  final String removalReason;
  final String gasUsageStatus;
  final String usageType;
  final num hourlyGasConsumption;
  final num dailyConsumption;
  final String replacementReason;
  final List<EghuActionAttachment> actFiles;
  final List<EghuActionAttachment> proofFiles;
  final List<EghuActionAttachment> protocolFiles;
  final List<EghuActionAttachment> comparisonFiles;
  final int? employeeId;
  final int? egxuTypeId;
  final String? oneFactory;
  final String? twoFactory;
  final String? reason;
  final String? otherReason;
  final String? sealStatus;
  final String? gasSupplyStopped;
  final int? recordId;
  final List<int> existingAktIds;

  bool get isUpdate => recordId != null;

  String get actionCode => switch (actionType) {
    ActionMenuType.reinstall => 'reinstall',
    ActionMenuType.detach => 'detach',
    ActionMenuType.indicatorUpload => 'indicator_upload',
  };

  String get stampNumber => stamps.isEmpty ? '' : stamps.first.number;

  DateTime? get stampDateTime =>
      stamps.isEmpty ? null : stamps.first.installedAt;

  String get egxuRemovalDocumentType => switch (actionType) {
    ActionMenuType.reinstall => 'reinstall',
    ActionMenuType.detach => 'removal',
    ActionMenuType.indicatorUpload => 'indicator_upload',
  };

  String get egxuRemovalReason => switch (actionType) {
    ActionMenuType.reinstall => 'eghu_improvement',
    ActionMenuType.detach => 'repair',
    ActionMenuType.indicatorUpload => 'other',
  };

  Map<String, Object?> toJson({List<int> aktIds = const []}) {
    final reals = isUpdate
        ? stamps.where((stamp) => stamp.shouldSendOnUpdate).toList()
        : stamps;
    final selectedReason = reason ?? egxuRemovalReason;
    final trimmedOtherReason = otherReason?.trim();
    return {
      'consumer': consumerDocumentId,
      'egxu': egxuItemId,
      'document_type': egxuRemovalDocumentType,
      'reason': selectedReason,
      'other_reason':
          selectedReason == 'other' &&
              trimmedOtherReason != null &&
              trimmedOtherReason.isNotEmpty
          ? trimmedOtherReason
          : null,
      'seal_status': sealStatus ?? 'working',
      'gas_supply_stopped': gasSupplyStopped ?? 'no',
      if (reals.isNotEmpty)
        'reals': reals
            .where((stamp) => stamp.number.trim().isNotEmpty)
            .map((stamp) => stamp.toJson())
            .toList(),
      'akt_ids': aktIds,
    };
  }

  Map<String, Object?> toDebugFields() {
    return {
      ...toJson(),
      'action_type': actionCode,
      'act_file_names': actFiles.map((file) => file.name).toList(),
      'proof_file_names': proofFiles.map((file) => file.name).toList(),
      'protocol_file_names': protocolFiles.map((file) => file.name).toList(),
      'comparison_file_names': comparisonFiles.map((file) => file.name).toList(),
    };
  }
}
