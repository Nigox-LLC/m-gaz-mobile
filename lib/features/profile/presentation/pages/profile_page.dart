import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:m_gaz/app/injection.dart';
import 'package:m_gaz/core/common/words.dart';
import 'package:m_gaz/core/extension/size_extension.dart';
import 'package:m_gaz/features/profile/presentation/bloc/profile_bloc.dart';
import 'package:m_gaz/features/profile/presentation/pages/personal_data_page.dart';
import 'package:m_gaz/features/profile/presentation/pages/security_page.dart';
import 'package:m_gaz/features/profile/presentation/pages/settings_page.dart';
import 'package:m_gaz/features/profile/presentation/widgets/custom_container_widget.dart';
import 'package:m_gaz/features/profile/presentation/widgets/custom_list_tile.dart';
import 'package:m_gaz/global_widget/app_tools.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<ProfileBloc>()..add(GetProfileDataEvent()),
      child: const _ProfileView(),
    );
  }
}

class _ProfileView extends StatelessWidget {
  const _ProfileView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFCFCFC),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF0F0F0),
        elevation: 0,
        centerTitle: false,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: AppTools.svg(AppTools.icChervonLeft, width: 24, height: 24),
        ),
      ),
      body: Column(
        children: [
          BlocBuilder<ProfileBloc, ProfileState>(
            buildWhen: (p, c) =>
                p.profileData != c.profileData ||
                p.profileLoadStatus != c.profileLoadStatus,
            builder: (context, state) => _ProfileHeader(state: state),
          ),
          SizedBox(height: 24.h),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: CustomContainerWidget(
              child: Column(
                spacing: 20,
                children: [
                  CustomListTile(
                    leadingIcon: AppTools.svg(
                      AppTools.icUser,
                      colorFilter: const ColorFilter.mode(Color(0xFF202020), BlendMode.srcIn),
                      width: 20,
                      height: 20,
                    ),
                    title: Words.personalInfo.tr(),
                    onTap: () => _openWithBloc(context, const PersonalDataPage()),
                    trailingIcon: AppTools.svg(AppTools.icChervonRight),
                  ),
                  CustomListTile(
                    leadingIcon: AppTools.svg(AppTools.icFile),
                    title: Words.reports.tr(),
                    onTap: () {},
                    trailingIcon: AppTools.svg(AppTools.icChervonRight),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(height: 12.h),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: CustomContainerWidget(
              child: Column(
                spacing: 20,
                children: [
                  CustomListTile(
                    leadingIcon: AppTools.svg(AppTools.icShield),
                    title: Words.security.tr(),
                    onTap: () {
                      Navigator.push(context, CupertinoPageRoute(builder: (_) => const SecurityPage()));
                    },
                    trailingIcon: AppTools.svg(AppTools.icChervonRight),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(height: 12.h),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: CustomContainerWidget(
              child: Column(
                spacing: 20,
                children: [
                  CustomListTile(
                    leadingIcon: AppTools.svg(AppTools.icSettings),
                    title: Words.settings.tr(),
                    onTap: () {
                      Navigator.push(context, CupertinoPageRoute(builder: (_) => const SettingsPage()));
                    },
                    trailingIcon: AppTools.svg(AppTools.icChervonRight),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Pushes [page] while keeping the existing [ProfileBloc] instance available
  /// so the destination screen reads the same already-loaded profile data.
  void _openWithBloc(BuildContext context, Widget page) {
    final bloc = context.read<ProfileBloc>();
    Navigator.push(
      context,
      CupertinoPageRoute(
        builder: (_) => BlocProvider.value(value: bloc, child: page),
      ),
    );
  }
}

class _ProfileHeader extends StatelessWidget {
  const _ProfileHeader({required this.state});

  final ProfileState state;

  @override
  Widget build(BuildContext context) {
    final profile = state.profileData;
    final isLoading = state.profileLoadStatus.isLoading && profile == null;

    final name = (profile?.employeeFio?.trim().isNotEmpty ?? false)
        ? profile!.employeeFio!.trim()
        : (profile?.username ?? '');
    final role = (profile?.role.trim().isNotEmpty ?? false)
        ? profile!.role.trim()
        : Words.employee.tr();

    return Container(
      width: MediaQuery.of(context).size.width,
      padding: const EdgeInsets.symmetric(vertical: 15),
      decoration: const BoxDecoration(
        borderRadius: BorderRadius.only(bottomLeft: Radius.circular(28), bottomRight: Radius.circular(28)),
        color: Color(0xFFF0F0F0),
      ),
      child: Column(
        children: [
          _ProfileAvatar(photoUrl: profile?.photoUrl),
          SizedBox(height: 8.h),
          if (isLoading)
            const SizedBox(height: 21, width: 21, child: CircularProgressIndicator(strokeWidth: 2))
          else
            Text(name, style: GoogleFonts.manrope(fontSize: 17, fontWeight: FontWeight.w800)),
          SizedBox(height: 8.h),
          Text(role, style: GoogleFonts.manrope(fontSize: 13, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }
}

class _ProfileAvatar extends StatelessWidget {
  const _ProfileAvatar({this.photoUrl});

  final String? photoUrl;

  @override
  Widget build(BuildContext context) {
    final hasPhoto = photoUrl != null && photoUrl!.trim().isNotEmpty;

    return ClipRRect(
      borderRadius: BorderRadius.circular(25),
      child: hasPhoto
          ? CachedNetworkImage(
              imageUrl: photoUrl!,
              height: 80.h,
              width: 80.w,
              fit: BoxFit.cover,
              placeholder: (_, __) => const Center(child: CircularProgressIndicator()),
              errorWidget: (_, __, ___) => _placeholder(),
            )
          : _placeholder(),
    );
  }

  Widget _placeholder() => SizedBox(
        height: 80.h,
        width: 80.w,
        child: const ColoredBox(
          color: Color(0xFFE8E8E8),
          child: Icon(Icons.person, color: Color(0xFF8A8A8A), size: 40),
        ),
      );
}
