part of 'eghu_indicator_detail_bloc.dart';

enum EghuIndicatorDetailStatus {
  initial,
  loading,
  success,
  failure,
  submitting,
  submitFailure,
  successSaved,
}

class EghuIndicatorDetailState extends Equatable {
  const EghuIndicatorDetailState({
    required this.id,
    this.initialConsumerId,
    this.initialEghuId,
    this.initialValue = '',
    this.selectedConsumer,
    this.selectedConsumerDetail,
    this.selectedEghu,
    this.value = '',
    this.basicFile,
    this.printFile,
    this.basicFileId,
    this.printFileId,
    this.basicFileChanged = false,
    this.printFileChanged = false,
    this.employeeName,
    this.status = EghuIndicatorDetailStatus.initial,
    this.errorMessage = '',
    this.lastSubmittedRequest,
  });

  factory EghuIndicatorDetailState.fromDocument(
    EghuIndicatorDocument document,
    String? employeeName,
  ) {
    final basicFile = document.fileByType('basic');
    final printFile = document.fileByType('print');
    final normalizedValue = normalizeEghuIndicatorValue(document.value);

    return EghuIndicatorDetailState(
      id: document.id,
      initialConsumerId: document.consumerId,
      initialEghuId: document.egxuId,
      initialValue: normalizedValue,
      selectedConsumer: _consumerStub(document),
      selectedEghu: _eghuStub(document),
      value: normalizedValue,
      basicFile: _attachmentFromFile(basicFile),
      printFile: _attachmentFromFile(printFile),
      basicFileId: basicFile?.id,
      printFileId: printFile?.id,
      employeeName: employeeName,
      status: EghuIndicatorDetailStatus.success,
    );
  }

  final int id;
  final int? initialConsumerId;
  final int? initialEghuId;
  final String initialValue;
  final WorkingWithConsumersList? selectedConsumer;
  final WorkingWithConsumersDetailModel? selectedConsumerDetail;
  final ConsumersEgxuItem? selectedEghu;
  final String value;
  final EghuActionAttachment? basicFile;
  final EghuActionAttachment? printFile;
  final int? basicFileId;
  final int? printFileId;
  final bool basicFileChanged;
  final bool printFileChanged;
  final String? employeeName;
  final EghuIndicatorDetailStatus status;
  final String errorMessage;
  final EghuIndicatorUpdateRequest? lastSubmittedRequest;

  String get normalizedValue => normalizeEghuIndicatorValue(value);

  bool get hasValidValue {
    final normalized = normalizedValue;
    if (normalized.isEmpty) return false;
    final parsed = double.tryParse(normalized);
    return parsed != null && parsed > 0;
  }

  bool get mainChanged =>
      selectedConsumer?.id != initialConsumerId ||
      selectedEghu?.id != initialEghuId ||
      normalizedValue != initialValue;

  bool get isDirty => mainChanged || basicFileChanged || printFileChanged;

  bool get canSubmit =>
      status != EghuIndicatorDetailStatus.loading &&
      status != EghuIndicatorDetailStatus.submitting &&
      selectedConsumer != null &&
      selectedEghu?.id != null &&
      hasValidValue &&
      basicFile != null &&
      printFile != null &&
      isDirty;

  EghuIndicatorUpdateRequest? toRequest() {
    if (!canSubmit) return null;
    return EghuIndicatorUpdateRequest(
      id: id,
      value: normalizedValue,
      consumerId: selectedConsumer!.id,
      egxuId: selectedEghu!.id!,
      mainChanged: mainChanged,
      basicFileChanged: basicFileChanged && basicFile?.isRemote != true,
      printFileChanged: printFileChanged && printFile?.isRemote != true,
      basicFile: basicFile,
      printFile: printFile,
      basicFileId: basicFileId,
      printFileId: printFileId,
    );
  }

