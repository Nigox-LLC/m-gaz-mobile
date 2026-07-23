part of 'login_bloc.dart';

abstract class LoginEvent extends Equatable {
  const LoginEvent();

  @override
  List<Object?> get props => [];
}

class LoginSubmitted extends LoginEvent {
  final String userName;
  final String password;

  const LoginSubmitted({required this.userName, required this.password});

  @override
  List<Object?> get props => [userName, password];
}

class LoadUserProfile extends LoginEvent {
  const LoadUserProfile();
}

/// Loads the last saved username so the login form can be pre-filled.
class LoadSavedUsername extends LoginEvent {
  const LoadSavedUsername();
}

class ProfilePhotoUploaded extends LoginEvent {
  const ProfilePhotoUploaded({required this.userId, required this.photo});

  final int userId;
  final File photo;

  @override
  List<Object?> get props => [userId, photo];
}
