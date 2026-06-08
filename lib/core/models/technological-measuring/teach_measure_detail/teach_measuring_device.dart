import 'package:equatable/equatable.dart';

class TechnoMeasuringDevices extends Equatable {
  final int? id;
  final String? name;

  const TechnoMeasuringDevices({required this.id, required this.name});

  factory TechnoMeasuringDevices.fromJson(Map<String, dynamic> json) {
    return TechnoMeasuringDevices(
      id: json['id'] as int?,
      name: json['name'] as String?,
    );
  }

  @override
  List<Object?> get props => [id, name];
}