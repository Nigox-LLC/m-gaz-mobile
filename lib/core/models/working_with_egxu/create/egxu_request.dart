// class EgxuRequest {
//   final String datetime;
//   final int region;
//   final int district;
//   final int typeOfActivity;
//   final String removal;
//   final String gasUsage;
//   final String usageType;
//   final int employee;
//   final int consumers;
//   final bool isActive;
//   final List<GasEquipmentItem> gasEquipmentList;
//
//   EgxuRequest({
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
//   Map<String, dynamic> toJson() => {
//     "datetime": datetime,
//     "region": region,
//     "district": district,
//     "type_of_activity": typeOfActivity,
//     "removal": removal,
//     "gas_usage": gasUsage,
//     "usage_type": usageType,
//     "employee": employee,
//     "consumers": consumers,
//     "is_active": isActive,
//     "gas_equipment_list":
//     gasEquipmentList.map((e) => e.toJson()).toList(),
//   };
// }
//
// class GasEquipmentItem {
//   final int gasEquipment;
//   final int egxu;
//   final bool uses;
//   final int quantity;
//   final String stampNumber;
//   final String hourlyGasConsumption;
//   final String replacementReason;
//   final String dailyGasConsumption;
//   final String workCompletedDate;
//   final List<PhotoItem> photos;
//
//   GasEquipmentItem({
//     required this.gasEquipment,
//     required this.egxu,
//     required this.uses,
//     required this.quantity,
//     required this.stampNumber,
//     required this.hourlyGasConsumption,
//     required this.replacementReason,
//     required this.dailyGasConsumption,
//     required this.workCompletedDate,
//     required this.photos,
//   });
//
//   Map<String, dynamic> toJson() => {
//     "gas_equipment": gasEquipment,
//     "egxu": egxu,
//     "uses": uses,
//     "quantity": quantity,
//     "stamp_number": stampNumber,
//     "hourly_gas_consumption": hourlyGasConsumption,
//     "replacement_reason": replacementReason,
//     "daily_gas_consumption": dailyGasConsumption,
//     "work_completed_date": workCompletedDate,
//     "photos": photos.map((e) => e.toJson()).toList(),
//   };
// }
//
// class PhotoItem {
//   final String file;
//
//   PhotoItem({required this.file});
//
//   Map<String, dynamic> toJson() => {"file": file};
// }
