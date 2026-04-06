import 'package:equatable/equatable.dart';
import 'package:m_gaz/core/models/technological-measuring/teach_measure_detail/teach_measure_certificate.dart';
import 'package:m_gaz/core/models/technological-measuring/teach_measure_detail/teach_measure_egxu_type.dart';
import 'package:m_gaz/core/models/technological-measuring/teach_measure_detail/teach_measure_hourly_file.dart';
import 'package:m_gaz/core/models/technological-measuring/teach_measure_detail/teach_measure_hourly_indicator_image.dart';
import 'package:m_gaz/core/models/technological-measuring/teach_measure_detail/teach_measure_indicator_image.dart';
import 'package:m_gaz/core/models/technological-measuring/teach_measure_detail/teach_measure_real_item.dart';

class TeachMeasureItem extends Equatable {
  final int id;
  final List<TeachMeasureRealItem> real;
  final List<TeachMeasureHourlyListIndicator> hourlyListIndicator;
  final List<TeachMeasureIndicatorImage> indicatorImages;
  final List<TeachMeasureHourlyFile> hourlyFiles;
  final List<TeachMeasureCertificate> certificates;
  final TeachMeasureEgxuType egxuType;
  final DateTime? fromDate;
  final DateTime? toDate;
  final String? oneFactory;
  final String? twoFactory;
  final DateTime createdAdd;
  final bool isMoonClosed;
  final DateTime? closedDate;
  final bool isActive;

  const TeachMeasureItem({
    required this.id,
    required this.real,
    required this.hourlyListIndicator,
    required this.indicatorImages,
    required this.hourlyFiles,
    required this.certificates,
    required this.egxuType,
    this.fromDate,
    this.toDate,
    this.oneFactory,
    this.twoFactory,
    required this.createdAdd,
    required this.isMoonClosed,
    this.closedDate,
    required this.isActive,
  });

  factory TeachMeasureItem.fromJson(Map<String, dynamic> json) {
    return TeachMeasureItem(
      id: json['id'] ?? 0,

      real: (json['real'] as List? ?? [])
          .map((e) => TeachMeasureRealItem.fromJson(e ?? {}))
          .toList(),

      hourlyListIndicator: (json['hourly_list_indicator'] as List? ?? [])
          .map((e) => TeachMeasureHourlyListIndicator.fromJson(e ?? {}))
          .toList(),

      indicatorImages: (json['indicator_images'] as List? ?? [])
          .map((e) => TeachMeasureIndicatorImage.fromJson(e ?? {}))
          .toList(),

      hourlyFiles: (json['hourly_files'] as List? ?? [])
          .map((e) => TeachMeasureHourlyFile.fromJson(e ?? {}))
          .toList(),

      certificates: (json['certificates'] as List? ?? [])
          .map((e) => TeachMeasureCertificate.fromJson(e ?? {}))
          .toList(),

      egxuType: json['egxu_type'] != null
          ? TeachMeasureEgxuType.fromJson(json['egxu_type'])
          : const TeachMeasureEgxuType(id: 0, name: ""),

      fromDate: json['from_date'] != null
          ? DateTime.parse(json['from_date'])
          : null,

      toDate: json['to_date'] != null
          ? DateTime.parse(json['to_date'])
          : null,

      oneFactory: json['one_factory'],
      twoFactory: json['two_factory'],

      createdAdd: json['created_add'] != null
          ? DateTime.parse(json['created_add'])
          : DateTime(1970),

      isMoonClosed: json['is_moon_closed'] ?? false,

      closedDate: json['closed_date'] != null
          ? DateTime.parse(json['closed_date'])
          : null,

      isActive: json['is_active'] ?? false,
    );
  }


  @override
  List<Object?> get props => [
    id,
    real,
    hourlyListIndicator,
    indicatorImages,
    hourlyFiles,
    certificates,
    egxuType,
    fromDate,
    toDate,
    oneFactory,
    twoFactory,
    createdAdd,
    isMoonClosed,
    closedDate,
    isActive,
  ];
}