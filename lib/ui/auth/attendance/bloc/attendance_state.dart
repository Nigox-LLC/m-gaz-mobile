import 'dart:io';
import 'package:equatable/equatable.dart';

enum AttendanceStatus { initial, picking, picked, uploading, success, fail }

class AttendanceState extends Equatable {
  final AttendanceStatus status;
  final File? pickedPhoto;
  final Map<String, dynamic>? response;
  final String? error;

  const AttendanceState({
    this.status = AttendanceStatus.initial,
    this.pickedPhoto,
    this.response,
    this.error,
  });

  AttendanceState copyWith({
    AttendanceStatus? status,
    File? pickedPhoto,
    Map<String, dynamic>? response,
    String? error,
  }) {
    return AttendanceState(
      status: status ?? this.status,
      pickedPhoto: pickedPhoto ?? this.pickedPhoto,
      response: response ?? this.response,
      error: error ?? this.error,
    );
  }

  @override
  List<Object?> get props => [status, pickedPhoto, response, error];
}
