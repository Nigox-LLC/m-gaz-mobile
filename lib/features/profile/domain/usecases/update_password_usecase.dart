import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:injectable/injectable.dart';
import 'package:m_gaz/core/error/failures.dart';
import 'package:m_gaz/core/usecase/usecase.dart';
import 'package:m_gaz/features/profile/domain/repository/profile_repository.dart';

@injectable
class UpdatePasswordUseCase implements UseCase<void, UpdatePasswordParams> {
  UpdatePasswordUseCase(this._repository);

  final ProfileRepository _repository;

  @override
  Future<Either<Failure, void>> call(UpdatePasswordParams params) {
    return _repository.updatePassword(
      userId: params.userId,
      password: params.password,
    );
  }
}

class UpdatePasswordParams extends Equatable {
  const UpdatePasswordParams({required this.userId, required this.password});

  final int userId;
  final String password;

  @override
  List<Object?> get props => [userId, password];
}
