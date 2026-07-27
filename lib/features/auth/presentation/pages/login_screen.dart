import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:m_gaz/app/injection.dart';
import 'package:m_gaz/core/common/words.dart';
import 'package:m_gaz/core/extension/message_extension.dart';
import 'package:m_gaz/core/extension/navigator_extension.dart';
import 'package:m_gaz/core/usecase/usecase.dart';
import 'package:m_gaz/features/auth/domain/usecases/get_saved_username_usecase.dart';
import 'package:m_gaz/features/auth/presentation/bloc/login_bloc.dart';
import 'package:m_gaz/features/auth/presentation/widgets/login_button.dart';
import 'package:m_gaz/features/auth/presentation/widgets/login_text_field.dart';
import 'package:m_gaz/global_widget/app_tools.dart';
import 'package:m_gaz/ui/auth/attendance/agreement_screen.dart';
import 'package:m_gaz/ui/auth/attendance/bloc/attendance_bloc.dart';
import 'package:m_gaz/ui/auth/attendance/bloc/attendance_event.dart';
import 'package:m_gaz/ui/auth/attendance/bloc/attendance_state.dart';

import '../../../../ui/home/home_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  static const _backgroundColor = Color(0xFFFCFCFC);
  static const _headingColor = Color(0xFF1A1D2E);
  static const _formHorizontalPadding = 20.0;
  static const _formMaxWidth = 350.0;

  final userNameController = TextEditingController();
  final passwordController = TextEditingController();

  bool _obscurePassword = true;
  String? _authErrorMessage;
  // Faqat shu ekrandan yuborilgan login natijasiga reaksiya qilamiz — bloc
  // singleton'da qolib ketgan eski `success` state home'ga sakratib yubormasin.
  bool _submitted = false;
  // Login muvaffaqiyatli bo'lgandan keyin backend yo'qlama tekshiruvi
  // (AttendanceCheckAccess) davom etayotganini bildiradi.
  bool _checkingAttendance = false;

  bool _isEimzoStep(LoginStatus status) => switch (status) {
    LoginStatus.eimzoReady ||
    LoginStatus.eimzoLaunching ||
    LoginStatus.eimzoWaiting ||
    LoginStatus.eimzoCompleting => true,
    _ => false,
  };

  bool get _hasInput =>
      userNameController.text.trim().isNotEmpty &&
      passwordController.text.trim().isNotEmpty;

  bool get _hasAuthError => _authErrorMessage != null;

  @override
  void initState() {
    super.initState();
    userNameController.addListener(_handleInputChanged);
    passwordController.addListener(_handleInputChanged);
    _prefillSavedUsername();
  }

  // Saqlangan foydalanuvchi nomini har safar ekran ochilganda (cold start,
  // relaunch, orqa fondan qaytish) to'g'ridan-to'g'ri storage'dan o'qib prefill
  // qilamiz. Bloc app-level singleton bo'lgani uchun uning state'iga tayanmaymiz:
  // eski/teng state listener'ni qayta ishga tushirmaydi va prefill o'tkazib
  // yuboriladi.
  Future<void> _prefillSavedUsername() async {
    final result = await getIt<GetSavedUsernameUseCase>()(const NoParams());
    final name = result.getOrElse(() => '');
    if (!mounted || name.isEmpty) return;
    if (userNameController.text.isEmpty) {
      userNameController.text = name;
    }
  }

  @override
  void dispose() {
    userNameController.removeListener(_handleInputChanged);
    passwordController.removeListener(_handleInputChanged);
    userNameController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  void _handleInputChanged() {
    if (_authErrorMessage != null) {
      _authErrorMessage = null;
    }
    if (mounted) {
      setState(() {});
    }
  }

  void _clearController(TextEditingController controller) {
    controller.clear();
    _handleInputChanged();
  }

  void _login(BuildContext context) {
    if (_checkingAttendance) return;

    if (!_hasInput) {
      showToast(context, Words.loginRequiredFields.tr());
      return;
    }

    if (_hasAuthError) {
      return;
    }

    _submitted = true;
    context.read<LoginBloc>().add(
      LoginSubmitted(
        userName: userNameController.text.trim(),
        password: passwordController.text.trim(),
      ),
    );
  }

  // Auth muvaffaqiyatli — endi lokal sana emas, backend GET orqali bugungi
  // yo'qlama holatini so'raymiz (AttendanceCheckAccess).
  void _onLoginState(BuildContext context, LoginState state) {
    if (!_submitted) return;

    if (state.status == LoginStatus.fail) {
      setState(() {
        _authErrorMessage = Words.loginInvalidCredentials.tr();
        _checkingAttendance = false;
      });
      if (state.errorMessage.isNotEmpty) {
        showToast(context, state.errorMessage);
      }
      return;
    }

    if (state.status == LoginStatus.eimzoFailure) {
      setState(() {
        _submitted = false;
        _checkingAttendance = false;
        _authErrorMessage = null;
        passwordController.clear();
      });
      showToast(context, state.errorMessage);
      return;
    }

    if (state.status == LoginStatus.success && !_checkingAttendance) {
      _startAttendanceCheck(context);
    }
  }

  void _startAttendanceCheck(BuildContext context) {
    if (_checkingAttendance) return;
    setState(() => _checkingAttendance = true);
    context.read<AttendanceBloc>().add(AttendanceCheckAccess());
  }

  // Backend javobiga ko'ra yo'naltirish:
  //   already_attended == false (accessAllowed) → AgreementPdfScreen
  //   already_attended == true  (accessBlocked) → HomeScreen
  void _onAttendanceState(BuildContext context, AttendanceState state) {
    if (!_checkingAttendance) return;

    switch (state.status) {
      case AttendanceStatus.accessAllowed:
        _checkingAttendance = false;
        pushAndRemoveUntil(AgreementPdfScreen());
        break;
      case AttendanceStatus.accessBlocked:
        _checkingAttendance = false;
        pushAndRemoveUntil(HomeScreen());
        break;
      case AttendanceStatus.fail:
        setState(() => _checkingAttendance = false);
        showToast(context, state.error ?? Words.errorOccurred.tr());
        break;
      default:
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarBrightness: Brightness.light,
        statusBarIconBrightness: Brightness.dark,
      ),
      child: Scaffold(
        resizeToAvoidBottomInset: true,
        backgroundColor: _backgroundColor,
        body: MultiBlocListener(
          listeners: [
            BlocListener<LoginBloc, LoginState>(
              listenWhen: (prev, curr) => prev.status != curr.status,
              listener: _onLoginState,
            ),
            BlocListener<AttendanceBloc, AttendanceState>(
              listenWhen: (prev, curr) => prev.status != curr.status,
              listener: _onAttendanceState,
            ),
          ],
          child: SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final viewInsets = MediaQuery.viewInsetsOf(context);
                final formWidth = math.min(
                  _formMaxWidth,
                  math.max(
                    0.0,
                    constraints.maxWidth - (_formHorizontalPadding * 2),
                  ),
                );
                final isShortHeight = constraints.maxHeight < 700;
                final logoTopSpacing = isShortHeight ? 24.0 : 68.0;
                final logoFormSpacing = isShortHeight ? 32.0 : 58.0;

                return SingleChildScrollView(
                  keyboardDismissBehavior:
                      ScrollViewKeyboardDismissBehavior.onDrag,
                  padding: EdgeInsets.fromLTRB(
                    _formHorizontalPadding,
                    0,
                    _formHorizontalPadding,
                    24 + viewInsets.bottom,
                  ),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minHeight: math.max(
                        0.0,
                        constraints.maxHeight - viewInsets.bottom,
                      ),
                    ),
                    child: Center(
                      child: SizedBox(
                        width: formWidth,
                        child: BlocBuilder<LoginBloc, LoginState>(
                          builder: (context, state) {
                            final showEimzo = _isEimzoStep(state.status);
                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                SizedBox(height: logoTopSpacing),
                                AppTools.img(
                                  AppTools.splashLogo,
                                  width: 104,
                                  height: 104,
                                ),
                                SizedBox(height: logoFormSpacing),
                                if (showEimzo)
                                  _EImzoVerificationCard(
                                    status: state.status,
                                    onVerify: () =>
                                        context.read<LoginBloc>().add(
                                          const EImzoVerificationRequested(),
                                        ),
                                    onBack: () {
                                      passwordController.clear();
                                      _submitted = false;
                                      context.read<LoginBloc>().add(
                                        const EImzoResetRequested(),
                                      );
                                    },
                                  )
                                else
                                  _LoginForm(
                                    userNameController: userNameController,
                                    passwordController: passwordController,
                                    obscurePassword: _obscurePassword,
                                    authErrorMessage: _authErrorMessage,
                                    onClearUserName: () =>
                                        _clearController(userNameController),
                                    onClearPassword: () =>
                                        _clearController(passwordController),
                                    onTogglePassword: () {
                                      setState(() {
                                        _obscurePassword = !_obscurePassword;
                                      });
                                    },
                                    onSubmit: () => _login(context),
                                    hasInput: _hasInput,
                                    hasAuthError: _hasAuthError,
                                    externalBusy: _checkingAttendance,
                                  ),
                                const SizedBox(height: 24),
                              ],
                            );
                          },
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}

class _LoginForm extends StatelessWidget {
  const _LoginForm({
    required this.userNameController,
    required this.passwordController,
    required this.obscurePassword,
    required this.authErrorMessage,
    required this.onClearUserName,
    required this.onClearPassword,
    required this.onTogglePassword,
    required this.onSubmit,
    required this.hasInput,
    required this.hasAuthError,
    required this.externalBusy,
  });

  final TextEditingController userNameController;
  final TextEditingController passwordController;
  final bool obscurePassword;
  final String? authErrorMessage;
  final VoidCallback onClearUserName;
  final VoidCallback onClearPassword;
  final VoidCallback onTogglePassword;
  final VoidCallback onSubmit;
  final bool hasInput;
  final bool hasAuthError;
  // Auth muvaffaqiyatli, lekin backend yo'qlama tekshiruvi davom etayotgan davr —
  // tugma yuklanish holatida va o'chirilgan bo'lib turadi.
  final bool externalBusy;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LoginBloc, LoginState>(
      builder: (context, state) {
        final isLoading = state.status == LoginStatus.loading || externalBusy;
        final isEnabled = hasInput && !hasAuthError && !isLoading;
        final hasError = authErrorMessage != null;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              Words.loginTitle.tr(),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.manrope(
                color: _LoginScreenState._headingColor,
                fontSize: 28,
                fontWeight: FontWeight.w800,
                height: 32 / 28,
              ),
            ),
            const SizedBox(height: 16),
            LoginTextField(
              key: const ValueKey('login_username_field'),
              controller: userNameController,
              label: Words.loginUsernameLabel.tr(),
              hintText: Words.loginUsernameHint.tr(),
              enabled: !isLoading,
              hasError: hasError,
              textInputAction: TextInputAction.next,
              onClear: onClearUserName,
            ),
            const SizedBox(height: 12),
            LoginTextField(
              key: const ValueKey('login_password_field'),
              controller: passwordController,
              label: Words.loginPasswordLabel.tr(),
              hintText: Words.loginPasswordHint.tr(),
              enabled: !isLoading,
              hasError: hasError,
              errorText: authErrorMessage,
              obscureText: obscurePassword,
              textInputAction: TextInputAction.done,
              onSubmitted: (_) => onSubmit(),
              onClear: onClearPassword,
              onToggleObscure: onTogglePassword,
            ),
            const SizedBox(height: 20),
            LoginButton(
              key: const ValueKey('login_submit_button'),
              title: Words.loginSubmit.tr(),
              isEnabled: isEnabled,
              isLoading: isLoading,
              onPressed: onSubmit,
            ),
          ],
        );
      },
    );
  }
}

