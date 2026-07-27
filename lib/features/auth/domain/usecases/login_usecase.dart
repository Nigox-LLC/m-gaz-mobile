import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecase/usecase.dart';
import '../repositories/auth_repository.dart';

/// Input parameters for [LoginUseCase].
class LoginParams extends Equatable {
  final String userName;
  final String password;

  const LoginParams({required this.userName, required this.password});

  @override
  List<Object?> get props => [userName, password];
}

/// Validates username/password before the mandatory E-Imzo verification.
@injectable
class LoginUseCase implements UseCase<int, LoginParams> {
  LoginUseCase(this._repository);

  final AuthRepository _repository;

  @override
  Future<Either<Failure, int>> call(LoginParams params) {
    return _repository.validateCredentials(
      userName: params.userName,
      password: params.password,
    );
  }
}
