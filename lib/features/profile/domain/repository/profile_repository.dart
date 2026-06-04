import 'package:dartz/dartz.dart';
import 'package:m_gaz/core/error/failures.dart';

import '../entities/profile_entity.dart';

abstract class ProfileRepository {

  Future<Either<Failure, ProfileEntity>> loadProfileData();

}