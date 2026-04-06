import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/api/attendance/attendance_api.dart';
import '../../../../di.dart';
import 'attendance_event.dart';
import 'attendance_state.dart';

class AttendanceBloc extends Bloc<AttendanceEvent, AttendanceState> {
  final AttendanceApi api = di.get<AttendanceApi>();

  AttendanceBloc() : super(const AttendanceState()) {
    on<AttendancePickPhoto>(_onPickPhoto);
    on<AttendanceSubmit>(_onSubmit);
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
