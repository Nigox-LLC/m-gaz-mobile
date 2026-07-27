part of 'profile_bloc.dart';

sealed class ProfileEvent extends Equatable {}

class GetProfileDataEvent extends ProfileEvent {
  @override
  List<Object?> get props => [];
}

class UpdatePasswordEvent extends ProfileEvent {
  UpdatePasswordEvent({required this.userId, required this.password});

  final int userId;
  final String password;

  @override
  List<Object?> get props => [userId, password];
}
