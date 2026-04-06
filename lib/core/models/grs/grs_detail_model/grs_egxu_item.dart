import 'grs_certigicate.dart';
import 'grs_egxu_data.dart';
import 'grs_egxu_type.dart';
import 'grs_gas_equipment_item.dart';
import 'grs_hourly_file.dart';
import 'grs_hourly_indicator.dart';
import 'grs_indicator_image.dart';
import 'grs_real_device.dart';

class GrsEgxuItem {
  final int? id;
  final GrsEgxuData? grsEgxuData;
  final List<GrsRealDevice>? real;
  final List<GrsHourlyIndicator>? hourlyListIndicator;
  final List<GrsIndicatorImage>? indicatorImages;
  final List<GrsHourlyFile>? hourlyFiles;
  final List<GrsCertificate>? certificates;
  final GrsEgxuType? egxuType;
  final List<GrsGasEquipmentItem>? gasEquipmentList;
  final DateTime? fromDate;
  final DateTime? toDate;
  final String? oneFactory;
  final String? twoFactory;
  final DateTime? createdAdd;
  final bool? isMoonClosed;
  final DateTime? closedDate;
  final bool? isActive;

  GrsEgxuItem({
    this.id,
    this.grsEgxuData,
    this.real,
    this.hourlyListIndicator,
    this.indicatorImages,
    this.hourlyFiles,
    this.certificates,
    this.egxuType,
    this.gasEquipmentList,
    this.fromDate,
    this.toDate,
    this.oneFactory,
    this.twoFactory,
    this.createdAdd,
    this.isMoonClosed,
    this.closedDate,
    this.isActive,
  });

  factory GrsEgxuItem.fromJson(Map<String, dynamic>? json) {
    if (json == null) return GrsEgxuItem();
    return GrsEgxuItem(
      id: json['id'],
      grsEgxuData: json['grs_egxu_data'] != null ? GrsEgxuData.fromJson(json['grs_egxu_data']) : null,
      real: (json['real'] as List?)?.map((e) => GrsRealDevice.fromJson(e)).toList(),
      hourlyListIndicator: (json['hourly_list_indicator'] as List?)?.map((e) => GrsHourlyIndicator.fromJson(e)).toList(),
      indicatorImages: (json['indicator_images'] as List?)?.map((e) => GrsIndicatorImage.fromJson(e)).toList(),
      hourlyFiles: (json['hourly_files'] as List?)?.map((e) => GrsHourlyFile.fromJson(e)).toList(),
      certificates: (json['certificates'] as List?)?.map((e) => GrsCertificate.fromJson(e)).toList(),
      egxuType: json['egxu_type'] != null ? GrsEgxuType.fromJson(json['egxu_type']) : null,
      gasEquipmentList: (json['gas_equipment_list'] as List?)?.map((e) => GrsGasEquipmentItem.fromJson(e)).toList(),
      fromDate: json['from_date'] != null ? DateTime.parse(json['from_date']) : null,
      toDate: json['to_date'] != null ? DateTime.parse(json['to_date']) : null,
      oneFactory: json['one_factory'],
      twoFactory: json['two_factory'],
      createdAdd: json['created_add'] != null ? DateTime.parse(json['created_add']) : null,
      isMoonClosed: json['is_moon_closed'],
      closedDate: json['closed_date'] != null ? DateTime.parse(json['closed_date']) : null,
      isActive: json['is_active'],
    );
  }
}