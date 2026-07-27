import 'dart:io';

import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/usecase/usecase.dart';
import '../../domain/entities/eimzo_mobile_session.dart';
import '../../domain/entities/eimzo_status.dart';
import '../../domain/entities/user.dart';
import '../../domain/usecases/get_saved_username_usecase.dart';
import '../../domain/usecases/load_user_profile_usecase.dart';
import '../../domain/usecases/login_usecase.dart';
import '../../domain/usecases/eimzo_mobile_auth_usecases.dart';
import '../../domain/usecases/update_profile_photo_usecase.dart';
import '../services/eimzo_mobile_service.dart';

part 'login_event.dart';
part 'login_state.dart';

@injectable
class LoginBloc extends Bloc<LoginEvent, LoginState> {
  final LoginUseCase _login;
  final LoadUserProfileUseCase _loadProfile;
  final GetSavedUsernameUseCase _getSavedUsername;
  final UpdateProfilePhotoUseCase _updateProfilePhoto;
  final StartEImzoMobileSessionUseCase _startEImzoSession;
  final GetEImzoMobileStatusUseCase _getEImzoStatus;
  final CompleteEImzoMobileLoginUseCase _completeEImzoLogin;
  final EImzoMobileService _eimzoMobileService;
  int? _credentialEmployeeId;

  LoginBloc(
    this._login,
    this._loadProfile,
    this._getSavedUsername,
    this._updateProfilePhoto,
    this._startEImzoSession,
    this._getEImzoStatus,
    this._completeEImzoLogin,
    this._eimzoMobileService,
  ) : super(const LoginState()) {
    on<LoginSubmitted>(_onSubmitted);
    on<LoadUserProfile>(_onLoadProfile);
    on<LoadSavedUsername>(_onLoadSavedUsername);
    on<ProfilePhotoUploaded>(_onProfilePhotoUploaded);
    on<EImzoVerificationRequested>(_onEImzoVerificationRequested);
    on<EImzoResetRequested>(_onEImzoResetRequested);
  }

  Future<void> _onLoadSavedUsername(
    LoadSavedUsername event,
    Emitter<LoginState> emit,
  ) async {
    final result = await _getSavedUsername(const NoParams());
    final username = result.getOrElse(() => '');
    if (username.isNotEmpty) {
      emit(state.copyWith(savedUsername: username));
    }
  }

  Future<void> _onSubmitted(
    LoginSubmitted event,
    Emitter<LoginState> emit,
  ) async {
    _credentialEmployeeId = null;
    _log('Login credentials validation started');
    emit(state.copyWith(status: LoginStatus.loading, errorMessage: ''));

    final result = await _login(
      LoginParams(userName: event.userName, password: event.password),
    );

    result.fold(
      (failure) => emit(
        state.copyWith(status: LoginStatus.fail, errorMessage: failure.message),
      ),
      // Yo'qlama/kelishuv qarori endi lokal sana emas — backend orqali
      // (AttendanceCheckAccess) login ekranida hal qilinadi.
      (employeeId) {
        _credentialEmployeeId = employeeId;
        _log('Credentials validated; employee_id received');
        emit(state.copyWith(status: LoginStatus.eimzoReady));
      },
    );
  }

