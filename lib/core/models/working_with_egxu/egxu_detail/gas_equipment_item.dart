// import 'EgxuInfo.dart';
// import 'GasEquipment.dart';
//
// class GasEquipmentItem {
//   final int id;
//   final GasEquipment gasEquipment;
//   final EgxuInfo egxu;
//   final bool uses;
//   final int quantity;
//   final String stampNumber;
//   final String hourlyGasConsumption;
//   final String replacementReason;
//   final String dailyGasConsumption;
//   final String workCompletedDate;
//
//   GasEquipmentItem({
//     required this.id,
//     required this.gasEquipment,
//     required this.egxu,
//     required this.uses,
//     required this.quantity,
//     required this.stampNumber,
//     required this.hourlyGasConsumption,
//     required this.replacementReason,
//     required this.dailyGasConsumption,
//     required this.workCompletedDate,
//   });
//
//   factory GasEquipmentItem.fromJson(Map<String, dynamic> json) {
//     return GasEquipmentItem(
//       id: json["id"],
//       gasEquipment: GasEquipment.fromJson(json["gas_equipment"]),
//       egxu: EgxuInfo.fromJson(json["egxu"]),
//       uses: json["uses"] ?? false,
//       quantity: json["quantity"] ?? 0,
//       stampNumber: json["stamp_number"] ?? "",
//       hourlyGasConsumption: json["hourly_gas_consumption"] ?? "0.00",
//       replacementReason: json["replacement_reason"] ?? "",
//       dailyGasConsumption: json["daily_gas_consumption"] ?? "0.00",
//       workCompletedDate: json["work_completed_date"] ?? "",
//     );
//   }
//
//   Map<String, dynamic> toJson() {
//     return {
//       "id": id,
//       "gas_equipment": gasEquipment.toJson(),
//       "egxu": egxu.toJson(),
//       "uses": uses,
//       "quantity": quantity,
//       "stamp_number": stampNumber,
//       "hourly_gas_consumption": hourlyGasConsumption,
//       "replacement_reason": replacementReason,
//       "daily_gas_consumption": dailyGasConsumption,
//       "work_completed_date": workCompletedDate,
//     };
//   }
// }
