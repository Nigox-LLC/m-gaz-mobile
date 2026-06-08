import 'package:equatable/equatable.dart';

class TeachMeasureGtsh extends Equatable {
  final int? id;
  final String? name;

  const TeachMeasureGtsh({required this.id, required this.name});

  factory TeachMeasureGtsh.fromJson(Map<String, dynamic> json) {
    return TeachMeasureGtsh(
      id: json['id'] as int?,
      name: json['name'] as String?,
    );
  }

  @override
  List<Object?> get props => [id, name];
}