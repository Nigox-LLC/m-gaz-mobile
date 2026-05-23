import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/usecase/usecase.dart';
import '../../domain/entities/user.dart';
import '../../domain/usecases/check_daily_agreement_usecase.dart';
import '../../domain/usecases/load_user_profile_usecase.dart';
import '../../domain/usecases/login_usecase.dart';

part 'login_event.dart';
part 'login_state.dart';

@injectable
class LoginBloc extends Bloc<LoginEvent, LoginState> {
  final LoginUseCase _login;
  final LoadUserProfileUseCase _loadProfile;
  final CheckDailyAgreementUseCase _checkAgreement;

  LoginBloc(this._login, this._loadProfile, this._checkAgreement)
      : super(const LoginState()) {
    on<LoginSubmitted>(_onSubmitted);
    on<LoadUserProfile>(_onLoadProfile);
  }

  Future<void> _onSubmitted(
    LoginSubmitted event,
    Emitter<LoginState> emit,
  ) async {
    emit(state.copyWith(status: LoginStatus.loading, errorMessage: ''));

    final result = await _login(
      LoginParams(userName: event.userName, password: event.password),
    );

    await result.fold(
      (failure) async {
        emit(state.copyWith(
          status: LoginStatus.fail,
          errorMessage: failure.message,
        ));
      },
      (_) async {
        final agreementResult = await _checkAgreement(const NoParams());
        final requiresAgreement = agreementResult.getOrElse(() => false);
        emit(state.copyWith(
          status: LoginStatus.success,
          requiresAgreement: requiresAgreement,
        ));
      },
    );
  }

  Future<void> _onLoadProfile(
    LoadUserProfile event,
    Emitter<LoginState> emit,
  ) async {
    emit(state.copyWith(status: LoginStatus.loading, errorMessage: ''));

    final result = await _loadProfile(const NoParams());
    result.fold(
      (failure) => emit(state.copyWith(
        status: LoginStatus.fail,
        errorMessage: failure.message,
      )),
      (user) => emit(state.copyWith(
        status: LoginStatus.success,
        user: user,
      )),
    );
  }
}
