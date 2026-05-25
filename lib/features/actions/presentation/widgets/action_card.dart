import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:m_gaz/core/common/words.dart';
import 'package:m_gaz/features/actions/domain/entities/action_menu_item.dart';
import 'package:m_gaz/global_widget/app_tools.dart';

class ActionCard extends StatelessWidget {
  const ActionCard({super.key, required this.item, required this.onTap});

  static const double compactHeight = 118;
  static const double wideHeight = 94;

  final ActionMenuItem item;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final minHeight = item.isWide ? wideHeight : compactHeight;

    return Semantics(
      button: true,
      label: item.title.tr(),
      child: Material(
        color: const Color(0xFFF0F0F0),
        borderRadius: BorderRadius.circular(16),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: minHeight),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(14, 14, 14, 16),
              child: SizedBox(
                width: MediaQuery.sizeOf(context).width,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _ActionIcon(path: item.iconPath),
                    const SizedBox(height: 8),
                    Text(
                      item.title.tr(),
                      maxLines: item.isWide ? 2 : 4,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.manrope(
                        color: Colors.black,
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        height: 24 / 15,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ActionIcon extends StatelessWidget {
  const _ActionIcon({required this.path});

  final String path;

  @override
  Widget build(BuildContext context) {
    final iconSize = path == AppTools.icDashboardSpeed01 ? 28.0 : 20.0;

    return Container(
      width: 32,
      height: 32,
      decoration: const BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
      ),
      alignment: Alignment.center,
      child: AppTools.svg(path, width: iconSize, height: iconSize),
    );
  }
}
