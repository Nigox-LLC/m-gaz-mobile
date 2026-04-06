import 'package:m_gaz/core/models/working-with-stamps/detail/working_with_stamp_real.dart';

class WorkingWithStampsDetailModel {
  final int id;
  final List<WorkingWithStampReals> reals;
  final String egxuType;
  final String fromDate;
  final String toDate;
  final String oneFactory;
  final String twoFactory;

  WorkingWithStampsDetailModel({
    required this.id,
    required this.reals,
    required this.egxuType,
    required this.fromDate,
    required this.toDate,
    required this.oneFactory,
    required this.twoFactory,
  });

  factory WorkingWithStampsDetailModel.fromJson(Map<String, dynamic> json) {
    return WorkingWithStampsDetailModel(
      id: json["id"] ?? 0,
      reals: (json["reals"] as List<dynamic>? ?? [])
          .map((e) => WorkingWithStampReals.fromJson(e))
          .toList(),
      egxuType: json["egxu_type"] ?? "-",
      fromDate: json["from_date"] ?? "-",
      toDate: json["to_date"] ?? "-",
      oneFactory: json["one_factory"] ?? "-",
      twoFactory: json["two_factory"] ?? "-",
    );
  }
}
