// class EgxuInfo {
//   final String fromDate;
//   final String toDate;
//   final String oneFactory;
//   final String twoFactory;
//   final String egxuType;
//   final String? egxuConnectionPoint;
//
//   EgxuInfo({
//     required this.fromDate,
//     required this.toDate,
//     required this.oneFactory,
//     required this.twoFactory,
//     required this.egxuType,
//     required this.egxuConnectionPoint,
//   });
//
//   factory EgxuInfo.fromJson(Map<String, dynamic> json) {
//     return EgxuInfo(
//       fromDate: json["from_date"] ?? "",
//       toDate: json["to_date"] ?? "",
//       oneFactory: json["one_factory"] ?? "",
//       twoFactory: json["two_factory"] ?? "",
//       egxuType: json["egxu_type"] ?? "",
//       egxuConnectionPoint: json["egxu_connection_point"],
//     );
//   }
//
//   Map<String, dynamic> toJson() {
//     return {
//       "from_date": fromDate,
//       "to_date": toDate,
//       "one_factory": oneFactory,
//       "two_factory": twoFactory,
//       "egxu_type": egxuType,
//       "egxu_connection_point": egxuConnectionPoint,
//     };
//   }
// }
