class GrsGtsh {
  final int? id;
  final String? name;

  GrsGtsh({this.id, this.name});

  factory GrsGtsh.fromJson(Map<String, dynamic>? json) {
    if (json == null) return GrsGtsh();
    return GrsGtsh(id: json['id'], name: json['name']);
  }
}