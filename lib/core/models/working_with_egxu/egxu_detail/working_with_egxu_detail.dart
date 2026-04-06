// import 'package:m_gaz/core/models/egxu/egxu_detail/GasEquipment.dart';
// import 'gas_equipment_item.dart';
//
// class WorkingWithEgxuDetail {
//   final int id;
//   final DateTime datetime;
//   final Region region;
//   final District district;
//   final Activity typeOfActivity;
//   final String removal;
//   final String gasUsage;
//   final String usageType;
//   final Employee employee;
//   final Consumers consumers;
//   final bool isActive;
//   final List<GasEquipment> gasEquipmentList;
//
//   WorkingWithEgxuDetail({
//     required this.id,
//     required this.datetime,
//     required this.region,
//     required this.district,
//     required this.typeOfActivity,
//     required this.removal,
//     required this.gasUsage,
//     required this.usageType,
//     required this.employee,
//     required this.consumers,
//     required this.isActive,
//     required this.gasEquipmentList,
//   });
//
//   factory WorkingWithEgxuDetail.fromJson(Map<String, dynamic> json) {
//     return WorkingWithEgxuDetail(
//       id: json["id"],
//       datetime: DateTime.parse(json["datetime"]),
//       region: Region.fromJson(json["region"]),
//       district: District.fromJson(json["district"]),
//       typeOfActivity: Activity.fromJson(json["type_of_activity"]),
//       removal: json["removal"] ?? "",
//       gasUsage: json["gas_usage"] ?? "",
//       usageType: json["usage_type"] ?? "",
//       employee: Employee.fromJson(json["employee"]),
//       consumers: Consumers.fromJson(json["consumers"]),
//       isActive: json["is_active"] ?? false,
//       gasEquipmentList: (json["gas_equipment_list"] as List)
//           .map((e) => GasEquipment.fromJson(e))
//           .toList(),
//     );
//   }
//
//   Map<String, dynamic> toJson() {
//     return {
//       "id": id,
//       "datetime": datetime.toIso8601String(),
//       "region": region.toJson(),
//       "district": district.toJson(),
//       "type_of_activity": typeOfActivity.toJson(),
//       "removal": removal,
//       "gas_usage": gasUsage,
//       "usage_type": usageType,
//       "employee": employee.toJson(),
//       "consumers": consumers.toJson(),
//       "is_active": isActive,
//       "gas_equipment_list":
//       gasEquipmentList.map((e) => e.toJson()).toList(),
//     };
//   }
// }
