import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:m_gaz/app/injection.dart';
import 'package:m_gaz/core/common/words.dart';
import 'package:m_gaz/core/extension/size_extension.dart';
import 'package:m_gaz/core/storage/local_storage.dart';
import 'package:m_gaz/core/usecase/usecase.dart';
import 'package:m_gaz/features/auth/domain/usecases/logout_usecase.dart';
import 'package:m_gaz/features/auth/presentation/pages/login_screen.dart';
import 'package:m_gaz/features/profile/presentation/bloc/profile_bloc.dart';
import 'package:m_gaz/features/profile/presentation/widgets/custom_logout_dialog.dart';
import 'package:m_gaz/features/profile/presentation/widgets/personal_data_item.dart';
import 'package:m_gaz/global_widget/app_tools.dart';

class PersonalDataPage extends StatefulWidget {
  const PersonalDataPage({super.key});

  @override
  State<PersonalDataPage> createState() => _PersonalDataPageState();
}

class _PersonalDataPageState extends State<PersonalDataPage> {
  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => CustomLogoutDialog(
        onPressed: () {
          Navigator.pop(dialogContext);
          _logout();
        },
        onCancel: () => Navigator.pop(dialogContext),
      ),
    );
  }

  /// Hard-wipes all local session state (Hive auth box including the saved
  /// username + shared preferences cache) and returns the user to the login
  /// screen.
  Future<void> _logout() async {
    await getIt<LogoutUseCase>()(const NoParams());
    await StorageRepository.clear();

    if (!mounted) return;
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final profile = context.watch<ProfileBloc>().state.profileData;
    final dash = '—';
    final role = (profile?.role.trim().isNotEmpty ?? false) ? profile!.role.trim() : dash;
    final region = (profile?.regionName?.trim().isNotEmpty ?? false) ? profile!.regionName!.trim() : dash;
    final district = (profile?.districtName?.trim().isNotEmpty ?? false) ? profile!.districtName!.trim() : dash;
    final phone = (profile?.phone?.trim().isNotEmpty ?? false) ? profile!.phone!.trim() : dash;

    return Scaffold(
      backgroundColor: const Color(0xFFFCFCFC),
      appBar: AppBar(
        backgroundColor: const Color(0xFFFCFCFC),
        elevation: 0,
        title: Text(
          Words.personalInfo.tr(),
          style: GoogleFonts.manrope(fontSize: 17, fontWeight: FontWeight.w800, color: Color(0xFF1A1D2E)),
        ),
        leading: IconButton(onPressed: () => Navigator.pop(context), icon: AppTools.svg(AppTools.icChervonLeft), iconSize: 24),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 20),
        child: Column(
          spacing: 12.h,
          children: [
            PersonalDataItem(label: Words.position.tr(), text: role),
            PersonalDataItem(label: Words.phone.tr(), text: phone),
            PersonalDataItem(label: Words.region.tr(), text: region),
            PersonalDataItem(label: Words.district.tr(), text: district),
          ],
        ),
      ),
      bottomNavigationBar: Padding(
        padding: EdgeInsets.fromLTRB(20, 0, 20, 20),
        child: ElevatedButton(
          onPressed: () => _showLogoutDialog(context),
          style: ElevatedButton.styleFrom(
            backgroundColor: Color(0xFFFFC0C5),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(44)),
            // To'liq kenglik uchun
            minimumSize: Size(double.infinity, 52),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            spacing: 8,
            children: [
              AppTools.svg(AppTools.logout, colorFilter: ColorFilter.mode(Color(0xFF681219), BlendMode.srcIn)),
              Text(
                Words.exitProfile.tr(),
                style: GoogleFonts.manrope(fontSize: 15, fontWeight: FontWeight.w800, color: Color(0xFF681219)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
