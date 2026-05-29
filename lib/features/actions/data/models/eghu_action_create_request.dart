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
    required this.actFile,
    required this.comparisonFile,
    this.employeeId,
    this.egxuTypeId,
    this.oneFactory,
    this.twoFactory,
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
  final EghuActionAttachment actFile;
  final EghuActionAttachment comparisonFile;
  final int? employeeId;
  final int? egxuTypeId;
  final String? oneFactory;
  final String? twoFactory;

  String get actionCode => switch (actionType) {
    ActionMenuType.reinstall => 'reinstall',
    ActionMenuType.detach => 'detach',
    ActionMenuType.indicatorUpload => 'indicator_upload',
  };

  Map<String, Object?> toJson() {
    final stampDate = _dateOnly(stampDateTime);
    return {
      'datetime': stampDateTime.toUtc().toIso8601String(),
      'region': regionId,
      'district': districtId,
      'type_of_activity': typeOfActivityId,
      'document_type': documentType,
      'document_id': consumerDocumentId,
      'employee': employeeId ?? 0,
      'list': [
        {
          'egxu_id': egxuItemId,
          'removal_reason': removalReason,
          'gas_usage_status': gasUsageStatus,
          'usage_type': usageType,
          'hourly_gas_consumption': hourlyGasConsumption,
          'daily_consumption': dailyConsumption,
          'replacement_reason': replacementReason,
          'real_numbers': [
            {
              'real_number': stampNumber,
              'from_date': stampDate,
              'to_date': stampDate,
            },
          ],
          'certificates': const [],
          'egxu_type': egxuTypeId ?? 0,
          'one_factory': oneFactory ?? '',
          'two_factory': twoFactory ?? '',
        },
      ],
    };
  }

  Map<String, Object?> toDebugFields() {
    return {
      ...toJson(),
      'action_type': actionCode,
      'act_file_name': actFile.name,
      'comparison_file_name': comparisonFile.name,
    };
  }

  static String _dateOnly(DateTime value) {
    final local = value.toLocal();
    return '${local.year.toString().padLeft(4, '0')}-'
        '${local.month.toString().padLeft(2, '0')}-'
        '${local.day.toString().padLeft(2, '0')}';
  }
}
