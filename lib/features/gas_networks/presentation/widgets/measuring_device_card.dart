import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/common/words.dart';
import '../../../../global_widget/app_tools.dart';
import '../../domain/entities/measuring_device_document.dart';

/// List card for a single measuring-device document. Visual style mirrors the
/// redesigned GTS page (rounded `0xFFF0F0F0` panel, icon-led info rows, pill
/// chips).
class MeasuringDeviceCard extends StatelessWidget {
  const MeasuringDeviceCard({super.key, required this.document, this.onTap});

  final MeasuringDeviceDocument document;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final label = document.deviceLabel?.trim() ?? '';

    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(16),
      clipBehavior: Clip.antiAlias,
      child: InkWell(onTap: onTap, child: _content(label)),
    );
  }

  Widget _content(String label) {
    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: const Color(0xFFF0F0F0),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: 12,
          children: [
            Row(
              spacing: 12,
              children: [
                DecoratedBox(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    color: const Color(0xFFFCFCFC),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: AppTools.svg(AppTools.icBuilding),
                  ),
                ),
                Flexible(
                  child: Text(
                    document.region,
                    style: GoogleFonts.manrope(
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                      color: const Color(0xFF202020),
                    ),
                  ),
                ),
              ],
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: 8,
              children: [
                _InfoRow(
                  iconPath: AppTools.icBreifcase,
                  label: Words.attachedEmployee.tr(),
                  value: document.employee,
                ),
                _InfoRow(
                  iconPath: AppTools.icNavigation,
                  label: Words.district.tr(),
                  value: document.district,
                ),
                Wrap(
                  spacing: 12,
                  runSpacing: 8,
                  children: [
                    _Chip(text: 'ID: ${document.id}'),
                    if (document.gtsh.trim().isNotEmpty)
                      _Chip(text: '${Words.gtsh.tr()}: ${document.gtsh}'),
                    if (label.isNotEmpty) _Chip(text: label),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.iconPath,
    required this.label,
    required this.value,
  });

  final String iconPath;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 8,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 2),
          child: AppTools.svg(iconPath),
        ),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: 2,
            children: [
              Text(
                label,
                style: GoogleFonts.manrope(
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                  color: const Color(0xFFBBBBBB),
                ),
              ),
              Text(
                value,
                style: GoogleFonts.manrope(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
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

class _Chip extends StatelessWidget {
  const _Chip({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(21),
        color: const Color(0xFFFCFCFC),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        child: Text(
          text,
          style: GoogleFonts.manrope(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: const Color(0xFF202020),
          ),
        ),
      ),
    );
  }
}
