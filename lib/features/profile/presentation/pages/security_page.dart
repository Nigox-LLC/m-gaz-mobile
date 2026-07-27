import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:m_gaz/features/profile/presentation/widgets/personal_data_item.dart';

import '../../../../core/common/words.dart';
import '../../../../core/enums/status.dart';
import '../../../../core/extension/message_extension.dart';
import '../../../../core/extension/size_extension.dart';
import '../../../../global_widget/app_tools.dart';
import '../bloc/profile_bloc.dart';

class SecurityPage extends StatefulWidget {
  const SecurityPage({super.key});

  @override
  State<SecurityPage> createState() => _SecurityPageState();
}

class _SecurityPageState extends State<SecurityPage> {
  final _currentPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _passwordsDoNotMatch = false;

  @override
  void initState() {
    super.initState();
    _newPasswordController.addListener(_clearPasswordError);
    _confirmPasswordController.addListener(_clearPasswordError);
  }

  @override
  void dispose() {
    _newPasswordController.removeListener(_clearPasswordError);
    _confirmPasswordController.removeListener(_clearPasswordError);
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<ProfileBloc, ProfileState>(
      listenWhen: (previous, current) =>
          previous.passwordUpdateStatus != current.passwordUpdateStatus,
      listener: _onPasswordUpdateStateChanged,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: const Color(0xFFFCFCFC),
          elevation: 0,
          title: Text(
            Words.security.tr(),
            style: GoogleFonts.manrope(
              fontSize: 17,
              fontWeight: FontWeight.w800,
              color: Color(0xFF1A1D2E),
            ),
          ),
          leading: IconButton(
            onPressed: () => Navigator.pop(context),
            icon: AppTools.svg(AppTools.icChervonLeft),
            iconSize: 24,
          ),
        ),
        body: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            spacing: 12.h,
            children: [
              PersonalDataItem(
                controller: _currentPasswordController,
                readOnly: false,
                hintText: Words.currentPasswordHint.tr(),
                label: Words.currentPassword.tr(),
                isError: false,
                suffixWidget: AppTools.svg(AppTools.icEye),
              ),
              PersonalDataItem(
                controller: _newPasswordController,
                readOnly: false,
                hintText: Words.newPasswordHint.tr(),
                label: Words.newPassword.tr(),
                isError: _passwordsDoNotMatch,
                suffixWidget: AppTools.svg(AppTools.icEye),
                errorText: Words.passwordsDoNotMatch.tr(),
              ),
              PersonalDataItem(
                controller: _confirmPasswordController,
                readOnly: false,
                hintText: Words.confirmPasswordHint.tr(),
                label: Words.confirmPassword.tr(),
                isError: _passwordsDoNotMatch,
                suffixWidget: AppTools.svg(AppTools.icEye),
                errorText: Words.passwordsDoNotMatch.tr(),
              ),
            ],
          ),
        ),
        bottomNavigationBar: BlocBuilder<ProfileBloc, ProfileState>(
          buildWhen: (previous, current) =>
              previous.passwordUpdateStatus != current.passwordUpdateStatus,
          builder: (context, state) {
            final isLoading = state.passwordUpdateStatus == Status.loading;
            return Padding(
              padding: EdgeInsets.fromLTRB(20, 0, 20, 20),
              child: ElevatedButton(
                onPressed: isLoading ? null : _submit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF526ED3),
                  minimumSize: Size(MediaQuery.of(context).size.width, 56.h),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: isLoading
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        spacing: 8,
                        children: [
                          AppTools.svg(
                            AppTools.check,
                            colorFilter: ColorFilter.mode(
                              Colors.white,
                              BlendMode.srcIn,
                            ),
                          ),
                          Text(
                            Words.save.tr(),
                            style: GoogleFonts.manrope(
                              fontSize: 15,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
              ),
            );
          },
        ),
      ),
    );
  }

  void _submit() {
    final newPassword = _newPasswordController.text.trim();
    final confirmPassword = _confirmPasswordController.text.trim();

    if (newPassword.isEmpty || confirmPassword.isEmpty) {
      _showToast("Yangi parolni kiriting");
      return;
    }
    if (newPassword != confirmPassword) {
      setState(() => _passwordsDoNotMatch = true);
      _showToast(Words.passwordsDoNotMatch.tr());
      return;
    }

    final profile = context.read<ProfileBloc>().state.profileData;
    if (profile == null) {
      _showToast("Profil ma'lumoti yuklanmagan");
      return;
    }

    setState(() => _passwordsDoNotMatch = false);
    context.read<ProfileBloc>().add(
      UpdatePasswordEvent(userId: profile.id, password: newPassword),
    );
  }

  void _onPasswordUpdateStateChanged(BuildContext context, ProfileState state) {
    if (state.passwordUpdateStatus == Status.success) {
      _currentPasswordController.clear();
      _newPasswordController.clear();
      _confirmPasswordController.clear();
      _showToast("Parol o'zgartirildi", success: true);
      Navigator.pop(context);
      return;
    }
    if (state.passwordUpdateStatus == Status.error) {
      _showToast(state.errorMessage);
    }
  }

  void _clearPasswordError() {
    if (!_passwordsDoNotMatch) return;
    setState(() => _passwordsDoNotMatch = false);
  }

  void _showToast(String message, {bool success = false}) {
    showToast(
      context,
      message,
      backgroundColor: success
          ? const Color(0xFF17B26A)
          : const Color(0xFFFB3748),
    );
  }
}
