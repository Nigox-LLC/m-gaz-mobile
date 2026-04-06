import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/api/user/user_api.dart';
import '../../../../core/models/user/user_model.dart';
import '../../../../di.dart';

part 'login_event.dart';
part 'login_state.dart';

class LoginBloc extends Bloc<LoginEvent, LoginState> {
  final UserApi _apiUser;

  LoginBloc({UserApi? apiUser})
      : _apiUser = apiUser ?? di.get<UserApi>(),
        super(const LoginState()) {
    on<LoginSubmitted>(_onLoginSubmitted);
    on<LoadUserProfile>(_onLoadUserProfile);
  }

  Future<void> _onLoginSubmitted(
    LoginSubmitted event,
    Emitter<LoginState> emit,
  ) async {
    emit(state.copyWith(status: LoginStatus.loading));
    try {
      await _apiUser.loginUser(
        userName: event.userName,
        password: event.password,
      );

      // Check for daily agreement
      final today = DateTime.now();
      final todayStr = "${today.year}-${today.month}-${today.day}";
      final lastDate = _apiUser.hive.lastAgreementDate;
      bool requiresAgreement = false;

      if (lastDate != todayStr) {
        _apiUser.hive.lastAgreementDate = todayStr;
        requiresAgreement = true;
      }

      emit(state.copyWith(
        status: LoginStatus.success,
        requiresAgreement: requiresAgreement,
      ));
    } catch (e) {
      emit(
        state.copyWith(
          status: LoginStatus.fail,
          errorMessage: e.toString().replaceAll("Exception: ", ""),
        ),
      );
    }
  }

  Future<void> _onLoadUserProfile(
    LoadUserProfile event,
    Emitter<LoginState> emit,
  ) async {
    emit(state.copyWith(status: LoginStatus.loading));

    try {
      final user = await _apiUser.loadUserProfile();
      emit(state.copyWith(
        status: LoginStatus.success,
        user: user,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: LoginStatus.fail,
        errorMessage: e.toString().replaceAll("Exception: ", ""),
      ));
    }
  }
}

