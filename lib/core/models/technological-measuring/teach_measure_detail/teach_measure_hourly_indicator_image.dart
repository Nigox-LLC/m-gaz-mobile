import 'package:equatable/equatable.dart';

class TeachMeasureHourlyListIndicator extends Equatable {
  final int? id;
  final DateTime timestamp;
  final double indicator;
  final bool? isActive;

  const TeachMeasureHourlyListIndicator({
    required this.id,
    required this.timestamp,
    required this.indicator,
    required this.isActive,
  });

  factory TeachMeasureHourlyListIndicator.fromJson(Map<String, dynamic> json) {
    return TeachMeasureHourlyListIndicator(
      id: json['id'] as int?,
      timestamp: DateTime.parse(json['timestamp'] as String? ??DateTime.now().toString()),
      indicator: (json['indicator'] as num? ?? 0).toDouble(),
      isActive: json['is_active'] as bool?,
    );
  }

  @override
  List<Object?> get props => [id, timestamp, indicator, isActive];
}