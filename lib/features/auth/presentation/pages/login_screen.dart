import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
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
        body: BlocListener<LoginBloc, LoginState>(
          listener: (context, state) {
            // Faqat shu ekrandan yuborilgan login natijasini hisobga olamiz.
            if (!_submitted) return;
            if (state.status == LoginStatus.fail) {
              setState(() {
                _authErrorMessage = Words.loginInvalidCredentials.tr();
              });
              if (state.errorMessage.isNotEmpty) {
                showToast(context, state.errorMessage);
              }
            }
            if (state.status == LoginStatus.success) {
              if (state.requiresAgreement) {
                pushAndRemoveUntil(AgreementPdfScreen());
              } else {
                pushAndRemoveUntil(HomeScreen());
              }
            }
          },
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
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            SizedBox(height: logoTopSpacing),
                            AppTools.img(
                              AppTools.splashLogo,
                              width: 104,
                              height: 104,
                            ),
                            SizedBox(height: logoFormSpacing),
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
                            ),
                            const SizedBox(height: 24),
                          ],
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

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LoginBloc, LoginState>(
      builder: (context, state) {
        final isLoading = state.status == LoginStatus.loading;
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
