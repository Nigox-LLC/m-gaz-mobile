import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../entities/auth_token.dart';
import '../entities/eimzo_mobile_session.dart';
import '../entities/eimzo_status.dart';

abstract class EImzoAuthRepository {
  Future<Either<Failure, EImzoMobileSession>> startMobileSession();
  Future<Either<Failure, EImzoStatus>> getMobileStatus(String documentId);
  Future<Either<Failure, AuthToken>> completeMobileLogin({
    required String documentId,
    required int employeeId,
  });
}
