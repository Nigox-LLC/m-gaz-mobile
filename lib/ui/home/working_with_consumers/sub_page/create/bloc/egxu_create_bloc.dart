import 'package:flutter_bloc/flutter_bloc.dart';
import '../widget/egxu_item.dart';
import 'egxu_create_event.dart';
import 'egxu_create_state.dart';

class ConsumerCreateBloc extends Bloc<ConsumerCreateEvent, ConsumerCreateState> {
  ConsumerCreateBloc() : super(const ConsumerCreateState()) {
    on<ConsumerCreateStarted>(_onStarted);
    on<ConsumerConsumerSelected>(_onConsumerSelected);
    on<ConsumerCreateNextStep>(_onNextStep);
    on<ConsumerCreatePreviousStep>(_onPreviousStep);
    on<ConsumerItemAdded>(_onEgxuAdded);
    on<ConsumerTamgaAdded>(_onTamgaAdded);
    on<ConsumerGazAdded>(_onGazAdded);
    on<ConsumerStep2DataSubmitted>(_onStep2DataSubmitted);
    on<ConsumerStep3DataSubmitted>(_onStep3DataSubmitted);

    // Yangi eventlar (agar kerak bo'lsa)
    // on<ConsumerEgxuLoadStarted>(_onEgxuLoadStarted);
    // on<ConsumerEgxuLoadMore>(_onEgxuLoadMore);
    // on<ConsumerStampLoadStarted>(_onStampLoadStarted);
    // on<ConsumerGazLoadStarted>(_onGazLoadStarted);
  }

  void _onStarted(ConsumerCreateStarted event, Emitter<ConsumerCreateState> emit) {
    emit(state.copyWith(generalStatus: ConsumerGeneralStatus.initial));
  }

  void _onConsumerSelected(
      ConsumerConsumerSelected event, Emitter<ConsumerCreateState> emit) {
    emit(state.copyWith(
      selectedConsumer: event.consumer,
      step1Status: ConsumerStepStatus.success,
    ));
  }

  void _onNextStep(ConsumerCreateNextStep event, Emitter<ConsumerCreateState> emit) {
    // Step 0 validation
    if (state.currentStep == 0) {
      if (state.selectedConsumer == null) {
        emit(state.copyWith(
          step1Status: ConsumerStepStatus.failure,
          errorMessage: "Iltimos, iste'molchini tanlang",
        ));
        return;
      }
      emit(state.copyWith(step1Status: ConsumerStepStatus.success));
    }

    // Step 1 validation
    if (state.currentStep == 1) {
      if (state.egxuList.isEmpty) {
        emit(state.copyWith(
          step2Status: ConsumerStepStatus.failure,
          errorMessage: "Kamida bitta EGHU qo'shing",
        ));
        return;
      }
      emit(state.copyWith(step2Status: ConsumerStepStatus.success));
    }

    // Step 2 validation (optional)
    if (state.currentStep == 2) {
      emit(state.copyWith(step3Status: ConsumerStepStatus.success));
    }

    // Navigate to next step
    if (state.currentStep < 3) {
      final nextStep = state.currentStep + 1;
      emit(state.copyWith(
        currentStep: nextStep,
        errorMessage: null, // Clear error on step change
      ));
    }
  }

  void _onPreviousStep(
      ConsumerCreatePreviousStep event, Emitter<ConsumerCreateState> emit) {
    if (state.currentStep > 0) {
      emit(state.copyWith(
        currentStep: state.currentStep - 1,
        errorMessage: null, // Clear error on step change
      ));
    }
  }

  void _onEgxuAdded(ConsumerItemAdded event, Emitter<ConsumerCreateState> emit) {
    final list = List<EgxuItem>.from(state.egxuList)..add(event.item);
    emit(state.copyWith(
      egxuList: list,
      step2Status: list.isNotEmpty ? ConsumerStepStatus.success : ConsumerStepStatus.initial,
    ));
  }

  void _onTamgaAdded(ConsumerTamgaAdded event, Emitter<ConsumerCreateState> emit) {
    final list = List<StampModel>.from(state.tamgaList)..add(event.item);
    emit(state.copyWith(
      tamgaList: list,
      stampStatus: list.isNotEmpty ? StampStatus.loaded : StampStatus.initial,
    ));
  }

