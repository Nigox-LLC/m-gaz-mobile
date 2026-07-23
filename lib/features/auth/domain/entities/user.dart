import 'package:equatable/equatable.dart';

/// Pure domain entity representing the authenticated user.
///
/// Mirrors the legacy `UserModel` fields but contains no JSON logic and no
/// dependencies on Flutter/Dio — only [Equatable].
class User extends Equatable {
  final int id;
  final String username;
  final String role;
  final String? deviceLanguage;
  final int? employeeId;
  final int? regionId;
  final String? regionName;
  final int? districtId;
  final String? districtName;
  final String? photoUrl;

  const User({
    required this.id,
    required this.username,
    required this.role,
    this.deviceLanguage,
    this.employeeId,
    this.regionId,
    this.regionName,
    this.districtId,
    this.districtName,
    this.photoUrl,
  });

  bool get hasProfilePhoto => photoUrl?.trim().isNotEmpty == true;

  @override
  List<Object?> get props => [
    id,
    username,
    role,
    deviceLanguage,
    employeeId,
    regionId,
    regionName,
    districtId,
    districtName,
    photoUrl,
  ];
}
