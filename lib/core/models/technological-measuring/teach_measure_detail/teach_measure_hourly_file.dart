import 'package:equatable/equatable.dart';

class TeachMeasureHourlyFile extends Equatable {
  final int id;
  final String? file;
  final bool isActive;

  const TeachMeasureHourlyFile({
    required this.id,
    this.file,
    required this.isActive,
  });

  factory TeachMeasureHourlyFile.fromJson(Map<String, dynamic> json) {
    return TeachMeasureHourlyFile(
      id: json['id'] as int,
      file: json['file'] as String?,
      isActive: json['is_active'] as bool,
    );
  }

  @override
  List<Object?> get props => [id, file, isActive];
}