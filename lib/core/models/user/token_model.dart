class TokenModel {
  String refresh;
  String access;
  int? employeeId;

  TokenModel({required this.refresh, required this.access, this.employeeId});

  factory TokenModel.fromJson(Map<String, dynamic> json) {
    final user = json["user"];
    return TokenModel(
      refresh: json["refresh"] ?? "",
      access: json["access"] ?? "",
      employeeId: _parseEmployeeId(
        user is Map ? user["employee_id"] : json["employee_id"],
      ),
    );
  }

  Map<String, dynamic> toJson() => {
    "refresh": refresh,
    "access": access,
    if (employeeId != null) "employee_id": employeeId,
  };

  static int? _parseEmployeeId(Object? value) {
    if (value is int) return value;
    if (value is String) return int.tryParse(value);
    return null;
  }
}
