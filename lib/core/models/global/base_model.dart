class Region {
  final int? id;
  final String? name;

  Region({this.id, this.name});

  factory Region.fromJson(Map<String, dynamic>? json) {
    if (json == null) return Region();
    return Region(
      id: json['id'],
      name: json['name'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
    };
  }
}

class District {
  final int? id;
  final String? name;

  District({this.id, this.name});

  factory District.fromJson(Map<String, dynamic>? json) {
    if (json == null) return District();
    return District(
      id: json['id'],
      name: json['name'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
    };
  }
}

class Employee {
  final int? id;
  final String? fio;

  Employee({this.id, this.fio});

  factory Employee.fromJson(Map<String, dynamic>? json) {
    if (json == null) return Employee();
    return Employee(
      id: json['id'],
      fio: json['fio'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'fio': fio,
    };
  }
}

class Consumers {
  final int? id;
  final String? name;

  Consumers({this.id, this.name});

  factory Consumers.fromJson(Map<String, dynamic>? json) {
    if (json == null) return Consumers();
    return Consumers(
      id: json['id'],
      name: json['name'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
    };
  }
}