class _EImzoVerificationCard extends StatelessWidget {
  const _EImzoVerificationCard({
    required this.status,
    required this.onVerify,
    required this.onBack,
  });

  final LoginStatus status;
  final VoidCallback onVerify;
  final VoidCallback onBack;

  bool get _isBusy =>
      status == LoginStatus.eimzoLaunching ||
      status == LoginStatus.eimzoWaiting ||
      status == LoginStatus.eimzoCompleting;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFFBFCFF),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFE0E4F0)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0D1A1D2E),
            blurRadius: 12,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFE9ECF6),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 36,
                  height: 36,
                  alignment: Alignment.center,
                  decoration: const BoxDecoration(
                    color: Color(0xFFE6EDFF),
                    shape: BoxShape.circle,
                  ),
                  child: SvgPicture.asset(
                    'assets/icons/ic_hugeicons_shield_key.svg',
                    width: 24,
                    height: 24,
                    colorFilter: const ColorFilter.mode(
                      Color(0xFF245BFF),
                      BlendMode.srcIn,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                const Expanded(child: _EImzoCardText()),
              ],
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            height: 52,
            child: Material(
              color: const Color(0xFF354B9A),
              borderRadius: BorderRadius.circular(12),
              child: InkWell(
                borderRadius: BorderRadius.circular(12),
                onTap: _isBusy ? null : onVerify,
                child: Center(
                  child: _isBusy
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.check_circle_outline_rounded,
                              color: Colors.white,
                              size: 22,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              Words.eimzoVerify.tr(),
                              style: GoogleFonts.manrope(
                                color: Colors.white,
                                fontSize: 15,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ],
                        ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          TextButton.icon(
            onPressed: _isBusy ? null : onBack,
            icon: const Icon(
              Icons.arrow_back,
              color: Color(0xFF202020),
              size: 20,
            ),
            label: Text(
              Words.eimzoBack.tr(),
              style: GoogleFonts.manrope(
                color: const Color(0xFF202020),
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _EImzoCardText extends StatelessWidget {
  const _EImzoCardText();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          Words.eimzoTitle.tr(),
          style: GoogleFonts.manrope(
            color: const Color(0xFF1A1D2E),
            fontSize: 16,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          Words.eimzoDescription.tr(),
          style: GoogleFonts.manrope(
            color: const Color(0xFF1A1D2E),
            fontSize: 13,
            height: 18 / 13,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
