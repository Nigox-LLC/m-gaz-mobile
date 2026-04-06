import 'package:m_gaz/core/models/grs/grs_detail_model/grs_hourly_indicator_data.dart';

class GrsHourlyIndicator {
  final int? count;
  final String? date;
  final List<GrsHourlyIndicatorData>? data;

  GrsHourlyIndicator({
    this.count,
    this.date,
    this.data,
  });

  factory GrsHourlyIndicator.fromJson(Map<String, dynamic>? json) {
    if (json == null) return GrsHourlyIndicator();
    return GrsHourlyIndicator(
      count: json['count'],
      date: json['date'],
      data: (json['data'] as List?)?.map((e) => GrsHourlyIndicatorData.fromJson(e)).toList(),
    );
  }
}