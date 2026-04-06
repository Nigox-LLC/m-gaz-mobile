import 'dart:io';
import 'package:equatable/equatable.dart';

abstract class AttendanceEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class AttendancePickPhoto extends AttendanceEvent {
  final File photo;
  AttendancePickPhoto(this.photo);

  @override
  List<Object?> get props => [photo];
}

class AttendanceSubmit extends AttendanceEvent {
  final File photo;
  final Map<String, dynamic>? data;

  AttendanceSubmit({required this.photo, this.data});

  @override
  List<Object?> get props => [photo, data];
}
