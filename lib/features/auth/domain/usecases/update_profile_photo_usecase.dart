import 'dart:io';

import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/error/failures.dart';
import '../entities/user.dart';
import '../repositories/auth_repository.dart';

@injectable
class UpdateProfilePhotoUseCase {
  UpdateProfilePhotoUseCase(this._repository);

  final AuthRepository _repository;

  Future<Either<Failure, User>> call({
    required int userId,
    required File photo,
  }) => _repository.updateProfilePhoto(userId: userId, photo: photo);
}
