class EgxuListModel {
  final int id;
  final String name;
  final String photo;
  final double maxGas;
  final double minGas;
  final bool isStg;
  final bool isAutopilot;
  final bool isFlowGas;
  final bool isPresidentIds;

  EgxuListModel({
    required this.id,
    required this.name,
    required this.photo,
    required this.maxGas,
    required this.minGas,
    required this.isStg,
    required this.isAutopilot,
    required this.isFlowGas,
    required this.isPresidentIds,
  });

  factory EgxuListModel.fromJson(Map<String, dynamic> json) {
    return EgxuListModel(
      id: json["id"] ?? 0,
      name: json["name"] ?? "",
      photo: json["photo"] ?? "",
      maxGas: (json["max_gas"] ?? 0).toDouble(),
      minGas: (json["min_gas"] ?? 0).toDouble(),
      isStg: json["is_stg"] ?? false,
      isAutopilot: json["is_avtopilot"] ?? false,
      isFlowGas: json["is_flow_gas"] ?? false,
      isPresidentIds: json["is_president_ids"] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "name": name,
      "photo": photo,
      "max_gas": maxGas,
      "min_gas": minGas,
      "is_stg": isStg,
      "is_avtopilot": isAutopilot,
      "is_flow_gas": isFlowGas,
      "is_president_ids": isPresidentIds,
    };
  }
}
