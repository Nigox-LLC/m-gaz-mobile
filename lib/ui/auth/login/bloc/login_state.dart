part of 'login_bloc.dart';

enum LoginStatus { initial, loading, success, fail }

class LoginState extends Equatable {
  final LoginStatus status;
  final bool requiresAgreement;
  final UserModel? user;
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
    UserModel? user,
    String? errorMessage,
  }) {
    return LoginState(
      status: status ?? this.status,
      requiresAgreement: requiresAgreement ?? this.requiresAgreement,
      errorMessage: errorMessage ?? this.errorMessage,
      user: user ?? this.user,
    );
  }

  @override
  List<Object?> get props => [status, requiresAgreement, errorMessage];
}
