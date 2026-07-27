import '../models/auth_token_model.dart';
import '../models/eimzo_mobile_session_model.dart';
import '../models/eimzo_status_model.dart';

abstract class EImzoRemoteDataSource {
  Future<EImzoMobileSessionModel> startMobileSession();
  Future<EImzoStatusModel> getMobileStatus(String documentId);
  Future<AuthTokenModel> completeMobileLogin({
    required String documentId,
    required int employeeId,
  });
}
