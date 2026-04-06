class WorkingWithStampsModel {
  final int id;
  final String region;
  final String district;
  final String employee;
  final String? consumers;
  final DateTime datetime;

  WorkingWithStampsModel({
    required this.id,
    required this.region,
    required this.district,
    required this.employee,
    this.consumers,
    required this.datetime,
  });

  factory WorkingWithStampsModel.fromJson(Map<String, dynamic> json) {
    return WorkingWithStampsModel(
      id: json["id"],
      region: json["region"] ?? "-",
      district: json["district"] ?? "-",
      employee: json["employee"] ?? "-",
      consumers: json["consumers"], // optional
      datetime: DateTime.parse(json["datetime"]),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "region": region,
      "district": district,
      "employee": employee,
      "consumers": consumers,
      "datetime": datetime.toIso8601String(),
    };
  }
}
