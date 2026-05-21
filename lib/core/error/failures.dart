import 'package:equatable/equatable.dart';

/// Base class for all domain-level failures.
///
/// Failures are returned from repositories/use-cases via [Either] (left)
/// and consumed by BLoCs to render error UI. They MUST NOT contain
/// Flutter/UI types — pure Dart only.
abstract class Failure extends Equatable {
  const Failure(this.message);

  final String message;

  @override
  List<Object?> get props => [message];

  @override
  String toString() => '$runtimeType(message: $message)';
}

class ServerFailure extends Failure {
  const ServerFailure(super.message);
}

class NetworkFailure extends Failure {
  const NetworkFailure(super.message);
}

class CacheFailure extends Failure {
  const CacheFailure(super.message);
}

class AuthFailure extends Failure {
  const AuthFailure(super.message);
}

class UnauthorizedFailure extends Failure {
  const UnauthorizedFailure(super.message);
}
