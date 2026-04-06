import 'package:equatable/equatable.dart';

class WorkingWithConsumersList extends Equatable {
  final int id;
  final String region;
  final String district;
  final String employee;
  final String consumers;
  final DateTime datetime;
  final String excelId;

  const WorkingWithConsumersList({
    required this.id,
    required this.region,
    required this.district,
    required this.employee,
    required this.consumers,
    required this.datetime,
    required this.excelId,
  });

  factory WorkingWithConsumersList.fromJson(Map<String, dynamic> json) {
    return WorkingWithConsumersList(
      id: json['id'] as int,
      region: json['region']?.toString() ?? '',
      district: json['district']?.toString() ?? '',
      employee: json['employee']?.toString() ?? '',
      consumers: json['consumers']?.toString() ?? '',
      datetime: json['datetime'] != null
          ? DateTime.tryParse(json['datetime'].toString()) ?? DateTime.now()
          : DateTime.now(),
      excelId: json['excel_id']?.toString() ?? '',
    );
  }

  @override
  List<Object?> get props => [
    id,
    region,
    district,
    employee,
    consumers,
    datetime,
    excelId,
  ];
}
