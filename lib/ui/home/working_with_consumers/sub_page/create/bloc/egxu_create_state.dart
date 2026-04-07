import 'package:equatable/equatable.dart';
import '../../../../../../../core/models/global/global_model.dart';
import '../widget/egxu_item.dart';

// Alohida statuslar har bir ma'lumot turi uchun
enum ConsumerGeneralStatus { initial, loading, success, failure }
enum ConsumerStepStatus { initial, loading, success, failure }
enum EgxuStatus { initial, loading, loaded, loadingMore, failure }
enum StampStatus { initial, loading, loaded, failure }
enum GazStatus { initial, loading, loaded, failure }

class ConsumerCreateState extends Equatable {
  // Umumiy status
  final ConsumerGeneralStatus generalStatus;
  final String? errorMessage;

  // Step statuslari alohida
  final ConsumerStepStatus step1Status;
  final ConsumerStepStatus step2Status;
  final ConsumerStepStatus step3Status;
  final int currentStep;

  // Ma'lumotlar statuslari alohida
  final EgxuStatus egxuStatus;
  final StampStatus stampStatus;
  final GazStatus gazStatus;

  // Ma'lumotlar
  final GlobalModel? selectedConsumer;
  final List<EgxuItem> egxuList;
  final List<StampModel> tamgaList;
  final List<GazUsageResult> gazList;

  // Step ma'lumotlari
  final Map<String, dynamic>? step1Data;
  final Map<String, dynamic>? step2Data;
  final Map<String, dynamic>? step3Data;

  // Pagination
  final bool hasMoreEgxu;
  final bool isLoadingMoreEgxu;

  const ConsumerCreateState({
    this.generalStatus = ConsumerGeneralStatus.initial,
    this.errorMessage,
    this.step1Status = ConsumerStepStatus.initial,
    this.step2Status = ConsumerStepStatus.initial,
    this.step3Status = ConsumerStepStatus.initial,
    this.currentStep = 0,
    this.egxuStatus = EgxuStatus.initial,
    this.stampStatus = StampStatus.initial,
    this.gazStatus = GazStatus.initial,
    this.selectedConsumer,
    this.egxuList = const [],
    this.tamgaList = const [],
    this.gazList = const [],
    this.step1Data,
    this.step2Data,
    this.step3Data,
    this.hasMoreEgxu = false,
    this.isLoadingMoreEgxu = false,
  });

  // Helper getterlar
  bool get isLoading => generalStatus == ConsumerGeneralStatus.loading;
  bool get isSuccess => generalStatus == ConsumerGeneralStatus.success;
  bool get isFailure => generalStatus == ConsumerGeneralStatus.failure;

  bool get isStep1Loading => step1Status == ConsumerStepStatus.loading;
  bool get isStep2Loading => step2Status == ConsumerStepStatus.loading;
  bool get isStep3Loading => step3Status == ConsumerStepStatus.loading;

  bool get isEgxuLoading => egxuStatus == EgxuStatus.loading;
  bool get isEgxuLoaded => egxuStatus == EgxuStatus.loaded;
  bool get isEgxuLoadingMore => egxuStatus == EgxuStatus.loadingMore;

  bool get isStampLoading => stampStatus == StampStatus.loading;
  bool get isGazLoading => gazStatus == GazStatus.loading;

  ConsumerCreateState copyWith({
    ConsumerGeneralStatus? generalStatus,
    String? errorMessage,
    ConsumerStepStatus? step1Status,
    ConsumerStepStatus? step2Status,
    ConsumerStepStatus? step3Status,
    int? currentStep,
    EgxuStatus? egxuStatus,
    StampStatus? stampStatus,
    GazStatus? gazStatus,
    GlobalModel? selectedConsumer,
    List<EgxuItem>? egxuList,
    List<StampModel>? tamgaList,
    List<GazUsageResult>? gazList,
    Map<String, dynamic>? step1Data,
    Map<String, dynamic>? step2Data,
    Map<String, dynamic>? step3Data,
    bool? hasMoreEgxu,
    bool? isLoadingMoreEgxu,
    bool clearEgxuList = false,
    bool clearTamgaList = false,
    bool clearGazList = false,
    bool appendEgxu = false,
  }) {
    return ConsumerCreateState(
      generalStatus: generalStatus ?? this.generalStatus,
      errorMessage: errorMessage ?? this.errorMessage,
      step1Status: step1Status ?? this.step1Status,
      step2Status: step2Status ?? this.step2Status,
      step3Status: step3Status ?? this.step3Status,
      currentStep: currentStep ?? this.currentStep,
      egxuStatus: egxuStatus ?? this.egxuStatus,
      stampStatus: stampStatus ?? this.stampStatus,
      gazStatus: gazStatus ?? this.gazStatus,
      selectedConsumer: selectedConsumer ?? this.selectedConsumer,
      egxuList: clearEgxuList
          ? const []
          : appendEgxu
          ? [...this.egxuList, ...(egxuList ?? [])]
          : (egxuList ?? this.egxuList),
      tamgaList: clearTamgaList
          ? const []
          : (tamgaList ?? this.tamgaList),
      gazList: clearGazList
          ? const []
          : (gazList ?? this.gazList),
      step1Data: step1Data ?? this.step1Data,
      step2Data: step2Data ?? this.step2Data,
      step3Data: step3Data ?? this.step3Data,
      hasMoreEgxu: hasMoreEgxu ?? this.hasMoreEgxu,
      isLoadingMoreEgxu: isLoadingMoreEgxu ?? this.isLoadingMoreEgxu,
    );
  }

  @override
  List<Object?> get props => [
    generalStatus,
    errorMessage,
    step1Status,
    step2Status,
    step3Status,
    currentStep,
    egxuStatus,
    stampStatus,
    gazStatus,
    selectedConsumer,
    egxuList,
    tamgaList,
    gazList,
    step1Data,
    step2Data,
    step3Data,
    hasMoreEgxu,
    isLoadingMoreEgxu,
  ];
}