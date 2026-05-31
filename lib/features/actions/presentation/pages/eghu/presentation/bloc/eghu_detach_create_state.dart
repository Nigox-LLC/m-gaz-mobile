part of 'eghu_detach_create_bloc.dart';

enum EghuDetachSubmitStatus { initial, submitting, success, failure }

class EghuDetachCreateState extends Equatable {
  const EghuDetachCreateState({
    this.selectedConsumer,
    this.selectedConsumerDetail,
    this.selectedEghu,
    this.reason,
    this.otherReason = '',
    this.sealStatus,
    this.actFile,
    this.proofFile,
    this.protocolFile,
    this.gasSupplyStopped,
    this.stampNumber = '',
    this.stampDateTime,
    this.employeeId,
    this.employeeName,
    this.profileRegionId,
    this.profileDistrictId,
    this.status = EghuDetachSubmitStatus.initial,
    this.errorMessage = '',
    this.lastSubmittedRequest,
    this.recordId,
    this.stampRealId,
  });

  factory EghuDetachCreateState.fromDetail(
    EghuRemovalDetail detail, {
    int? employeeId,
    String? employeeName,
    int? regionId,
    int? districtId,
    DateTime? now,
  }) {
    final firstReal = detail.reals.isNotEmpty ? detail.reals.first : null;
    final stampDate =
        _parseDate(firstReal?.installedDate) ?? now ?? DateTime.now();

    EghuActionAttachment? actFile;
    EghuActionAttachment? proofFile;
    EghuActionAttachment? protocolFile;
    for (final akt in detail.akts) {
      final attachment = _attachmentFromAkt(akt);
      if (attachment == null) continue;
      switch (akt.aktFileType) {
        case 'akt':
          actFile = attachment;
        case 'proof':
          proofFile = attachment;
        case 'protocol':
          protocolFile = attachment;
      }
    }

    return EghuDetachCreateState(
      selectedConsumer: _consumerStub(detail),
      selectedEghu: _eghuStub(detail),
      reason: _reasonFromApi(detail.reason),
      otherReason: detail.otherReason ?? '',
      sealStatus: _sealStatusFromApi(detail.sealStatus),
      gasSupplyStopped: _gasSupplyStoppedFromApi(detail.gasSupplyStopped),
      actFile: actFile,
      proofFile: proofFile,
      protocolFile: protocolFile,
      stampNumber: firstReal?.realNumberValue ?? '',
      stampDateTime: stampDate,
      recordId: detail.id,
      stampRealId: firstReal?.id,
      employeeId: employeeId,
      employeeName: employeeName,
      profileRegionId: regionId,
      profileDistrictId: districtId,
    );
  }

  final WorkingWithConsumersList? selectedConsumer;
  final WorkingWithConsumersDetailModel? selectedConsumerDetail;
  final ConsumersEgxuItem? selectedEghu;
  final EghuDetachReason? reason;
  final String otherReason;
  final EghuDetachSealStatus? sealStatus;
  final EghuActionAttachment? actFile;
  final EghuActionAttachment? proofFile;
  final EghuActionAttachment? protocolFile;
  final EghuGasSupplyStopped? gasSupplyStopped;
  final String stampNumber;
  final DateTime? stampDateTime;
  final int? employeeId;
  final String? employeeName;
  final int? profileRegionId;
  final int? profileDistrictId;
  final EghuDetachSubmitStatus status;
  final String errorMessage;
  final EghuActionCreateRequest? lastSubmittedRequest;
  final int? recordId;
  final int? stampRealId;

  bool get isEdit => recordId != null;

  bool get shouldShowOtherReason => reason == EghuDetachReason.other;

  bool get shouldShowAct => sealStatus == EghuDetachSealStatus.defective;

  bool get shouldShowProof => sealStatus == EghuDetachSealStatus.working;

  bool get shouldShowGasSupplyStopped =>
      sealStatus == EghuDetachSealStatus.defective && actFile != null;

  bool get shouldShowStamp =>
      sealStatus == EghuDetachSealStatus.defective &&
      actFile != null &&
      gasSupplyStopped == EghuGasSupplyStopped.yes;

  bool get shouldShowProtocol =>
      sealStatus == EghuDetachSealStatus.defective &&
      actFile != null &&
      gasSupplyStopped == EghuGasSupplyStopped.no;

