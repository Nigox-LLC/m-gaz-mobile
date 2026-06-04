import 'package:equatable/equatable.dart';

class ProfileEntity extends Equatable {
  final int id;
  final String username;
  final String role;
  final String? deviceLanguage;
  final int? employeeId;
  final String? employeeFio;
  final int? regionId;
  final String? regionName;
  final int? districtId;
  final String? districtName;
  final String? photoUrl;
  final String? phone;

  const ProfileEntity({
    required this.id,
    required this.username,
    required this.role,
    this.deviceLanguage,
    this.employeeId,
    this.employeeFio,
    this.regionId,
    this.regionName,
    this.districtId,
    this.districtName,
    this.photoUrl,
    this.phone,
  });

  @override
  List<Object?> get props => [
    id,
    username,
    role,
    deviceLanguage,
    employeeId,
    employeeFio,
    regionId,
    regionName,
    districtId,
    districtName,
    photoUrl,
    phone,
  ];
}
