import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecase/usecase.dart';
import '../repositories/auth_repository.dart';

/// Returns the last successfully logged-in username (empty if none), used to
/// pre-fill the login form on app launch.
@injectable
class GetSavedUsernameUseCase implements UseCase<String, NoParams> {
  GetSavedUsernameUseCase(this._repository);

  final AuthRepository _repository;

  @override
  Future<Either<Failure, String>> call(NoParams params) =>
      _repository.getSavedUsername();
}
