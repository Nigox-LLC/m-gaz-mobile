import 'package:equatable/equatable.dart';

/// Umumiy dictionary modeli
class GlobalModel extends Equatable {
  final int? id;
  final String? fio;
  final String? name;

  const GlobalModel({this.id, this.fio, this.name});

  factory GlobalModel.fromJson(Map<String, dynamic> json) {
    return GlobalModel(
      id: json['id'] as int?,
      fio: json['fio'] as String?,
      name: json['name'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'fio': fio,
      'name': name,
    };
  }

  @override
  List<Object?> get props => [id, fio, name];
}