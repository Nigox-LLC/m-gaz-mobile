part of 'profile_bloc.dart';

final class ProfileState extends Equatable {
  const ProfileState({
    this.profileLoadStatus = Status.initial,
    this.passwordUpdateStatus = Status.initial,
    this.profileData,
    this.errorMessage = '',
  });

  final Status profileLoadStatus;
  final Status passwordUpdateStatus;
  final ProfileEntity? profileData;
  final String errorMessage;

  ProfileState copyWith({
    Status? profileLoadStatus,
    Status? passwordUpdateStatus,
    ProfileEntity? profileData,
    String? errorMessage,
  }) {
    return ProfileState(
      profileLoadStatus: profileLoadStatus ?? this.profileLoadStatus,
      passwordUpdateStatus: passwordUpdateStatus ?? this.passwordUpdateStatus,
      profileData: profileData ?? this.profileData,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [
    profileLoadStatus,
    passwordUpdateStatus,
    profileData,
    errorMessage,
  ];
}
