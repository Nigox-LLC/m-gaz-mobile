import 'package:equatable/equatable.dart';
import '../../../../../../../core/models/global/global_model.dart';
import '../widget/egxu_item.dart';


enum ConsumerCreateStatus { initial, loading, success, failure }

class ConsumerCreateState extends Equatable {
  final ConsumerCreateStatus status;
  final int currentStep;
  final GlobalModel? selectedConsumer;
  final List<EgxuItem> egxuList;
  final List<StampModel> tamgaList;
  final List<GazUsageResult> gazList;
  final Map<String, dynamic>? step2Data;
  final Map<String, dynamic>? step3Data;
  final String? errorMessage;

  const ConsumerCreateState({
    this.status = ConsumerCreateStatus.initial,
    this.currentStep = 0,
    this.selectedConsumer,
    this.egxuList = const [],
    this.tamgaList = const [],
    this.gazList = const [],
    this.step2Data,
    this.step3Data,
    this.errorMessage,
  });

  ConsumerCreateState copyWith({
    ConsumerCreateStatus? status,
    int? currentStep,
    GlobalModel? selectedConsumer,
    List<EgxuItem>? egxuList,
    List<StampModel>? tamgaList,
    List<GazUsageResult>? gazList,
    Map<String, dynamic>? step2Data,
    Map<String, dynamic>? step3Data,
    String? errorMessage,
  }) {
    return ConsumerCreateState(
      status: status ?? this.status,
      currentStep: currentStep ?? this.currentStep,
      selectedConsumer: selectedConsumer ?? this.selectedConsumer,
      egxuList: egxuList ?? this.egxuList,
      tamgaList: tamgaList ?? this.tamgaList,
      gazList: gazList ?? this.gazList,
      step2Data: step2Data ?? this.step2Data,
      step3Data: step3Data ?? this.step3Data,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [
        status,
        currentStep,
        selectedConsumer,
        egxuList,
        tamgaList,
        gazList,
        step2Data,
        step3Data,
        errorMessage,
      ];
}
