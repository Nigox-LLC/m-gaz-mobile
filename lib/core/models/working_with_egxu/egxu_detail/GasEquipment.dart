// class GasEquipment {
//   final int id;
//   final String name;
//   final double hourlyGasConsumption;
//
//   GasEquipment({
//     required this.id,
//     required this.name,
//     required this.hourlyGasConsumption,
//   });
//
//   factory GasEquipment.fromJson(Map<String, dynamic> json) {
//     return GasEquipment(
//       id: json["id"],
//       name: json["name"],
//       hourlyGasConsumption:
//       (json["hourly_gas_consumption"] as num).toDouble(),
//     );
//   }
//
//   Map<String, dynamic> toJson() {
//     return {
//       "id": id,
//       "name": name,
//       "hourly_gas_consumption": hourlyGasConsumption,
//     };
//   }
// }
