import 'dart:io';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/usecase/usecase.dart';
import '../../domain/entities/user.dart';
import '../../domain/usecases/get_saved_username_usecase.dart';
import '../../domain/usecases/load_user_profile_usecase.dart';
import '../../domain/usecases/login_usecase.dart';
import '../../domain/usecases/update_profile_photo_usecase.dart';

part 'login_event.dart';
part 'login_state.dart';

@injectable
class LoginBloc extends Bloc<LoginEvent, LoginState> {
  final LoginUseCase _login;
  final LoadUserProfileUseCase _loadProfile;
  final GetSavedUsernameUseCase _getSavedUsername;
  final UpdateProfilePhotoUseCase _updateProfilePhoto;

  LoginBloc(
    this._login,
    this._loadProfile,
    this._getSavedUsername,
    this._updateProfilePhoto,
  ) : super(const LoginState()) {
    on<LoginSubmitted>(_onSubmitted);
    on<LoadUserProfile>(_onLoadProfile);
    on<LoadSavedUsername>(_onLoadSavedUsername);
    on<ProfilePhotoUploaded>(_onProfilePhotoUploaded);
  }

  Future<void> _onLoadSavedUsername(
    LoadSavedUsername event,
    Emitter<LoginState> emit,
  ) async {
    final result = await _getSavedUsername(const NoParams());
    final username = result.getOrElse(() => '');
    if (username.isNotEmpty) {
      emit(state.copyWith(savedUsername: username));
    }
  }

  Future<void> _onSubmitted(
    LoginSubmitted event,
    Emitter<LoginState> emit,
  ) async {
    emit(state.copyWith(status: LoginStatus.loading, errorMessage: ''));

    final result = await _login(
      LoginParams(userName: event.userName, password: event.password),
    );

    result.fold(
      (failure) => emit(
        state.copyWith(status: LoginStatus.fail, errorMessage: failure.message),
      ),
      // Yo'qlama/kelishuv qarori endi lokal sana emas — backend orqali
      // (AttendanceCheckAccess) login ekranida hal qilinadi.
      (_) => emit(state.copyWith(status: LoginStatus.success)),
    );
  }

  Future<void> _onLoadProfile(
    LoadUserProfile event,
    Emitter<LoginState> emit,
  ) async {
    emit(state.copyWith(status: LoginStatus.loading, errorMessage: ''));

    final result = await _loadProfile(const NoParams());
    result.fold(
      (failure) => emit(
        state.copyWith(status: LoginStatus.fail, errorMessage: failure.message),
      ),
      (user) => emit(state.copyWith(status: LoginStatus.success, user: user)),
    );
  }

  Future<void> _onProfilePhotoUploaded(
    ProfilePhotoUploaded event,
    Emitter<LoginState> emit,
  ) async {
    emit(state.copyWith(status: LoginStatus.loading, errorMessage: ''));
    final result = await _updateProfilePhoto(
      userId: event.userId,
      photo: event.photo,
    );
    result.fold(
      (failure) => emit(
        state.copyWith(status: LoginStatus.fail, errorMessage: failure.message),
      ),
      (user) => emit(state.copyWith(status: LoginStatus.success, user: user)),
    );
  }
}
