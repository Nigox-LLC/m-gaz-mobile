import '../../domain/entities/action_menu_item.dart';
import 'eghu_action_attachment.dart';

class EghuActionCreateRequest {
  const EghuActionCreateRequest({
    required this.actionType,
    required this.consumerDocumentId,
    required this.egxuItemId,
    required this.stampNumber,
    required this.stampDateTime,
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
    this.actFile,
    this.proofFile,
    this.protocolFile,
    this.comparisonFile,
    this.employeeId,
    this.egxuTypeId,
    this.oneFactory,
    this.twoFactory,
    this.reason,
    this.otherReason,
    this.sealStatus,
    this.gasSupplyStopped,
    this.recordId,
    this.stampRealId,
    this.existingAktIds = const [],
  });

  final ActionMenuType actionType;
  final int consumerDocumentId;
  final int egxuItemId;
  final String stampNumber;
  final DateTime stampDateTime;
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
  final EghuActionAttachment? actFile;
  final EghuActionAttachment? proofFile;
  final EghuActionAttachment? protocolFile;
  final EghuActionAttachment? comparisonFile;
  final int? employeeId;
  final int? egxuTypeId;
  final String? oneFactory;
  final String? twoFactory;
  final String? reason;
  final String? otherReason;
  final String? sealStatus;
  final String? gasSupplyStopped;
  final int? recordId;
  final int? stampRealId;
  final List<int> existingAktIds;

  bool get isUpdate => recordId != null;

  String get actionCode => switch (actionType) {
    ActionMenuType.reinstall => 'reinstall',
    ActionMenuType.detach => 'detach',
    ActionMenuType.indicatorUpload => 'indicator_upload',
  };

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
    final stampDate = _dateOnly(stampDateTime);
    final trimmedStamp = stampNumber.trim();
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
      if (trimmedStamp.isNotEmpty)
        'reals': [
          {
            'id': stampRealId,
            'real_number_value': trimmedStamp,
            'installed_date': stampDate,
          },
        ],
      'akt_ids': aktIds,
    };
  }

  Map<String, Object?> toDebugFields() {
    return {
      ...toJson(),
      'action_type': actionCode,
      'act_file_name': actFile?.name,
      'proof_file_name': proofFile?.name,
      'protocol_file_name': protocolFile?.name,
      'comparison_file_name': comparisonFile?.name,
    };
  }

  static String _dateOnly(DateTime value) {
    final local = value.toLocal();
    return '${local.year.toString().padLeft(4, '0')}-'
        '${local.month.toString().padLeft(2, '0')}-'
        '${local.day.toString().padLeft(2, '0')}';
  }
}
