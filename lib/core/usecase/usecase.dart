import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '../error/failures.dart';

/// Base contract for application use-cases.
///
/// `Type`  — the success payload type.
/// `Params` — the input arguments (use [NoParams] when none).
// ignore: avoid_types_as_parameter_names
abstract class UseCase<Type, Params> {
  Future<Either<Failure, Type>> call(Params params);
}

/// Sentinel parameter type for use-cases that take no input.
class NoParams extends Equatable {
  const NoParams();

  @override
  List<Object?> get props => [];
}
