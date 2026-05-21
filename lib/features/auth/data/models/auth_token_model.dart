import '../../domain/entities/auth_token.dart';

/// Data-layer representation of [AuthToken] with JSON serialization.
class AuthTokenModel extends AuthToken {
  const AuthTokenModel({required super.access, required super.refresh});

  factory AuthTokenModel.fromJson(Map<String, dynamic> json) {
    return AuthTokenModel(
      access: json['access'] ?? '',
      refresh: json['refresh'] ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
        'access': access,
        'refresh': refresh,
      };
}
