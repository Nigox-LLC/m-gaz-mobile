import 'package:m_gaz/core/models/grs/grs_detail_model/grs_egxu_item.dart';

import '../../global/base_model.dart';
import 'grs_gtsh.dart';

class GrsDetailModel {
  final int? id;
  final List<GrsEgxuItem>? egxuList;
  final Region? region;
  final District? district;
  final Employee? employee;
  final GrsGtsh? gtsh;
  final DateTime? dateTime;

  GrsDetailModel({
    this.id,
    this.egxuList,
    this.region,
    this.district,
    this.employee,
    this.gtsh,
    this.dateTime,
  });

  factory GrsDetailModel.fromJson(Map<String, dynamic>? json) {
    if (json == null) return GrsDetailModel();
    return GrsDetailModel(
      id: json['id'],
      egxuList: (json['egxu_list'] as List?)?.map((e) => GrsEgxuItem.fromJson(e)).toList(),
      region: json['region'] != null ? Region.fromJson(json['region']) : null,
      district: json['district'] != null ? District.fromJson(json['district']) : null,
      employee: json['employee'] != null ? Employee.fromJson(json['employee']) : null,
      gtsh: json['gtsh'] != null ? GrsGtsh.fromJson(json['gtsh']) : null,
      dateTime: json['datetime'] != null ? DateTime.parse(json['datetime']) : null,
    );
  }
}
