part of 'login_bloc.dart';

enum LoginStatus { initial, loading, success, fail }

class LoginState extends Equatable {
  final LoginStatus status;
  final bool requiresAgreement;
  final User? user;
  final String errorMessage;
  final String savedUsername;

  const LoginState({
    this.status = LoginStatus.initial,
    this.requiresAgreement = false,
    this.user,
    this.errorMessage = '',
    this.savedUsername = '',
  });

  LoginState copyWith({
    LoginStatus? status,
    bool? requiresAgreement,
    User? user,
    String? errorMessage,
    String? savedUsername,
  }) {
    return LoginState(
      status: status ?? this.status,
      requiresAgreement: requiresAgreement ?? this.requiresAgreement,
      user: user ?? this.user,
      errorMessage: errorMessage ?? this.errorMessage,
      savedUsername: savedUsername ?? this.savedUsername,
    );
  }

  @override
  List<Object?> get props =>
      [status, requiresAgreement, user, errorMessage, savedUsername];
}
