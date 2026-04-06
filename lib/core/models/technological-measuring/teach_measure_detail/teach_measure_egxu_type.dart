import 'package:equatable/equatable.dart';

class TeachMeasureEgxuType extends Equatable {
  final int id;
  final String name;

  const TeachMeasureEgxuType({required this.id, required this.name});

  factory TeachMeasureEgxuType.fromJson(Map<String, dynamic> json) {
    return TeachMeasureEgxuType(
      id: json['id'] as int,
      name: json['name'] as String,
    );
  }

  @override
  List<Object?> get props => [id, name];
}