  EghuIndicatorDetailState copyWith({
    int? initialConsumerId,
    int? initialEghuId,
    String? initialValue,
    WorkingWithConsumersList? selectedConsumer,
    WorkingWithConsumersDetailModel? selectedConsumerDetail,
    ConsumersEgxuItem? selectedEghu,
    String? value,
    EghuActionAttachment? basicFile,
    EghuActionAttachment? printFile,
    int? basicFileId,
    int? printFileId,
    bool? basicFileChanged,
    bool? printFileChanged,
    String? employeeName,
    EghuIndicatorDetailStatus? status,
    String? errorMessage,
    EghuIndicatorUpdateRequest? lastSubmittedRequest,
    bool clearSelectedEghu = false,
    bool clearSelectedConsumerDetail = false,
    bool clearBasicFile = false,
    bool clearPrintFile = false,
  }) {
    return EghuIndicatorDetailState(
      id: id,
      initialConsumerId: initialConsumerId ?? this.initialConsumerId,
      initialEghuId: initialEghuId ?? this.initialEghuId,
      initialValue: initialValue ?? this.initialValue,
      selectedConsumer: selectedConsumer ?? this.selectedConsumer,
      selectedConsumerDetail: clearSelectedConsumerDetail
          ? null
          : (selectedConsumerDetail ?? this.selectedConsumerDetail),
      selectedEghu: clearSelectedEghu
          ? null
          : (selectedEghu ?? this.selectedEghu),
      value: value ?? this.value,
      basicFile: clearBasicFile ? null : (basicFile ?? this.basicFile),
      printFile: clearPrintFile ? null : (printFile ?? this.printFile),
      basicFileId: basicFileId ?? this.basicFileId,
      printFileId: printFileId ?? this.printFileId,
      basicFileChanged: basicFileChanged ?? this.basicFileChanged,
      printFileChanged: printFileChanged ?? this.printFileChanged,
      employeeName: employeeName ?? this.employeeName,
      status: status ?? this.status,
      errorMessage: errorMessage ?? this.errorMessage,
      lastSubmittedRequest: lastSubmittedRequest ?? this.lastSubmittedRequest,
    );
  }

  @override
  List<Object?> get props => [
    id,
    initialConsumerId,
    initialEghuId,
    initialValue,
    selectedConsumer,
    selectedConsumerDetail,
    selectedEghu,
    value,
    basicFile,
    printFile,
    basicFileId,
    printFileId,
    basicFileChanged,
    printFileChanged,
    employeeName,
    status,
    errorMessage,
    lastSubmittedRequest,
  ];
}

extension on EghuIndicatorDocument {
  EghuIndicatorFileDocument? fileByType(String type) {
    for (final file in files) {
      if (file.fileType == type) return file;
    }
    return null;
  }
}

WorkingWithConsumersList _consumerStub(EghuIndicatorDocument document) {
  return WorkingWithConsumersList(
    id: document.consumerId,
    region: document.region,
    district: document.district,
    employee: document.employee,
    consumers: document.consumerName,
    facial: document.personalAccount,
    datetime: document.createdAt,
    excelId: '',
  );
}

ConsumersEgxuItem _eghuStub(EghuIndicatorDocument document) {
  return ConsumersEgxuItem(
    id: document.egxuId,
    oneFactory: document.factoryNumber,
    egxuType: ConsumersEgxuType(name: document.egxuType),
  );
}

EghuActionAttachment? _attachmentFromFile(EghuIndicatorFileDocument? file) {
  final url = file?.file.trim();
  if (url == null || url.isEmpty) return null;
  final name = _fileNameFromUrl(url);
  return EghuActionAttachment.remote(
    url: url,
    name: name,
    isImage: _isImageName(name),
    aktId: file!.id,
    createdAt: file.createdAt,
  );
}

String _fileNameFromUrl(String url) {
  final cleaned = url.split('?').first;
  final segment = cleaned.split('/').where((e) => e.isNotEmpty).toList();
  if (segment.isEmpty) return 'file';
  return Uri.decodeComponent(segment.last);
}

bool _isImageName(String name) {
  final lower = name.toLowerCase();
  return lower.endsWith('.png') ||
      lower.endsWith('.jpg') ||
      lower.endsWith('.jpeg') ||
      lower.endsWith('.webp') ||
      lower.endsWith('.gif') ||
      lower.endsWith('.bmp') ||
      lower.endsWith('.heic');
}
