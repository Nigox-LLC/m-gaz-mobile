class Region {
  final int? id;
  final String? name;

  Region({this.id, this.name});

  factory Region.fromJson(Map<String, dynamic>? json) {
    if (json == null) return Region();
    return Region(id: _intValue(json['id']), name: json['name']?.toString());
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'name': name};
  }
}

class District {
  final int? id;
  final String? name;

  District({this.id, this.name});

  factory District.fromJson(Map<String, dynamic>? json) {
    if (json == null) return District();
    return District(id: _intValue(json['id']), name: json['name']?.toString());
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'name': name};
  }
}

class Employee {
  final int? id;
  final String? fio;

  Employee({this.id, this.fio});

  factory Employee.fromJson(Map<String, dynamic>? json) {
    if (json == null) return Employee();
    return Employee(id: _intValue(json['id']), fio: json['fio']?.toString());
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'fio': fio};
  }
}

class Consumers {
  final int? id;
  final String? name;

  Consumers({this.id, this.name});

  factory Consumers.fromJson(Map<String, dynamic>? json) {
    if (json == null) return Consumers();
    return Consumers(id: _intValue(json['id']), name: json['name']?.toString());
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'name': name};
  }
}

int? _intValue(Object? value) {
  if (value is num) return value.toInt();
  return int.tryParse(value?.toString() ?? '');
}
