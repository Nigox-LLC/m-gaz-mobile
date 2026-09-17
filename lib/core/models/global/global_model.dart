import 'package:equatable/equatable.dart';

/// Umumiy dictionary modeli
class GlobalModel extends Equatable {
  final int? id;
  final String? fio;
  final String? name;

  const GlobalModel({this.id, this.fio, this.name});

  factory GlobalModel.fromJson(Map<String, dynamic> json) {
    return GlobalModel(
      id: _asInt(json['id']),
      fio: json['fio']?.toString(),
      name: json['name']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'fio': fio, 'name': name};
  }

  @override
  List<Object?> get props => [id, fio, name];
}

int? _asInt(Object? value) {
  if (value is num) return value.toInt();
  return int.tryParse(value?.toString() ?? '');
}
