part of 'eghu_action_create_bloc.dart';

enum EghuActionSubmitStatus { initial, submitting, success, failure }

class EghuActionCreateState extends Equatable {
  const EghuActionCreateState({
    required this.actionType,
    this.selectedConsumer,
    this.selectedConsumerDetail,
    this.selectedEghu,
    this.actFile,
    this.comparisonFile,
    this.stampNumber = '',
    this.stampDateTime,
    this.employeeId,
    this.employeeName,
    this.profileRegionId,
    this.profileDistrictId,
    this.status = EghuActionSubmitStatus.initial,
    this.errorMessage = '',
    this.lastSubmittedRequest,
  });

  final ActionMenuType actionType;
  final WorkingWithConsumersList? selectedConsumer;
  final WorkingWithConsumersDetailModel? selectedConsumerDetail;
  final ConsumersEgxuItem? selectedEghu;
  final EghuActionAttachment? actFile;
  final EghuActionAttachment? comparisonFile;
  final String stampNumber;
  final DateTime? stampDateTime;
  final int? employeeId;
  final String? employeeName;
  final int? profileRegionId;
  final int? profileDistrictId;
  final EghuActionSubmitStatus status;
  final String errorMessage;
  final EghuActionCreateRequest? lastSubmittedRequest;

  bool get canSubmit =>
      selectedConsumer != null &&
      selectedEghu?.id != null &&
      actFile != null &&
      comparisonFile != null &&
      stampNumber.trim().isNotEmpty &&
      stampDateTime != null;

  EghuActionCreateRequest? toRequest() {
    final consumer = selectedConsumer;
    final eghu = selectedEghu;
    final act = actFile;
    final comparison = comparisonFile;
    final date = stampDateTime;

    if (consumer == null ||
        eghu?.id == null ||
        act == null ||
        comparison == null ||
        stampNumber.trim().isEmpty ||
        date == null) {
      return null;
    }

    return EghuActionCreateRequest(
      actionType: actionType,
      consumerDocumentId: consumer.id,
      egxuItemId: eghu!.id!,
      stampNumber: stampNumber.trim(),
      stampDateTime: date,
      regionId: selectedConsumerDetail?.region?.id ?? profileRegionId ?? 0,
      districtId:
          selectedConsumerDetail?.district?.id ?? profileDistrictId ?? 0,
      typeOfActivityId:
          eghu.consumerRelationEgxu?.typeOfActivityId ??
          eghu.consumerRelationEgxu?.id ??
          _parseInt(eghu.consumerRelationEgxu?.typeOfActivity) ??
          0,
      documentType: 'consumer',
      removalReason: _removalReason,
      gasUsageStatus: _gasUsageStatus,
      usageType: 'all_gas_devices',
      hourlyGasConsumption: _hourlyGasConsumption(eghu),
      dailyConsumption: _hourlyGasConsumption(eghu) * 24,
      replacementReason: _replacementReason,
      actFile: act,
      comparisonFile: comparison,
      employeeId: selectedConsumerDetail?.employee?.id ?? employeeId,
      egxuTypeId: eghu.egxuType?.id,
      oneFactory: eghu.oneFactory,
      twoFactory: eghu.twoFactory,
    );
  }

  String get _removalReason => switch (actionType) {
    ActionMenuType.reinstall => 'other_type_or_factory',
    ActionMenuType.detach => 'for_repair',
    ActionMenuType.indicatorUpload => 'other_type_or_factory',
  };

  String get _gasUsageStatus => switch (actionType) {
    ActionMenuType.reinstall => 'tagged',
    ActionMenuType.detach => 'used',
    ActionMenuType.indicatorUpload => 'used',
  };

  String get _replacementReason => switch (actionType) {
    ActionMenuType.reinstall => "EGHU qayta o'rnatish",
    ActionMenuType.detach => 'EGHU yechib olish',
    ActionMenuType.indicatorUpload => "EGHU ko'rsatkichi yuklash",
  };

  num _hourlyGasConsumption(ConsumersEgxuItem eghu) {
    final equipment = eghu.gasEquipmentList;
    if (equipment == null || equipment.isEmpty) return 0;
    return equipment.fold<num>(0, (sum, item) {
      final hourly =
          item.hourlyGasConsumption ??
          item.gasEquipment?.hourlyGasConsumption ??
          0;
      final quantity = item.quantity ?? 1;
      return sum + (hourly * quantity);
    });
  }

  int? _parseInt(Object? value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    if (value is String) return int.tryParse(value);
    return null;
  }

  EghuActionCreateState copyWith({
    WorkingWithConsumersList? selectedConsumer,
    WorkingWithConsumersDetailModel? selectedConsumerDetail,
    ConsumersEgxuItem? selectedEghu,
    EghuActionAttachment? actFile,
    EghuActionAttachment? comparisonFile,
    String? stampNumber,
    DateTime? stampDateTime,
    int? employeeId,
    String? employeeName,
    int? profileRegionId,
    int? profileDistrictId,
    EghuActionSubmitStatus? status,
    String? errorMessage,
    EghuActionCreateRequest? lastSubmittedRequest,
    bool clearSelectedEghu = false,
    bool clearSelectedConsumerDetail = false,
    bool clearActFile = false,
    bool clearComparisonFile = false,
  }) {
    return EghuActionCreateState(
      actionType: actionType,
      selectedConsumer: selectedConsumer ?? this.selectedConsumer,
      selectedConsumerDetail: clearSelectedConsumerDetail
          ? null
          : (selectedConsumerDetail ?? this.selectedConsumerDetail),
      selectedEghu: clearSelectedEghu
          ? null
          : (selectedEghu ?? this.selectedEghu),
      actFile: clearActFile ? null : (actFile ?? this.actFile),
      comparisonFile: clearComparisonFile
          ? null
          : (comparisonFile ?? this.comparisonFile),
      stampNumber: stampNumber ?? this.stampNumber,
      stampDateTime: stampDateTime ?? this.stampDateTime,
      employeeId: employeeId ?? this.employeeId,
      employeeName: employeeName ?? this.employeeName,
      profileRegionId: profileRegionId ?? this.profileRegionId,
      profileDistrictId: profileDistrictId ?? this.profileDistrictId,
      status: status ?? this.status,
      errorMessage: errorMessage ?? this.errorMessage,
      lastSubmittedRequest: lastSubmittedRequest ?? this.lastSubmittedRequest,
    );
  }

  @override
  List<Object?> get props => [
    actionType,
    selectedConsumer,
    selectedConsumerDetail,
    selectedEghu,
    actFile,
    comparisonFile,
    stampNumber,
    stampDateTime,
    employeeId,
    employeeName,
    profileRegionId,
    profileDistrictId,
    status,
    errorMessage,
    lastSubmittedRequest,
  ];
}
