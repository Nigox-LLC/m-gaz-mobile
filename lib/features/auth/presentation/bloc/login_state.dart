part of 'login_bloc.dart';

enum LoginStatus { initial, loading, success, fail }

class LoginState extends Equatable {
  final LoginStatus status;
  final User? user;
  final String errorMessage;
  final String savedUsername;
  final BiometricAvailability biometricAvailability;
  final BiometricResult? biometricResult;
  final bool hasStoredSession;
  final bool isBiometricPromptInProgress;

  const LoginState({
    this.status = LoginStatus.initial,
    this.user,
    this.errorMessage = '',
    this.savedUsername = '',
    this.biometricAvailability = BiometricAvailability.unknown,
    this.biometricResult,
    this.hasStoredSession = false,
    this.isBiometricPromptInProgress = false,
  });

  LoginState copyWith({
    LoginStatus? status,
    User? user,
    String? errorMessage,
    String? savedUsername,
    BiometricAvailability? biometricAvailability,
    BiometricResult? biometricResult,
    bool clearBiometricResult = false,
    bool? hasStoredSession,
    bool? isBiometricPromptInProgress,
  }) {
    return LoginState(
      status: status ?? this.status,
      user: user ?? this.user,
      errorMessage: errorMessage ?? this.errorMessage,
      savedUsername: savedUsername ?? this.savedUsername,
      biometricAvailability:
          biometricAvailability ?? this.biometricAvailability,
      biometricResult: clearBiometricResult
          ? null
          : biometricResult ?? this.biometricResult,
      hasStoredSession: hasStoredSession ?? this.hasStoredSession,
      isBiometricPromptInProgress:
          isBiometricPromptInProgress ?? this.isBiometricPromptInProgress,
    );
  }

  @override
  List<Object?> get props => [
    status,
    user,
    errorMessage,
    savedUsername,
    biometricAvailability,
    biometricResult,
    hasStoredSession,
    isBiometricPromptInProgress,
  ];
}
