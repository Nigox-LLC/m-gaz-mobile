import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecase/usecase.dart';
import '../entities/auth_token.dart';
import '../entities/eimzo_mobile_session.dart';
import '../entities/eimzo_status.dart';
import '../repositories/eimzo_auth_repository.dart';

@injectable
class StartEImzoMobileSessionUseCase
    implements UseCase<EImzoMobileSession, NoParams> {
  StartEImzoMobileSessionUseCase(this._repository);

  final EImzoAuthRepository _repository;

  @override
  Future<Either<Failure, EImzoMobileSession>> call(NoParams params) =>
      _repository.startMobileSession();
}

class EImzoMobileAuthParams extends Equatable {
  const EImzoMobileAuthParams({
    required this.documentId,
    required this.employeeId,
  });

  final String documentId;
  final int employeeId;

  @override
  List<Object?> get props => [documentId, employeeId];
}

@injectable
class GetEImzoMobileStatusUseCase implements UseCase<EImzoStatus, String> {
  GetEImzoMobileStatusUseCase(this._repository);

  final EImzoAuthRepository _repository;

  @override
  Future<Either<Failure, EImzoStatus>> call(String documentId) =>
      _repository.getMobileStatus(documentId);
}

@injectable
class CompleteEImzoMobileLoginUseCase
    implements UseCase<AuthToken, EImzoMobileAuthParams> {
  CompleteEImzoMobileLoginUseCase(this._repository);

  final EImzoAuthRepository _repository;

  @override
  Future<Either<Failure, AuthToken>> call(EImzoMobileAuthParams params) =>
      _repository.completeMobileLogin(
        documentId: params.documentId,
        employeeId: params.employeeId,
      );
}
