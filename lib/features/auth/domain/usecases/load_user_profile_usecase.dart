import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecase/usecase.dart';
import '../entities/user.dart';
import '../repositories/auth_repository.dart';

/// Loads the currently authenticated user's profile.
@injectable
class LoadUserProfileUseCase implements UseCase<User, NoParams> {
  LoadUserProfileUseCase(this._repository);

  final AuthRepository _repository;

  @override
  Future<Either<Failure, User>> call(NoParams params) => _repository.loadProfile();
}
