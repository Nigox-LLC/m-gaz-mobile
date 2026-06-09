import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:m_gaz/core/api/attendance/attendance_api.dart';
import 'package:m_gaz/ui/auth/attendance/bloc/attendance_bloc.dart';
import 'package:m_gaz/ui/auth/attendance/bloc/attendance_event.dart';
import 'package:m_gaz/ui/auth/attendance/bloc/attendance_state.dart';

void main() {
  group('AttendanceBloc access check', () {
    test('emits checking then accessAllowed when not attended', () {
      final bloc = AttendanceBloc(api: _FakeAttendanceApi(attended: false));

      expectLater(
        bloc.stream.map((s) => s.status),
        emitsInOrder([
          AttendanceStatus.checking,
          AttendanceStatus.accessAllowed,
        ]),
      );

      bloc.add(AttendanceCheckAccess());
    });

    test('emits checking then accessBlocked when already attended', () {
      final bloc = AttendanceBloc(api: _FakeAttendanceApi(attended: true));

      expectLater(
        bloc.stream.map((s) => s.status),
        emitsInOrder([
          AttendanceStatus.checking,
          AttendanceStatus.accessBlocked,
        ]),
      );

      bloc.add(AttendanceCheckAccess());
    });

    test('emits checking then fail when the GET throws', () {
      final bloc = AttendanceBloc(api: _FakeAttendanceApi(throwError: true));

      expectLater(
        bloc.stream.map((s) => s.status),
        emitsInOrder([
          AttendanceStatus.checking,
          AttendanceStatus.fail,
        ]),
      );

      bloc.add(AttendanceCheckAccess());
    });
  });
}

class _FakeAttendanceApi implements AttendanceApi {
  _FakeAttendanceApi({this.attended = false, this.throwError = false});

  final bool attended;
  final bool throwError;

  @override
  Future<bool> checkAlreadyAttended() async {
    if (throwError) throw Exception('boom');
    return attended;
  }

  @override
  Future<Map<String, dynamic>> sendAttendance({
    required File photo,
    Map<String, dynamic>? data,
  }) async => <String, dynamic>{};

  @override
  noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}
