import 'package:equatable/equatable.dart';

/// Domain entity representing an auth token pair (access + refresh).
///
/// Mirrors the shape of legacy `TokenModel` but stays free of JSON
/// serialization concerns.
class AuthToken extends Equatable {
  final String access;
  final String refresh;

  const AuthToken({required this.access, required this.refresh});

  @override
  List<Object?> get props => [access, refresh];
}
