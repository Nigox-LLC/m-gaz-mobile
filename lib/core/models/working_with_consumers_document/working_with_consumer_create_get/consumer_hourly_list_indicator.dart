import 'package:equatable/equatable.dart';

class ConsumerHourlyListIndicator extends Equatable {
  final String timestamp;
  final double indicator;

  const ConsumerHourlyListIndicator({
    required this.timestamp,
    required this.indicator,
  });

  factory ConsumerHourlyListIndicator.fromJson(Map<String, dynamic> json) {
    return ConsumerHourlyListIndicator(
      timestamp: json['timestamp'] as String,
      indicator: (json['indicator'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'timestamp': timestamp,
      'indicator': indicator,
    };
  }

  @override
  List<Object?> get props => [timestamp, indicator];
}