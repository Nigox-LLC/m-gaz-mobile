import 'dart:io';

import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:m_gaz/core/error/failures.dart';
import 'package:m_gaz/features/auth/domain/entities/auth_token.dart';
import 'package:m_gaz/features/auth/domain/entities/user.dart';
import 'package:m_gaz/features/auth/domain/repositories/auth_repository.dart';
import 'package:m_gaz/features/auth/domain/services/biometric_auth_service.dart';
import 'package:m_gaz/features/auth/domain/usecases/get_saved_username_usecase.dart';
import 'package:m_gaz/features/auth/domain/usecases/has_stored_session_usecase.dart';
import 'package:m_gaz/features/auth/domain/usecases/load_user_profile_usecase.dart';
import 'package:m_gaz/features/auth/domain/usecases/login_usecase.dart';
import 'package:m_gaz/features/auth/domain/usecases/mark_session_active_usecase.dart';
import 'package:m_gaz/features/auth/domain/usecases/update_profile_photo_usecase.dart';
import 'package:m_gaz/features/auth/presentation/bloc/login_bloc.dart';

void main() {
  test(
    'biometric success restores stored session without password login',
    () async {
      final repository = _FakeAuthRepository(hasSession: true);
      final bloc = LoginBloc(
        LoginUseCase(repository),
        LoadUserProfileUseCase(repository),
        GetSavedUsernameUseCase(repository),
        UpdateProfilePhotoUseCase(repository),
        const _FakeBiometricAuthService(BiometricResult.success),
        HasStoredSessionUseCase(repository),
        MarkSessionActiveUseCase(repository),
      );
      addTearDown(bloc.close);

      final available = bloc.stream.firstWhere(
        (state) =>
            state.biometricAvailability == BiometricAvailability.available,
      );
      bloc.add(const CheckBiometricAvailability());
      await available;

      final unlocked = bloc.stream.firstWhere(
        (state) => state.biometricResult == BiometricResult.success,
      );
      bloc.add(const BiometricUnlockRequested(reason: 'Unlock'));
      final state = await unlocked;

      expect(state.isBiometricPromptInProgress, isFalse);
      expect(repository.loginCalls, 0);
      expect(repository.markActiveCalls, 1);
    },
  );
}

class _FakeBiometricAuthService implements BiometricAuthService {
  const _FakeBiometricAuthService(this.result);

  final BiometricResult result;

  @override
  Future<BiometricAvailability> availability() async =>
      BiometricAvailability.available;

  @override
  Future<BiometricResult> authenticate({required String reason}) async =>
      result;
}

class _FakeAuthRepository implements AuthRepository {
  _FakeAuthRepository({required this.hasSession});

  final bool hasSession;
  int loginCalls = 0;
  int markActiveCalls = 0;

  @override
  Future<Either<Failure, AuthToken>> login({
    required String userName,
    required String password,
  }) async {
    loginCalls++;
    return const Right(AuthToken(access: 'access', refresh: 'refresh'));
  }

  @override
  Future<Either<Failure, String>> getSavedUsername() async => const Right('');

  @override
  Future<Either<Failure, bool>> hasStoredSession() async => Right(hasSession);

  @override
  Future<Either<Failure, User>> loadProfile() async =>
      const Right(User(id: 1, username: 'tester', role: 'tester'));

  @override
  Future<Either<Failure, Unit>> logout() async => const Right(unit);

  @override
  Future<Either<Failure, Unit>> markSessionActive() async {
    markActiveCalls++;
    return const Right(unit);
  }

  @override
  Future<Either<Failure, User>> updateProfilePhoto({
    required int userId,
    required File photo,
  }) async => const Right(User(id: 1, username: 'tester', role: 'tester'));
}
