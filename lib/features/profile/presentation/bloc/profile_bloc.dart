import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:m_gaz/core/usecase/usecase.dart';
import 'package:m_gaz/features/profile/domain/entities/profile_entity.dart';
import 'package:m_gaz/features/profile/domain/usecases/load_profile_data_usecase.dart';
import 'package:m_gaz/features/profile/domain/usecases/update_password_usecase.dart';

import '../../../../core/enums/status.dart';

part 'profile_event.dart';
part 'profile_state.dart';

@injectable
class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  ProfileBloc(this._loadProfileData, this._updatePassword)
    : super(const ProfileState()) {
    on<GetProfileDataEvent>(_getProfileData);
    on<UpdatePasswordEvent>(_updatePasswordData);
  }

  final LoadProfileDataUseCase _loadProfileData;
  final UpdatePasswordUseCase _updatePassword;

  Future<void> _getProfileData(
    GetProfileDataEvent event,
    Emitter<ProfileState> emit,
  ) async {
    emit(state.copyWith(profileLoadStatus: Status.loading));

    final result = await _loadProfileData(const NoParams());

    result.fold(
      (failure) => emit(
        state.copyWith(
          profileLoadStatus: Status.error,
          errorMessage: failure.message,
        ),
      ),
      (profile) => emit(
        state.copyWith(profileLoadStatus: Status.success, profileData: profile),
      ),
    );
  }

  Future<void> _updatePasswordData(
    UpdatePasswordEvent event,
    Emitter<ProfileState> emit,
  ) async {
    emit(
      state.copyWith(passwordUpdateStatus: Status.loading, errorMessage: ''),
    );

    final result = await _updatePassword(
      UpdatePasswordParams(userId: event.userId, password: event.password),
    );

    result.fold(
      (failure) => emit(
        state.copyWith(
          passwordUpdateStatus: Status.error,
          errorMessage: failure.message,
        ),
      ),
      (_) => emit(state.copyWith(passwordUpdateStatus: Status.success)),
    );
  }
}