  bool get canSubmit =>
      selectedConsumer != null &&
      selectedEghu?.id != null &&
      reason != null &&
      (!shouldShowOtherReason || otherReason.trim().isNotEmpty) &&
      sealStatus != null &&
      (!shouldShowProof || proofFile != null) &&
      (!shouldShowAct || actFile != null) &&
      (sealStatus != EghuDetachSealStatus.defective ||
          gasSupplyStopped != null) &&
      (!shouldShowStamp ||
          (stampNumber.trim().isNotEmpty && stampDateTime != null)) &&
      (!shouldShowProtocol || protocolFile != null) &&
      status != EghuDetachSubmitStatus.submitting;

  EghuActionCreateRequest? toRequest({required DateTime now}) {
    if (!canSubmit) return null;

    final consumer = selectedConsumer!;
    final eghu = selectedEghu!;
    final selectedReason = reason!;
    final selectedSealStatus = sealStatus!;
    final selectedGasSupplyStopped =
        selectedSealStatus == EghuDetachSealStatus.working
        ? EghuGasSupplyStopped.no
        : gasSupplyStopped!;

    return EghuActionCreateRequest(
      actionType: ActionMenuType.detach,
      consumerDocumentId: consumer.id,
      egxuItemId: eghu.id!,
      stampNumber: shouldShowStamp ? stampNumber.trim() : '',
      stampDateTime: stampDateTime ?? now,
      regionId: selectedConsumerDetail?.region?.id ?? profileRegionId ?? 0,
      districtId:
          selectedConsumerDetail?.district?.id ?? profileDistrictId ?? 0,
      typeOfActivityId:
          eghu.consumerRelationEgxu?.typeOfActivityId ??
          eghu.consumerRelationEgxu?.id ??
          _parseInt(eghu.consumerRelationEgxu?.typeOfActivity) ??
          0,
      documentType: 'consumer',
      removalReason: 'for_repair',
      gasUsageStatus: 'used',
      usageType: 'all_gas_devices',
      hourlyGasConsumption: _hourlyGasConsumption(eghu),
      dailyConsumption: _hourlyGasConsumption(eghu) * 24,
      replacementReason: 'EGHU yechib olish',
      actFile: shouldShowAct ? actFile : null,
      proofFile: shouldShowProof ? proofFile : null,
      protocolFile: shouldShowProtocol ? protocolFile : null,
      comparisonFile: null,
      employeeId: selectedConsumerDetail?.employee?.id ?? employeeId,
      egxuTypeId: eghu.egxuType?.id,
      oneFactory: eghu.oneFactory,
      twoFactory: eghu.twoFactory,
      reason: selectedReason.apiValue,
      otherReason: selectedReason == EghuDetachReason.other
          ? otherReason.trim()
          : null,
      sealStatus: selectedSealStatus.apiValue,
      gasSupplyStopped: selectedGasSupplyStopped.apiValue,
      recordId: recordId,
      stampRealId: shouldShowStamp ? stampRealId : null,
      existingAktIds: _existingAktIds(),
    );
  }

  List<int> _existingAktIds() {
    final ids = <int>[];
    for (final entry in <(EghuActionAttachment?, bool)>[
      (actFile, shouldShowAct),
      (proofFile, shouldShowProof),
      (protocolFile, shouldShowProtocol),
    ]) {
      final attachment = entry.$1;
      if (!entry.$2 || attachment == null || !attachment.isRemote) continue;
      final aktId = attachment.remoteAktId;
      if (aktId != null) ids.add(aktId);
    }
    return ids;
  }

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

  static DateTime? _parseDate(String? value) {
    if (value == null || value.trim().isEmpty) return null;
    return DateTime.tryParse(value.trim());
  }

  static WorkingWithConsumersList _consumerStub(EghuRemovalDetail detail) {
    return WorkingWithConsumersList(
      id: detail.consumerId ?? 0,
      region: '',
      district: '',
      employee: '',
      consumers: detail.consumerName ?? '',
      facial: '',
      datetime: DateTime.now(),
      excelId: '',
    );
  }

  static ConsumersEgxuItem _eghuStub(EghuRemovalDetail detail) {
    return ConsumersEgxuItem(
      id: detail.egxuId,
      oneFactory: detail.egxuSerialNumber,
    );
  }

  static EghuActionAttachment? _attachmentFromAkt(EghuRemovalAkt akt) {
    final url = akt.fileUrl;
    if (url == null || url.trim().isEmpty) return null;
    final name = _fileNameFromUrl(url);
    return EghuActionAttachment.remote(
      url: url,
      name: name,
      isImage: _isImageName(name),
      aktId: akt.id,
    );
  }

  static String _fileNameFromUrl(String url) {
    final cleaned = url.split('?').first;
    final segment = cleaned.split('/').where((e) => e.isNotEmpty).toList();
    if (segment.isEmpty) return 'file';
    return Uri.decodeComponent(segment.last);
  }

