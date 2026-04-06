class GrsConnectionPoint {
  final int? id;
  final String? name;

  GrsConnectionPoint({this.id, this.name});

  factory GrsConnectionPoint.fromJson(Map<String, dynamic>? json) {
    if (json == null) return GrsConnectionPoint();
    return GrsConnectionPoint(id: json['id'], name: json['name']);
  }
}