import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecase/usecase.dart';
import '../repositories/auth_repository.dart';

/// Returns `true` if the daily agreement screen should be shown today. As a
/// side-effect, the stored "last shown" date is updated when `true` is
/// returned.
@injectable
class CheckDailyAgreementUseCase implements UseCase<bool, NoParams> {
  CheckDailyAgreementUseCase(this._repository);

  final AuthRepository _repository;

  @override
  Future<Either<Failure, bool>> call(NoParams params) =>
      _repository.requiresDailyAgreement();
}
