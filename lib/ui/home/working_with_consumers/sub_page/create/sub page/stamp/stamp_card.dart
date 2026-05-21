import 'package:flutter/material.dart';
import 'package:m_gaz/core/common/words.dart';
import '../../widget/egxu_item.dart';

class StampCardList extends StatelessWidget {
  final List<StampModel> stamps;

  const StampCardList({super.key, required this.stamps});

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      padding: const EdgeInsets.all(8),
      itemCount: stamps.length,
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 1.45,
      ),
      itemBuilder: (context, index) {
        final s = stamps[index];
        return Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 6,
                offset: const Offset(0, 3),
              ),
            ],
            border: Border.all(
              color: s.isActive ? Colors.green : Colors.red,
              width: 1,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              /// Tamga raqami
              Text(
                "${Words.stampNumber.tr()}: ${s.stampNumber}",
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 4),

              /// Tamga joyi
              Text(
                "${Words.location.tr()}: ${s.place}",
                style: const TextStyle(color: Colors.grey, fontSize: 12),
              ),
              const SizedBox(height: 4),

              /// Tamga holati
              Text(
                "${Words.status.tr()}: ${s.isActive ? Words.installed.tr() : Words.notInstalled.tr()}",
                style: TextStyle(
                  color: s.isActive ? Colors.green : Colors.red,
                  fontWeight: FontWeight.w600,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
