class GrsHourlyIndicatorData {
  final int? id;
  final DateTime? timestamp;
  final double? pressure;
  final double? temperature;
  final double? mechanical;
  final double? correction;

  GrsHourlyIndicatorData({
    this.id,
    this.timestamp,
    this.pressure,
    this.temperature,
    this.mechanical,
    this.correction,
  });

  factory GrsHourlyIndicatorData.fromJson(Map<String, dynamic>? json) {
    if (json == null) return GrsHourlyIndicatorData();
    return GrsHourlyIndicatorData(
      id: json['id'],
      timestamp: json['timestamp'] != null ? DateTime.parse(json['timestamp']) : null,
      pressure: (json['pressure'] as num?)?.toDouble(),
      temperature: (json['temperature'] as num?)?.toDouble(),
      mechanical: (json['mechanical'] as num?)?.toDouble(),
      correction: (json['correction'] as num?)?.toDouble(),
    );
  }
}