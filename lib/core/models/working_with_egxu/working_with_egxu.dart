// class EGXUDocument {
//   final int id;
//   final String region;
//   final String district;
//   final String employee;
//   final String consumers;
//   final String typeOfActivity;
//   final String removal;
//   final String gasUsage;
//   final String usageType;
//   final DateTime datetime;
//
//   EGXUDocument({
//     required this.id,
//     required this.region,
//     required this.district,
//     required this.employee,
//     required this.consumers,
//     required this.typeOfActivity,
//     required this.removal,
//     required this.gasUsage,
//     required this.usageType,
//     required this.datetime,
//   });
//
//   factory EGXUDocument.fromJson(Map<String, dynamic> json) {
//     return EGXUDocument(
//       id: json['id'] ?? 0,
//       region: json['region'] ?? '',
//       district: json['district'] ?? '',
//       employee: json['employee'] ?? '',
//       consumers: json['consumers'] ?? '',
//       typeOfActivity: json['type_of_activity'] ?? '',
//       removal: json['removal'] ?? '',
//       gasUsage: json['gas_usage'] ?? '',
//       usageType: json['usage_type'] ?? '',
//       datetime: DateTime.tryParse(json['datetime'] ?? '') ?? DateTime.now(),
//     );
//   }
//
//   Map<String, dynamic> toJson() => {
//     "id": id,
//     "region": region,
//     "district": district,
//     "employee": employee,
//     "consumers": consumers,
//     "type_of_activity": typeOfActivity,
//     "removal": removal,
//     "gas_usage": gasUsage,
//     "usage_type": usageType,
//     "datetime": datetime.toIso8601String(),
//   };
// }
