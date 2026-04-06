class TechnologicalMeasuringDocument {
  final int id;
  final String region;
  final String district;
  final String employee;
  final String gtsh;
  final String techno;
  final DateTime datetime;

  TechnologicalMeasuringDocument({
    required this.id,
    required this.region,
    required this.district,
    required this.employee,
    required this.gtsh,
    required this.techno,
    required this.datetime,
  });

  factory TechnologicalMeasuringDocument.fromJson(Map<String, dynamic> json) {
    return TechnologicalMeasuringDocument(
      id: json['id'],
      region: json['region'],
      district: json['district'],
      employee: json['employee'],
      gtsh: json['gtsh'],
      techno: json['techno_measuring_devices'],
      datetime: DateTime.parse(json['datetime']),
    );
  }
}
