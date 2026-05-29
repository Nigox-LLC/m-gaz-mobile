import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:m_gaz/global_widget/app_tools.dart';

class EghuActionHeader extends StatelessWidget {
  const EghuActionHeader({
    super.key,
    required this.title,
    this.onBack,
    this.onAdd,
  });

  final String title;
  final VoidCallback? onBack;
  final VoidCallback? onAdd;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          height: 40,
          child: Row(
            children: [
              _BackButton(onTap: onBack ?? () => Navigator.maybePop(context)),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.manrope(
                    fontSize: 17,
                    height: 28 / 17,
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFF1A1D2E),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              _AddActionButton(onTap: onAdd),
            ],
          ),
        ),
        const SizedBox(height: 4),
        const EghuSearchFilterBar(),
      ],
    );
  }
}

class _BackButton extends StatelessWidget {
  const _BackButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 24,
      height: 36,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: onTap,
          child: const Icon(
            Icons.chevron_left_rounded,
            size: 28,
            color: Color(0xFF141B34),
          ),
        ),
      ),
    );
  }
}

class _AddActionButton extends StatelessWidget {
  const _AddActionButton({this.onTap});

  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 36,
      child: Material(
        color: const Color(0xFF3F57B3),
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                AppTools.svg(AppTools.icFileText, width: 20, height: 20),
                const SizedBox(width: 8),
                Text(
                  "Qo'shish",
                  style: GoogleFonts.manrope(
                    fontSize: 13,
                    height: 20 / 13,
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFFFCFCFC),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class EghuSearchFilterBar extends StatelessWidget {
  const EghuSearchFilterBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Container(
            height: 44,
            padding: const EdgeInsets.only(left: 12, right: 8),
            decoration: BoxDecoration(
              color: const Color(0xFFF9F9F9),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFE8E8E8)),
            ),
            child: Row(
              children: [
                AppTools.svg(AppTools.icSearchIcon, width: 24, height: 24),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Qidirish',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.manrope(
                      fontSize: 13,
                      height: 20 / 13,
                      fontWeight: FontWeight.w500,
                      color: const Color(0xFFBBBBBB),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 12),
        Container(
          width: 44,
          height: 44,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: const Color(0xFFF9F9F9),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFE8E8E8)),
          ),
          child: AppTools.svg(AppTools.icFilterIcon, width: 16, height: 16),
        ),
      ],
    );
  }
}
