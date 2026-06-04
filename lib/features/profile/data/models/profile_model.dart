import 'package:m_gaz/features/profile/domain/entities/profile_entity.dart';

class ProfileModel extends ProfileEntity {
  const ProfileModel({
    required super.id,
    required super.username,
    required super.role,
    super.deviceLanguage,
    super.employeeId,
    super.employeeFio,
    super.regionId,
    super.regionName,
    super.districtId,
    super.districtName,
    super.photoUrl,
    super.phone,
  });

  factory ProfileModel.fromJson(Map<String, dynamic> json) {
    return ProfileModel(
      id: json['id'],
      username: json['username'],
      role: json['role'],
      deviceLanguage: json['device_language'],
      employeeId: json['employee_id'],
      employeeFio: json['employee_fio'],
      regionId: json['region_id'],
      regionName: json['region_name'],
      districtId: json['district_id'],
      districtName: json['district_name'],
      photoUrl: json['photo_url'],
      phone: json['phone'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'role': role,
      'device_language': deviceLanguage,
      'employee_id': employeeId,
      'employee_fio': employeeFio,
      'region_id': regionId,
      'region_name': regionName,
      'district_id': districtId,
      'district_name': districtName,
      'photo_url': photoUrl,
      'phone': phone,
    };
  }
}