  static bool _isImageName(String name) {
    final lower = name.toLowerCase();
    return lower.endsWith('.png') ||
        lower.endsWith('.jpg') ||
        lower.endsWith('.jpeg') ||
        lower.endsWith('.webp') ||
        lower.endsWith('.gif') ||
        lower.endsWith('.bmp') ||
        lower.endsWith('.heic');
  }

  static EghuDetachReason? _reasonFromApi(String? value) {
    if (value == null) return null;
    for (final reason in EghuDetachReason.values) {
      if (reason.apiValue == value) return reason;
    }
    return null;
  }

  static EghuDetachSealStatus? _sealStatusFromApi(String? value) {
    if (value == null) return null;
    for (final status in EghuDetachSealStatus.values) {
      if (status.apiValue == value) return status;
    }
    return null;
  }

  static EghuGasSupplyStopped? _gasSupplyStoppedFromApi(String? value) {
    if (value == null) return null;
    for (final option in EghuGasSupplyStopped.values) {
      if (option.apiValue == value) return option;
    }
    return null;
  }

  EghuDetachCreateState copyWith({
    WorkingWithConsumersList? selectedConsumer,
    WorkingWithConsumersDetailModel? selectedConsumerDetail,
    ConsumersEgxuItem? selectedEghu,
    EghuDetachReason? reason,
    String? otherReason,
    EghuDetachSealStatus? sealStatus,
    EghuActionAttachment? actFile,
    EghuActionAttachment? proofFile,
    EghuActionAttachment? protocolFile,
    EghuGasSupplyStopped? gasSupplyStopped,
    String? stampNumber,
    DateTime? stampDateTime,
    int? employeeId,
    String? employeeName,
    int? profileRegionId,
    int? profileDistrictId,
    EghuDetachSubmitStatus? status,
    String? errorMessage,
    EghuActionCreateRequest? lastSubmittedRequest,
    int? recordId,
    int? stampRealId,
    bool clearSelectedEghu = false,
    bool clearSelectedConsumerDetail = false,
    bool clearReason = false,
    bool clearOtherReason = false,
    bool clearSealStatus = false,
    bool clearActFile = false,
    bool clearProofFile = false,
    bool clearProtocolFile = false,
    bool clearGasSupplyStopped = false,
    bool clearStamp = false,
  }) {
    return EghuDetachCreateState(
      selectedConsumer: selectedConsumer ?? this.selectedConsumer,
      selectedConsumerDetail: clearSelectedConsumerDetail
          ? null
          : (selectedConsumerDetail ?? this.selectedConsumerDetail),
      selectedEghu: clearSelectedEghu
          ? null
          : (selectedEghu ?? this.selectedEghu),
      reason: clearReason ? null : (reason ?? this.reason),
      otherReason: clearOtherReason ? '' : (otherReason ?? this.otherReason),
      sealStatus: clearSealStatus ? null : (sealStatus ?? this.sealStatus),
      actFile: clearActFile ? null : (actFile ?? this.actFile),
      proofFile: clearProofFile ? null : (proofFile ?? this.proofFile),
      protocolFile: clearProtocolFile
          ? null
          : (protocolFile ?? this.protocolFile),
      gasSupplyStopped: clearGasSupplyStopped
          ? null
          : (gasSupplyStopped ?? this.gasSupplyStopped),
      stampNumber: clearStamp ? '' : (stampNumber ?? this.stampNumber),
      stampDateTime: clearStamp ? null : (stampDateTime ?? this.stampDateTime),
      employeeId: employeeId ?? this.employeeId,
      employeeName: employeeName ?? this.employeeName,
      profileRegionId: profileRegionId ?? this.profileRegionId,
      profileDistrictId: profileDistrictId ?? this.profileDistrictId,
      status: status ?? this.status,
      errorMessage: errorMessage ?? this.errorMessage,
      lastSubmittedRequest: lastSubmittedRequest ?? this.lastSubmittedRequest,
      recordId: recordId ?? this.recordId,
      stampRealId: stampRealId ?? this.stampRealId,
    );
  }

  @override
  List<Object?> get props => [
    selectedConsumer,
    selectedConsumerDetail,
    selectedEghu,
    reason,
    otherReason,
    sealStatus,
    actFile,
    proofFile,
    protocolFile,
    gasSupplyStopped,
    stampNumber,
    stampDateTime,
    employeeId,
    employeeName,
    profileRegionId,
    profileDistrictId,
    status,
    errorMessage,
    lastSubmittedRequest,
    recordId,
    stampRealId,
  ];
}
