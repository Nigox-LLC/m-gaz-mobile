import 'package:flutter_bloc/flutter_bloc.dart';
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
  }

  void _onStarted(ConsumerCreateStarted event, Emitter<ConsumerCreateState> emit) {
    // Initial setup if needed, e.g. loading initial data
    emit(state.copyWith(status: ConsumerCreateStatus.initial));
  }

  void _onConsumerSelected(
      ConsumerConsumerSelected event, Emitter<ConsumerCreateState> emit) {
    emit(state.copyWith(selectedConsumer: event.consumer));
  }

  void _onNextStep(ConsumerCreateNextStep event, Emitter<ConsumerCreateState> emit) {
    if (state.currentStep == 0) {
      if (state.selectedConsumer == null) {
        emit(state.copyWith(errorMessage: "Iltimos, iste'molchini tanlang"));
        emit(state.copyWith(errorMessage: null)); // Clear error after emission
        return;
      }
    }

    if (state.currentStep == 1) {
      if (state.egxuList.isEmpty) {
        emit(state.copyWith(errorMessage: "Kamida bitta EGXU qo'shing"));
        emit(state.copyWith(errorMessage: null));
        return;
      }
    }

    if (state.currentStep < 3) {
      emit(state.copyWith(currentStep: state.currentStep + 1));
    }
  }

  void _onPreviousStep(
      ConsumerCreatePreviousStep event, Emitter<ConsumerCreateState> emit) {
    if (state.currentStep > 0) {
      emit(state.copyWith(currentStep: state.currentStep - 1));
    }
  }

  void _onEgxuAdded(ConsumerItemAdded event, Emitter<ConsumerCreateState> emit) {
    final list = List.of(state.egxuList)..add(event.item);
    emit(state.copyWith(egxuList: list));
  }

  void _onTamgaAdded(ConsumerTamgaAdded event, Emitter<ConsumerCreateState> emit) {
    final list = List.of(state.tamgaList)..add(event.item);
    emit(state.copyWith(tamgaList: list));
  }

  void _onGazAdded(ConsumerGazAdded event, Emitter<ConsumerCreateState> emit) {
    final list = List.of(state.gazList)..add(event.item);
    emit(state.copyWith(gazList: list));
  }

  void _onStep2DataSubmitted(
      ConsumerStep2DataSubmitted event, Emitter<ConsumerCreateState> emit) {
    emit(state.copyWith(step2Data: event.data));
  }

  void _onStep3DataSubmitted(
      ConsumerStep3DataSubmitted event, Emitter<ConsumerCreateState> emit) {
    emit(state.copyWith(step3Data: event.data));
  }
}
