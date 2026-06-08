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
    this.actFiles = const [],
    this.proofFiles = const [],
    this.protocolFiles = const [],
    this.gasSupplyStopped,
    this.stamps = const [],
    this.employeeId,
    this.employeeName,
    this.profileRegionId,
    this.profileDistrictId,
    this.status = EghuDetachSubmitStatus.initial,
    this.errorMessage = '',
    this.lastSubmittedRequest,
    this.recordId,
  });

  factory EghuDetachCreateState.fromDetail(
    EghuRemovalDetail detail, {
    int? employeeId,
    String? employeeName,
    int? regionId,
    int? districtId,
    DateTime? now,
  }) {
    final fallbackDate = now ?? DateTime.now();
    final stamps = detail.reals
        .map(
          (real) => EghuActionStampEntry.existing(
            realId: real.id,
            number: real.realNumberValue ?? '',
            installedAt: _parseDate(real.installedDate) ?? fallbackDate,
            employeeName: employeeName,
          ),
        )
        .toList();

    final actFiles = <EghuActionAttachment>[];
    final proofFiles = <EghuActionAttachment>[];
    final protocolFiles = <EghuActionAttachment>[];
    for (final akt in detail.akts) {
      final attachment = _attachmentFromAkt(akt);
      if (attachment == null) continue;
      switch (akt.aktFileType) {
        case 'akt':
          actFiles.add(attachment);
        case 'proof':
          proofFiles.add(attachment);
        case 'protocol':
          protocolFiles.add(attachment);
      }
    }

    return EghuDetachCreateState(
      selectedConsumer: _consumerStub(detail),
      selectedEghu: _eghuStub(detail),
      reason: _reasonFromApi(detail.reason),
      otherReason: detail.otherReason ?? '',
      sealStatus: _sealStatusFromApi(detail.sealStatus),
      gasSupplyStopped: _gasSupplyStoppedFromApi(detail.gasSupplyStopped),
      actFiles: actFiles,
      proofFiles: proofFiles,
      protocolFiles: protocolFiles,
      stamps: stamps,
      recordId: detail.id,
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
  final List<EghuActionAttachment> actFiles;
  final List<EghuActionAttachment> proofFiles;
  final List<EghuActionAttachment> protocolFiles;
  final EghuGasSupplyStopped? gasSupplyStopped;
  final List<EghuActionStampEntry> stamps;
  final int? employeeId;
  final String? employeeName;
  final int? profileRegionId;
  final int? profileDistrictId;
  final EghuDetachSubmitStatus status;
  final String errorMessage;
  final EghuActionCreateRequest? lastSubmittedRequest;
  final int? recordId;

  bool get isEdit => recordId != null;

  String get stampNumber => stamps.isEmpty ? '' : stamps.first.number;

  DateTime? get stampDateTime =>
      stamps.isEmpty ? null : stamps.first.installedAt;

  int? get stampRealId => stamps.isEmpty ? null : stamps.first.realId;

  bool get hasValidStamps =>
      stamps.isNotEmpty && stamps.every((stamp) => stamp.isValid);

  bool get shouldShowOtherReason => reason == EghuDetachReason.other;

  bool get shouldShowAct => sealStatus == EghuDetachSealStatus.defective;

  bool get shouldShowProof => sealStatus == EghuDetachSealStatus.working;

  bool get shouldShowGasSupplyStopped =>
      sealStatus == EghuDetachSealStatus.defective && actFiles.isNotEmpty;

  bool get shouldShowStamp =>
      sealStatus == EghuDetachSealStatus.defective &&
      actFiles.isNotEmpty &&
      gasSupplyStopped == EghuGasSupplyStopped.yes;

  bool get shouldShowProtocol =>
      sealStatus == EghuDetachSealStatus.defective &&
      actFiles.isNotEmpty &&
      gasSupplyStopped == EghuGasSupplyStopped.no;

  bool get canSubmit =>
      selectedConsumer != null &&
      selectedEghu?.id != null &&
      reason != null &&
      (!shouldShowOtherReason || otherReason.trim().isNotEmpty) &&
      sealStatus != null &&
      (!shouldShowProof || proofFiles.isNotEmpty) &&
      (!shouldShowAct || actFiles.isNotEmpty) &&
      (sealStatus != EghuDetachSealStatus.defective ||
          gasSupplyStopped != null) &&
      (!shouldShowStamp || hasValidStamps) &&
      (!shouldShowProtocol || protocolFiles.isNotEmpty) &&
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
      stamps: shouldShowStamp ? stamps : const [],
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
      actFiles: shouldShowAct ? List.unmodifiable(actFiles) : const [],
      proofFiles: shouldShowProof ? List.unmodifiable(proofFiles) : const [],
      protocolFiles: shouldShowProtocol
          ? List.unmodifiable(protocolFiles)
          : const [],
      comparisonFiles: const [],
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
      existingAktIds: _existingAktIds(),
    );
  }

  List<int> _existingAktIds() {
    final ids = <int>[];
    for (final entry in <(List<EghuActionAttachment>, bool)>[
      (actFiles, shouldShowAct),
      (proofFiles, shouldShowProof),
      (protocolFiles, shouldShowProtocol),
    ]) {
      if (!entry.$2) continue;
      for (final attachment in entry.$1) {
        if (!attachment.isRemote) continue;
        final aktId = attachment.remoteAktId;
        if (aktId != null) ids.add(aktId);
      }
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
    List<EghuActionAttachment>? actFiles,
    List<EghuActionAttachment>? proofFiles,
    List<EghuActionAttachment>? protocolFiles,
    EghuGasSupplyStopped? gasSupplyStopped,
    List<EghuActionStampEntry>? stamps,
    int? employeeId,
    String? employeeName,
    int? profileRegionId,
    int? profileDistrictId,
    EghuDetachSubmitStatus? status,
    String? errorMessage,
    EghuActionCreateRequest? lastSubmittedRequest,
    int? recordId,
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
      actFiles: clearActFile ? const [] : (actFiles ?? this.actFiles),
      proofFiles: clearProofFile ? const [] : (proofFiles ?? this.proofFiles),
      protocolFiles: clearProtocolFile
          ? const []
          : (protocolFiles ?? this.protocolFiles),
      gasSupplyStopped: clearGasSupplyStopped
          ? null
          : (gasSupplyStopped ?? this.gasSupplyStopped),
      stamps: clearStamp ? const [] : (stamps ?? this.stamps),
      employeeId: employeeId ?? this.employeeId,
      employeeName: employeeName ?? this.employeeName,
      profileRegionId: profileRegionId ?? this.profileRegionId,
      profileDistrictId: profileDistrictId ?? this.profileDistrictId,
      status: status ?? this.status,
      errorMessage: errorMessage ?? this.errorMessage,
      lastSubmittedRequest: lastSubmittedRequest ?? this.lastSubmittedRequest,
      recordId: recordId ?? this.recordId,
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
    actFiles,
    proofFiles,
    protocolFiles,
    gasSupplyStopped,
    stamps,
    employeeId,
    employeeName,
    profileRegionId,
    profileDistrictId,
    status,
    errorMessage,
    lastSubmittedRequest,
    recordId,
  ];
}
