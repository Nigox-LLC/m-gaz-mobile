class GrsEgxuType {
  final int? id;
  final String? name;
  final String? photo;
  final bool? isStg;
  final bool? isAvtopilot;
  final bool? isFlowGas;
  final bool? isPresidentIds;

  GrsEgxuType({
    this.id,
    this.name,
    this.photo,
    this.isStg,
    this.isAvtopilot,
    this.isFlowGas,
    this.isPresidentIds,
  });

  factory GrsEgxuType.fromJson(Map<String, dynamic>? json) {
    if (json == null) return GrsEgxuType();
    return GrsEgxuType(
      id: json['id'],
      name: json['name'],
      photo: json['photo'],
      isStg: json['is_stg'],
      isAvtopilot: json['is_avtopilot'],
      isFlowGas: json['is_flow_gas'],
      isPresidentIds: json['is_president_ids'],
    );
  }
}