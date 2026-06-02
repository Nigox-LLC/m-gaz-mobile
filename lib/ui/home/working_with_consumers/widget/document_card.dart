import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:m_gaz/core/common/words.dart';
import 'package:m_gaz/core/models/working_with_consumers_document/working_with_consumers_list.dart';

class DocumentCardData {
  const DocumentCardData({
    required this.id,
    required this.region,
    required this.district,
    required this.consumerName,
    required this.accountNumber,
  });

  factory DocumentCardData.fromConsumer(WorkingWithConsumersList document) {
    return DocumentCardData(
      id: document.id,
      region: document.region,
      district: document.district,
      consumerName: document.consumers,
      accountNumber: document.facial,
    );
  }

  final int id;
  final String region;
  final String district;
  final String consumerName;
  final String accountNumber;
}

class DocumentCard extends StatelessWidget {
  const DocumentCard({
    super.key,
    required this.document,
    required this.index,
    this.onTap,
  });

  final DocumentCardData document;
  final int index;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final location = [
      document.region,
      document.district,
    ].where((value) => value.trim().isNotEmpty).join(', ');

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Material(
        color: const Color(0xFFF0F0F0),
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: const Color(0xFFC0D5FF),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.apartment_rounded,
                        color: Color(0xFF2864FF),
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(child: _buildConsumerTitle(document.consumerName)),
                  ],
                ),
                const SizedBox(height: 12),
                _buildDetailRow(
                  icon: Icons.person_outline_rounded,
                  label: Words.status.tr(),
                  value: Words.stampNotInstalled.tr(),
                  emphasizeValue: true,
                ),
                const SizedBox(height: 8),
                _buildDetailRow(
                  icon: Icons.map_outlined,
                  label: Words.area.tr(),
                  value: location.isEmpty ? '-' : location,
                ),
                const SizedBox(height: 10),
                LayoutBuilder(
                  builder: (context, constraints) {
                    final maxChipWidth = constraints.maxWidth;
                    return Wrap(
                      spacing: 12,
                      runSpacing: 8,
                      children: [
                        _InfoChip(
                          text: 'ID: ${document.id}',
                          maxWidth: maxChipWidth,
                        ),
                        _InfoChip(
                          text:
                              '${Words.accountNumber.tr()}: ${document.accountNumber}',
                          maxWidth: maxChipWidth,
                        ),
                      ],
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildConsumerTitle(String value) {
    final trimmed = value.trim();
    final parts = trimmed.split(RegExp(r'\s+'));
    final first = parts.isNotEmpty ? parts.first : '';
    final rest = parts.length > 1
        ? trimmed.substring(first.length).trimLeft()
        : '';

    return RichText(
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
      text: TextSpan(
        style: GoogleFonts.manrope(
          color: const Color(0xFF202020),
          fontSize: 15,
          height: 24 / 15,
          fontWeight: FontWeight.w500,
        ),
        children: [
          TextSpan(
            text: first,
            style: GoogleFonts.manrope(
              color: const Color(0xFF202020),
              fontSize: 15,
              height: 24 / 15,
              fontWeight: FontWeight.w800,
            ),
          ),
          if (rest.isNotEmpty) TextSpan(text: ' $rest'),
        ],
      ),
    );
  }

  Widget _buildDetailRow({
    required IconData icon,
    required String label,
    required String value,
    bool emphasizeValue = false,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 2),
          child: Icon(icon, size: 16, color: const Color(0xFFBBBBBB)),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: GoogleFonts.manrope(
                  color: const Color(0xFFBBBBBB),
                  fontSize: 11,
                  height: 16 / 11,
                  letterSpacing: 0.4,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.manrope(
                  color: const Color(0xFF202020),
                  fontSize: 13,
                  height: 20 / 13,
                  fontWeight: emphasizeValue
                      ? FontWeight.w700
                      : FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _InfoChip extends StatelessWidget {
  const _InfoChip({required this.text, required this.maxWidth});

  final String text;
  final double maxWidth;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(maxWidth: maxWidth),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
      decoration: BoxDecoration(
        color: const Color(0xFFE8E8E8),
        borderRadius: BorderRadius.circular(21),
      ),
      child: Text(
        text,
        softWrap: true,
        style: GoogleFonts.manrope(
          color: const Color(0xFF202020),
          fontSize: 13,
          height: 20 / 13,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}
