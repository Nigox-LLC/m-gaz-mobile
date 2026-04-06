import 'package:equatable/equatable.dart';
import 'package:m_gaz/core/models/technological-measuring/teach_measure_detail/teach_measure_gtsh.dart';
import 'package:m_gaz/core/models/technological-measuring/teach_measure_detail/teach_measure_item.dart';
import 'package:m_gaz/core/models/technological-measuring/teach_measure_detail/teach_measuring_device.dart';

import '../../global/base_model.dart';

class TeachMeasureDetail extends Equatable {
  final int id;
  final List<TeachMeasureItem> egxuList;
  final Region region;
  final District district;
  final Employee employee;
  final TeachMeasureGtsh gtsh;
  final TechnoMeasuringDevices technoMeasuringDevices;
  final DateTime datetime;

  const TeachMeasureDetail({
    required this.id,
    required this.egxuList,
    required this.region,
    required this.district,
    required this.employee,
    required this.gtsh,
    required this.technoMeasuringDevices,
    required this.datetime,
  });

  factory TeachMeasureDetail.fromJson(Map<String, dynamic> json) {
    return TeachMeasureDetail(
      id: json['id'] ?? 0,

      egxuList: (json['egxu_list'] as List? ?? [])
          .map((e) => TeachMeasureItem.fromJson(e ?? {}))
          .toList(),

      region: json['region'] != null
          ? Region.fromJson(json['region'])
          : Region(id: 0, name: ""),

      district: json['district'] != null
          ? District.fromJson(json['district'])
          : District(id: 0, name: ""),

      employee: json['employee'] != null
          ? Employee.fromJson(json['employee'])
          : Employee(id: 0, fio: ""),

      gtsh: json['gtsh'] != null
          ? TeachMeasureGtsh.fromJson(json['gtsh'])
          : TeachMeasureGtsh(id: 0, name: ""),

      technoMeasuringDevices: json['techno_measuring_devices'] != null
          ? TechnoMeasuringDevices.fromJson(json['techno_measuring_devices'])
          : const TechnoMeasuringDevices(id: 0, name: ""),

      datetime: json['datetime'] != null
          ? DateTime.parse(json['datetime'])
          : DateTime(1970),
    );
  }

  @override
  List<Object?> get props => [
    id,
    egxuList,
    region,
    district,
    employee,
    gtsh,
    technoMeasuringDevices,
    datetime,
  ];
}