  Future<void> _onEImzoVerificationRequested(
    EImzoVerificationRequested event,
    Emitter<LoginState> emit,
  ) async {
    emit(state.copyWith(status: LoginStatus.eimzoLaunching, errorMessage: ''));
    _log('E-Imzo verification requested');

    final sessionResult = await _startEImzoSession(const NoParams());
    final session = sessionResult.fold<EImzoMobileSession?>((failure) {
      _log('E-Imzo session creation failed: ${failure.message}');
      emit(
        state.copyWith(
          status: LoginStatus.eimzoFailure,
          errorMessage: failure.message,
        ),
      );
      return null;
    }, (session) => session);
    if (session == null) {
      return;
    }
    _log(
      'E-Imzo session created: documentId=${session.documentId}, '
      'siteId=${session.siteId}, ttl=${session.ttl.inSeconds}s',
    );
    final employeeId = _credentialEmployeeId;
    if (employeeId == null) {
      emit(
        state.copyWith(
          status: LoginStatus.eimzoFailure,
          errorMessage: 'Login employee_id ma’lumoti topilmadi',
        ),
      );
      return;
    }

    try {
      Future<EImzoStatus> getStatus(String documentId) async {
        final result = await _getEImzoStatus(documentId);
        return result.fold(
          (failure) => throw EImzoPollingException(failure.message),
          (status) => status,
        );
      }

      final readyStatus = await _eimzoMobileService.waitForCompletion(
        session: session,
        getStatus: getStatus,
        stopWhenWaiting: true,
      );
      if (!readyStatus.isWaiting) {
        throw const EImzoPollingException('E-Imzo tayyor holatga o‘tmadi');
      }

      _log('E-Imzo server is ready; opening ID-CARD app');
      await _eimzoMobileService.launch(session);
      emit(state.copyWith(status: LoginStatus.eimzoWaiting));
      await _eimzoMobileService.waitForCompletion(
        session: session,
        getStatus: getStatus,
      );
    } on EImzoLaunchException {
      emit(
        state.copyWith(
          status: LoginStatus.eimzoFailure,
          errorMessage: 'E-Imzo ID-CARD ilovasi ochilmadi',
        ),
      );
      return;
    } on EImzoPollingException catch (error) {
      emit(
        state.copyWith(
          status: LoginStatus.eimzoFailure,
          errorMessage: error.message,
        ),
      );
      return;
    } catch (_) {
      emit(
        state.copyWith(
          status: LoginStatus.eimzoFailure,
          errorMessage: 'E-Imzo tasdiqlanmadi',
        ),
      );
      return;
    }

    emit(state.copyWith(status: LoginStatus.eimzoCompleting));
    _log(
      'E-Imzo status=1; sending final mobile auth for '
      'documentId=${session.documentId}',
    );
    final completeResult = await _completeEImzoLogin(
      EImzoMobileAuthParams(
        documentId: session.documentId,
        employeeId: employeeId,
      ),
    );
    completeResult.fold(
      (failure) {
        _log('Final E-Imzo auth failed: ${failure.message}');
        emit(
          state.copyWith(
            status: LoginStatus.eimzoFailure,
            errorMessage: failure.message,
          ),
        );
      },
      (_) {
        _log('Final E-Imzo auth succeeded; tokens persisted');
        emit(state.copyWith(status: LoginStatus.success));
      },
    );
  }

  void _onEImzoResetRequested(
    EImzoResetRequested event,
    Emitter<LoginState> emit,
  ) {
    _eimzoMobileService.cancel();
    _credentialEmployeeId = null;
    emit(const LoginState());
  }

  Future<void> _onLoadProfile(
    LoadUserProfile event,
    Emitter<LoginState> emit,
  ) async {
    emit(state.copyWith(status: LoginStatus.loading, errorMessage: ''));

    final result = await _loadProfile(const NoParams());
    result.fold(
      (failure) => emit(
        state.copyWith(status: LoginStatus.fail, errorMessage: failure.message),
      ),
      (user) => emit(state.copyWith(status: LoginStatus.success, user: user)),
    );
  }

  Future<void> _onProfilePhotoUploaded(
    ProfilePhotoUploaded event,
    Emitter<LoginState> emit,
  ) async {
    emit(state.copyWith(status: LoginStatus.loading, errorMessage: ''));
    final result = await _updateProfilePhoto(
      userId: event.userId,
      photo: event.photo,
    );
    result.fold(
      (failure) => emit(
        state.copyWith(status: LoginStatus.fail, errorMessage: failure.message),
      ),
      (user) => emit(state.copyWith(status: LoginStatus.success, user: user)),
    );
  }

  @override
  Future<void> close() {
    _eimzoMobileService.cancel();
    return super.close();
  }

  void _log(String message) {
    if (kDebugMode) debugPrint('[E-Imzo Auth] $message');
  }
}
