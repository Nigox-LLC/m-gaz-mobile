part of 'profile_bloc.dart';

final class ProfileState extends Equatable {
  const ProfileState({
    this.profileLoadStatus = Status.initial,
    this.profileData,
    this.errorMessage = '',
  });

  final Status profileLoadStatus;
  final ProfileEntity? profileData;
  final String errorMessage;

  ProfileState copyWith({
    Status? profileLoadStatus,
    ProfileEntity? profileData,
    String? errorMessage,
  }) {
    return ProfileState(
      profileLoadStatus: profileLoadStatus ?? this.profileLoadStatus,
      profileData: profileData ?? this.profileData,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [profileLoadStatus, profileData, errorMessage];
}