  void _onGazAdded(ConsumerGazAdded event, Emitter<ConsumerCreateState> emit) {
    final list = List<GazUsageResult>.from(state.gazList)..add(event.item);
    emit(state.copyWith(
      gazList: list,
      gazStatus: list.isNotEmpty ? GazStatus.loaded : GazStatus.initial,
    ));
  }

  void _onStep2DataSubmitted(
      ConsumerStep2DataSubmitted event, Emitter<ConsumerCreateState> emit) {
    emit(state.copyWith(
      step2Data: event.data,
      step2Status: ConsumerStepStatus.success,
    ));
  }

  void _onStep3DataSubmitted(
      ConsumerStep3DataSubmitted event, Emitter<ConsumerCreateState> emit) {
    emit(state.copyWith(
      step3Data: event.data,
      step3Status: ConsumerStepStatus.success,
    ));
  }

  // // ============= EGXU Loading =============
  // Future<void> _onEgxuLoadStarted(
  //     ConsumerEgxuLoadStarted event, Emitter<ConsumerCreateState> emit) async {
  //   emit(state.copyWith(
  //     egxuStatus: EgxuStatus.loading,
  //     clearEgxuList: true,
  //   ));
  //
  //   try {
  //     // API call
  //     final response = await _api.getEgxuList(limit: 20);
  //
  //     emit(state.copyWith(
  //       egxuStatus: EgxuStatus.loaded,
  //       egxuList: response.results,
  //       hasMoreEgxu: response.hasMore,
  //     ));
  //   } catch (e) {
  //     emit(state.copyWith(
  //       egxuStatus: EgxuStatus.failure,
  //       errorMessage: e.toString(),
  //     ));
  //   }
  // }
  //
  // Future<void> _onEgxuLoadMore(
  //     ConsumerEgxuLoadMore event, Emitter<ConsumerCreateState> emit) async {
  //   if (state.isLoadingMoreEgxu || !state.hasMoreEgxu) return;
  //
  //   emit(state.copyWith(
  //     egxuStatus: EgxuStatus.loadingMore,
  //     isLoadingMoreEgxu: true,
  //   ));
  //
  //   try {
  //     final response = await _api.getEgxuList(offset: state.egxuList.length);
  //
  //     emit(state.copyWith(
  //       egxuStatus: EgxuStatus.loaded,
  //       appendEgxu: true,
  //       egxuList: response.results,
  //       hasMoreEgxu: response.hasMore,
  //       isLoadingMoreEgxu: false,
  //     ));
  //   } catch (e) {
  //     emit(state.copyWith(
  //       egxuStatus: EgxuStatus.failure,
  //       errorMessage: e.toString(),
  //       isLoadingMoreEgxu: false,
  //     ));
  //   }
  // }
  //
  // // ============= Stamp Loading =============
  // Future<void> _onStampLoadStarted(
  //     ConsumerStampLoadStarted event, Emitter<ConsumerCreateState> emit) async {
  //   emit(state.copyWith(stampStatus: StampStatus.loading));
  //
  //   try {
  //     final response = await _api.getStamps();
  //     emit(state.copyWith(
  //       stampStatus: StampStatus.loaded,
  //       tamgaList: response,
  //     ));
  //   } catch (e) {
  //     emit(state.copyWith(
  //       stampStatus: StampStatus.failure,
  //       errorMessage: e.toString(),
  //     ));
  //   }
  // }
  //
  // // ============= Gaz Loading =============
  // Future<void> _onGazLoadStarted(
  //     ConsumerGazLoadStarted event, Emitter<ConsumerCreateState> emit) async {
  //   emit(state.copyWith(gazStatus: GazStatus.loading));
  //
  //   try {
  //     final response = await _api.getGazList();
  //     emit(state.copyWith(
  //       gazStatus: GazStatus.loaded,
  //       gazList: response,
  //     ));
  //   } catch (e) {
  //     emit(state.copyWith(
  //       gazStatus: GazStatus.failure,
  //       errorMessage: e.toString(),
  //     ));
  //   }
  // }
}