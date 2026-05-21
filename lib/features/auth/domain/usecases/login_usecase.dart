import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecase/usecase.dart';
import '../entities/auth_token.dart';
import '../repositories/auth_repository.dart';

/// Input parameters for [LoginUseCase].
class LoginParams extends Equatable {
  final String userName;
  final String password;

  const LoginParams({required this.userName, required this.password});

  @override
  List<Object?> get props => [userName, password];
}

/// Authenticates the user with username/password and returns the resulting
/// [AuthToken] on success.
@injectable
class LoginUseCase implements UseCase<AuthToken, LoginParams> {
  LoginUseCase(this._repository);

  final AuthRepository _repository;

  @override
  Future<Either<Failure, AuthToken>> call(LoginParams params) {
    return _repository.login(
      userName: params.userName,
      password: params.password,
    );
  }
}
