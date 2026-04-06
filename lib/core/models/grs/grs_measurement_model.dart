class GrsMeasurementModel {
  final int id;
  final String region;
  final String district;
  final String employee;
  final String gtsh;
  final DateTime dateTime;

  GrsMeasurementModel({
    required this.id,
    required this.region,
    required this.district,
    required this.employee,
    required this.gtsh,
    required this.dateTime,
  });

  factory GrsMeasurementModel.fromJson(Map<String, dynamic> json) {
    return GrsMeasurementModel(
      id: json['id'] as int,
      region: json['region'] as String,
      district: json['district'] as String,
      employee: json['employee'] as String,
      gtsh: json['gtsh'] as String,
      dateTime: DateTime.parse(json['datetime']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'region': region,
      'district': district,
      'employee': employee,
      'gtsh': gtsh,
      'datetime': dateTime.toIso8601String(),
    };
  }
}
