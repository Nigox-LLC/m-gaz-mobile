import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../../../../global_widget/app_tools.dart';

class EghuActionCardData {
  const EghuActionCardData({
    required this.personalAccount,
    required this.factoryNumber,
    required this.region,
    required this.district,
    required this.date,
    required this.employee,
    this.personalAccountLabel = 'Shaxsiy hisob:',
    this.factoryNumberLabel = 'Zavod raqami:',
  });

  final String personalAccount;
  final String factoryNumber;
  final String region;
  final String district;
  final String date;
  final String employee;
  final String personalAccountLabel;
  final String factoryNumberLabel;
}

class EghuActionCard extends StatelessWidget {
  const EghuActionCard({super.key, required this.data, this.onTap});

  final EghuActionCardData data;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: const Color(0xFFF0F0F0),
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const _SpeedBadge(),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _InlineInfo(
                          label: data.personalAccountLabel,
                          value: data.personalAccount,
                        ),
                        const SizedBox(height: 2),
                        _InlineInfo(
                          label: data.factoryNumberLabel,
                          value: data.factoryNumber,
                          valueBold: false,
                          labelColor: const Color(0xA61B1F3B),
                          valueColor: const Color(0xA61B1F3B),
                          fontSize: 13,
                          lineHeight: 20,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              _CardDetailRow(
                icon: AppTools.svg(AppTools.icMapPin, width: 16, height: 16),
                label: 'Viloyat',
                value: data.region,
              ),
              const SizedBox(height: 4),
              _CardDetailRow(
                icon: AppTools.svg(
                  AppTools.icNavigation,
                  width: 16,
                  height: 16,
                ),
                label: 'Tuman',
                value: data.district,
              ),
              const SizedBox(height: 4),
              _CardDetailRow(
                icon: AppTools.svg(AppTools.icCalendar, width: 16, height: 16),
                label: 'Sanasi',
                value: data.date,
                valueBold: true,
              ),
              const SizedBox(height: 4),
              _CardDetailRow(
                icon: AppTools.svg(AppTools.icBreifcase, width: 16, height: 16),
                label: 'Xodim',
                value: data.employee,
                valueBold: true,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SpeedBadge extends StatelessWidget {
  const _SpeedBadge();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        color: const Color(0xFFFCFCFC),
        borderRadius: BorderRadius.circular(12),
      ),
      alignment: Alignment.center,
      child: const Icon(
        Icons.speed_rounded,
        size: 28,
        color: Color(0xFF335CFF),
      ),
    );
  }
}

class _InlineInfo extends StatelessWidget {
  const _InlineInfo({
    required this.label,
    required this.value,
    this.valueBold = true,
    this.labelColor = const Color(0xFF202020),
    this.valueColor = const Color(0xFF202020),
    this.fontSize = 15,
    this.lineHeight = 24,
  });

  final String label;
  final String value;
  final bool valueBold;
  final Color labelColor;
  final Color valueColor;
  final double fontSize;
  final double lineHeight;

  @override
  Widget build(BuildContext context) {
    return RichText(
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      text: TextSpan(
        children: [
          TextSpan(
            text: '$label  ',
            style: GoogleFonts.manrope(
              fontSize: fontSize,
              height: lineHeight / fontSize,
              fontWeight: FontWeight.w500,
              color: labelColor,
            ),
          ),
          TextSpan(
            text: value,
            style: GoogleFonts.manrope(
              fontSize: fontSize,
              height: lineHeight / fontSize,
              fontWeight: valueBold ? FontWeight.w800 : FontWeight.w500,
              color: valueColor,
            ),
          ),
        ],
      ),
    );
  }
}

class _CardDetailRow extends StatelessWidget {
  const _CardDetailRow({
    required this.icon,
    required this.label,
    required this.value,
    this.valueBold = false,
  });

  final Widget icon;
  final String label;
  final String value;
  final bool valueBold;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Icon(icon, size: 16, color: const Color(0xFFBBBBBB)),
        icon,
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.manrope(
                  fontSize: 11,
                  height: 16 / 11,
                  letterSpacing: 0.4,
                  fontWeight: FontWeight.w500,
                  color: const Color(0xFFBBBBBB),
                ),
              ),
              Text(
                value,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.manrope(
                  fontSize: 13,
                  height: 20 / 13,
                  fontWeight: valueBold ? FontWeight.w700 : FontWeight.w500,
                  color: const Color(0xFF202020),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
