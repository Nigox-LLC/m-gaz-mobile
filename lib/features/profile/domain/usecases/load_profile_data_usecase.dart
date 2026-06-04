import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:m_gaz/core/error/failures.dart';
import 'package:m_gaz/core/usecase/usecase.dart';
import 'package:m_gaz/features/profile/domain/entities/profile_entity.dart';
import 'package:m_gaz/features/profile/domain/repository/profile_repository.dart';

/// Loads the authenticated user's profile for the profile feature screens.
@injectable
class LoadProfileDataUseCase implements UseCase<ProfileEntity, NoParams> {
  LoadProfileDataUseCase(this._repository);

  final ProfileRepository _repository;

  @override
  Future<Either<Failure, ProfileEntity>> call(NoParams params) {
    return _repository.loadProfileData();
  }
}
