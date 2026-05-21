part of 'login_bloc.dart';

enum LoginStatus { initial, loading, success, fail }

class LoginState extends Equatable {
  final LoginStatus status;
  final bool requiresAgreement;
  final User? user;
  final String errorMessage;

  const LoginState({
    this.status = LoginStatus.initial,
    this.requiresAgreement = false,
    this.user,
    this.errorMessage = '',
  });

  LoginState copyWith({
    LoginStatus? status,
    bool? requiresAgreement,
    User? user,
    String? errorMessage,
  }) {
    return LoginState(
      status: status ?? this.status,
      requiresAgreement: requiresAgreement ?? this.requiresAgreement,
      user: user ?? this.user,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, requiresAgreement, user, errorMessage];
}
