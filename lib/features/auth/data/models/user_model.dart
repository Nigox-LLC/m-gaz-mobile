import '../../domain/entities/user.dart';

/// Data-layer representation of [User] with JSON serialization.
///
/// JSON keys mirror the existing backend contract (legacy `UserModel`):
/// `id`, `username`, `role`, `device_language`, `employee_id`, `region_id`,
/// `region_name`, `district_id`, `district_name`.
class UserModel extends User {
  const UserModel({
    required super.id,
    required super.username,
    required super.role,
    super.deviceLanguage,
    super.employeeId,
    super.regionId,
    super.regionName,
    super.districtId,
    super.districtName,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] ?? 0,
      username: json['username'] ?? '',
      role: json['role'] ?? '',
      deviceLanguage: json['device_language'],
      employeeId: json['employee_id'],
      regionId: json['region_id'],
      regionName: json['region_name'],
      districtId: json['district_id'],
      districtName: json['district_name'],
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'username': username,
        'role': role,
        'device_language': deviceLanguage,
        'employee_id': employeeId,
        'region_id': regionId,
        'region_name': regionName,
        'district_id': districtId,
        'district_name': districtName,
      };
}
