import '../../domain/entities/auth_token.dart';

/// Data-layer representation of [AuthToken] with JSON serialization.
class AuthTokenModel extends AuthToken {
  const AuthTokenModel({
    required super.access,
    required super.refresh,
    this.employeeId,
  });

  final int? employeeId;

  factory AuthTokenModel.fromJson(Map<String, dynamic> json) {
    final user = json['user'];
    return AuthTokenModel(
      access: json['access'] ?? '',
      refresh: json['refresh'] ?? '',
      employeeId: _parseEmployeeId(
        user is Map ? user['employee_id'] : json['employee_id'],
      ),
    );
  }

  Map<String, dynamic> toJson() => {
    'access': access,
    'refresh': refresh,
    if (employeeId != null) 'employee_id': employeeId,
  };

  static int? _parseEmployeeId(Object? value) {
    if (value is int) return value;
    if (value is String) return int.tryParse(value);
    return null;
  }
}
