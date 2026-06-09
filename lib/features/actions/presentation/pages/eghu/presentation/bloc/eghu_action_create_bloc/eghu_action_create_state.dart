part of 'eghu_action_create_bloc.dart';

enum EghuActionSubmitStatus { initial, submitting, success, failure }

class EghuActionCreateState extends Equatable {
  const EghuActionCreateState({
    required this.actionType,
    this.selectedConsumer,
    this.selectedConsumerDetail,
    this.selectedEghu,
    this.actFiles = const [],
    this.comparisonFiles = const [],
    this.stamps = const [],
    this.employeeId,
    this.employeeName,
    this.profileRegionId,
    this.profileDistrictId,
    this.status = EghuActionSubmitStatus.initial,
    this.errorMessage = '',
    this.lastSubmittedRequest,
    this.recordId,
  });

  factory EghuActionCreateState.fromDetail(
    EghuRemovalDetail detail,
    ActionMenuType actionType, {
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
            installationPlaceId: real.installationPlaceId,
            installationPlaceName: real.installationPlaceName,
          ),
        )
        .toList();

    final actFiles = <EghuActionAttachment>[];
    final comparisonFiles = <EghuActionAttachment>[];
    for (final akt in detail.akts) {
      final attachment = _attachmentFromAkt(akt);
      if (attachment == null) continue;
      switch (akt.aktFileType) {
        case 'akt':
          actFiles.add(attachment);
        case 'calibration':
          comparisonFiles.add(attachment);
      }
    }

    return EghuActionCreateState(
      actionType: actionType,
      selectedConsumer: _consumerStub(detail),
      selectedEghu: _eghuStub(detail),
      actFiles: actFiles,
      comparisonFiles: comparisonFiles,
      stamps: stamps,
      recordId: detail.id,
      employeeId: employeeId,
      employeeName: employeeName,
      profileRegionId: regionId,
      profileDistrictId: districtId,
    );
  }

  final ActionMenuType actionType;
  final WorkingWithConsumersList? selectedConsumer;
  final WorkingWithConsumersDetailModel? selectedConsumerDetail;
  final ConsumersEgxuItem? selectedEghu;
  final List<EghuActionAttachment> actFiles;
  final List<EghuActionAttachment> comparisonFiles;
  final List<EghuActionStampEntry> stamps;
  final int? employeeId;
  final String? employeeName;
  final int? profileRegionId;
  final int? profileDistrictId;
  final EghuActionSubmitStatus status;
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

  /// Reinstall requires every stamp to have an installation place selected.
  bool get requiresStampInstallationPlace =>
      actionType == ActionMenuType.reinstall;

  bool get hasValidStampPlaces =>
      !requiresStampInstallationPlace ||
      stamps.every((stamp) => stamp.installationPlaceId != null);

  bool get canSubmit =>
      selectedConsumer != null &&
      selectedEghu?.id != null &&
      actFiles.isNotEmpty &&
      comparisonFiles.isNotEmpty &&
      hasValidStamps &&
      hasValidStampPlaces;

  EghuActionCreateRequest? toRequest() {
    final consumer = selectedConsumer;
    final eghu = selectedEghu;

    if (consumer == null ||
        eghu?.id == null ||
        actFiles.isEmpty ||
        comparisonFiles.isEmpty ||
        !hasValidStamps ||
        !hasValidStampPlaces) {
      return null;
    }

    return EghuActionCreateRequest(
      actionType: actionType,
      consumerDocumentId: consumer.id,
      egxuItemId: eghu!.id!,
      stamps: stamps,
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
      actFiles: List.unmodifiable(actFiles),
      comparisonFiles: List.unmodifiable(comparisonFiles),
      employeeId: selectedConsumerDetail?.employee?.id ?? employeeId,
      egxuTypeId: eghu.egxuType?.id,
      oneFactory: eghu.oneFactory,
      twoFactory: eghu.twoFactory,
      recordId: recordId,
      existingAktIds: _existingAktIds(),
    );
  }

  List<int> _existingAktIds() {
    final ids = <int>[];
    for (final attachment in [...actFiles, ...comparisonFiles]) {
      if (!attachment.isRemote) continue;
      final aktId = attachment.remoteAktId;
      if (aktId != null) ids.add(aktId);
    }
    return ids;
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

  EghuActionCreateState copyWith({
    WorkingWithConsumersList? selectedConsumer,
    WorkingWithConsumersDetailModel? selectedConsumerDetail,
    ConsumersEgxuItem? selectedEghu,
    List<EghuActionAttachment>? actFiles,
    List<EghuActionAttachment>? comparisonFiles,
    List<EghuActionStampEntry>? stamps,
    int? employeeId,
    String? employeeName,
    int? profileRegionId,
    int? profileDistrictId,
    EghuActionSubmitStatus? status,
    String? errorMessage,
    EghuActionCreateRequest? lastSubmittedRequest,
    int? recordId,
    bool clearSelectedEghu = false,
    bool clearSelectedConsumerDetail = false,
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
      actFiles: actFiles ?? this.actFiles,
      comparisonFiles: comparisonFiles ?? this.comparisonFiles,
      stamps: stamps ?? this.stamps,
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
    actionType,
    selectedConsumer,
    selectedConsumerDetail,
    selectedEghu,
    actFiles,
    comparisonFiles,
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
