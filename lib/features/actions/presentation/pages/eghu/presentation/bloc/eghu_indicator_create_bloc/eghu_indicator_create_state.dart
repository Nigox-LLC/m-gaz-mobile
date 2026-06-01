part of 'eghu_indicator_create_bloc.dart';

enum EghuIndicatorSubmitStatus { initial, submitting, success, failure }

class EghuIndicatorCreateState extends Equatable {
  const EghuIndicatorCreateState({
    this.selectedConsumer,
    this.selectedConsumerDetail,
    this.selectedEghu,
    this.value = '',
    this.basicFile,
    this.printFile,
    this.employeeName,
    this.status = EghuIndicatorSubmitStatus.initial,
    this.errorMessage = '',
    this.lastSubmittedRequest,
  });

  final WorkingWithConsumersList? selectedConsumer;
  final WorkingWithConsumersDetailModel? selectedConsumerDetail;
  final ConsumersEgxuItem? selectedEghu;
  final String value;
  final EghuActionAttachment? basicFile;
  final EghuActionAttachment? printFile;
  final String? employeeName;
  final EghuIndicatorSubmitStatus status;
  final String errorMessage;
  final EghuIndicatorCreateRequest? lastSubmittedRequest;

  String get normalizedValue => normalizeEghuIndicatorValue(value);

  bool get hasValidValue {
    final normalized = normalizedValue;
    if (normalized.isEmpty) return false;
    final parsed = double.tryParse(normalized);
    return parsed != null && parsed > 0;
  }

  bool get canSubmit =>
      selectedConsumer != null &&
      selectedEghu?.id != null &&
      hasValidValue &&
      basicFile != null &&
      printFile != null &&
      status != EghuIndicatorSubmitStatus.submitting;

  EghuIndicatorCreateRequest? toRequest({required DateTime now}) {
    if (!canSubmit) return null;
    return EghuIndicatorCreateRequest(
      createdAt: now,
      value: normalizedValue,
      consumerId: selectedConsumer!.id,
      egxuId: selectedEghu!.id!,
      basicFile: basicFile!,
      printFile: printFile!,
    );
  }

  EghuIndicatorCreateState copyWith({
    WorkingWithConsumersList? selectedConsumer,
    WorkingWithConsumersDetailModel? selectedConsumerDetail,
    ConsumersEgxuItem? selectedEghu,
    String? value,
    EghuActionAttachment? basicFile,
    EghuActionAttachment? printFile,
    String? employeeName,
    EghuIndicatorSubmitStatus? status,
    String? errorMessage,
    EghuIndicatorCreateRequest? lastSubmittedRequest,
    bool clearSelectedEghu = false,
    bool clearSelectedConsumerDetail = false,
    bool clearBasicFile = false,
    bool clearPrintFile = false,
  }) {
    return EghuIndicatorCreateState(
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
      employeeName: employeeName ?? this.employeeName,
      status: status ?? this.status,
      errorMessage: errorMessage ?? this.errorMessage,
      lastSubmittedRequest: lastSubmittedRequest ?? this.lastSubmittedRequest,
    );
  }

  @override
  List<Object?> get props => [
    selectedConsumer,
    selectedConsumerDetail,
    selectedEghu,
    value,
    basicFile,
    printFile,
    employeeName,
    status,
    errorMessage,
    lastSubmittedRequest,
  ];
}
