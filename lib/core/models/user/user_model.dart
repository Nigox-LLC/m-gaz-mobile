class UserModel {
  final int id;
  final String username;
  final String? deviceLanguage;
  final String role;

  final int? employeeId;
  final int? regionId;
  final String? regionName;
  final int? districtId;
  final String? districtName;

  UserModel({
    required this.id,
    required this.username,
    this.deviceLanguage,
    required this.role,
    this.employeeId,
    this.regionId,
    this.regionName,
    this.districtId,
    this.districtName,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] ?? 0,
      username: json['username'] ?? '',
      deviceLanguage: json['device_language'],
      role: json['role'] ?? '',

      employeeId: json['employee_id'],
      regionId: json['region_id'],
      regionName: json['region_name'],
      districtId: json['district_id'],
      districtName: json['district_name'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'device_language': deviceLanguage,
      'role': role,
      'employee_id': employeeId,
      'region_id': regionId,
      'region_name': regionName,
      'district_id': districtId,
      'district_name': districtName,
    };
  }
}
