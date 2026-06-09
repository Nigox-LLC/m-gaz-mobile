import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/api/attendance/attendance_api.dart';
import '../../../../di.dart';
import 'attendance_event.dart';
import 'attendance_state.dart';

class AttendanceBloc extends Bloc<AttendanceEvent, AttendanceState> {
  final AttendanceApi api;

  AttendanceBloc({AttendanceApi? api})
      : api = api ?? di.get<AttendanceApi>(),
        super(const AttendanceState()) {
    on<AttendanceCheckAccess>(_onCheckAccess);
    on<AttendancePickPhoto>(_onPickPhoto);
    on<AttendanceSubmit>(_onSubmit);
  }

  Future<void> _onCheckAccess(
      AttendanceCheckAccess event, Emitter<AttendanceState> emit) async {
    emit(state.copyWith(status: AttendanceStatus.checking, error: null));

    try {
      final attended = await api.checkAlreadyAttended();
      emit(
        state.copyWith(
          status: attended
              ? AttendanceStatus.accessBlocked
              : AttendanceStatus.accessAllowed,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          status: AttendanceStatus.fail,
          error: e.toString().replaceAll("Exception: ", ""),
        ),
      );
    }
  }

  Future<void> _onPickPhoto(
      AttendancePickPhoto event, Emitter<AttendanceState> emit) async {
    emit(
      state.copyWith(
        status: AttendanceStatus.picked,
        pickedPhoto: event.photo,
      ),
    );
  }

  Future<void> _onSubmit(
      AttendanceSubmit event, Emitter<AttendanceState> emit) async {
    emit(state.copyWith(status: AttendanceStatus.uploading));

    try {
      final resp = await api.sendAttendance(
        photo: event.photo,
        data: event.data,
      );

      emit(
        state.copyWith(
          status: AttendanceStatus.success,
          response: resp,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          status: AttendanceStatus.fail,
          error: e.toString().replaceAll("Exception: ", ""),
        ),
      );
    }
  }
}
