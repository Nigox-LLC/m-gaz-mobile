part of 'login_bloc.dart';

enum LoginStatus { initial, loading, success, fail }

class LoginState extends Equatable {
  final LoginStatus status;
  final User? user;
  final String errorMessage;
  final String savedUsername;

  const LoginState({
    this.status = LoginStatus.initial,
    this.user,
    this.errorMessage = '',
    this.savedUsername = '',
  });

  LoginState copyWith({
    LoginStatus? status,
    User? user,
    String? errorMessage,
    String? savedUsername,
  }) {
    return LoginState(
      status: status ?? this.status,
      user: user ?? this.user,
      errorMessage: errorMessage ?? this.errorMessage,
      savedUsername: savedUsername ?? this.savedUsername,
    );
  }

  @override
  List<Object?> get props => [status, user, errorMessage, savedUsername];
}
