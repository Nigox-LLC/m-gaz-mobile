import 'dart:io';
import 'package:flutter/material.dart';
import 'package:m_gaz/core/utils/colors.dart';
import '../egxu_item.dart';

class EgxuSliderCard extends StatefulWidget {
  final List<EgxuItem> items;

  const EgxuSliderCard({super.key, required this.items});

  @override
  State<EgxuSliderCard> createState() => _EgxuSliderCardState();
}

class _EgxuSliderCardState extends State<EgxuSliderCard> {
  final PageController _controller = PageController();
  int currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    final current = widget.items[currentIndex];

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppColors.blue),
        boxShadow: [
          BoxShadow(
            color: AppColors.black.withValues(alpha: 0.06),
            blurRadius: 10,
          ),
        ],
      ),
      child: Column(
        children: [
          /// IMAGE + ARROWS
          Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                height: 160,
                child: PageView.builder(
                  controller: _controller,
                  itemCount: widget.items.length,
                  onPageChanged: (i) {
                    setState(() => currentIndex = i);
                  },
                  itemBuilder: (_, i) =>
                      Center(child: _egxuImageLarge(widget.items[i].imagePath)),
                ),
              ),

              /// LEFT
              _arrow(
                Icons.chevron_left,
                Alignment.centerLeft,
                () => _controller.previousPage(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeOut,
                ),
              ),

              /// RIGHT
              _arrow(
                Icons.chevron_right,
                Alignment.centerRight,
                () => _controller.nextPage(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeOut,
                ),
              ),
            ],
          ),

          const SizedBox(height: 10),

          /// TYPE
          Text(
            current.type,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
          ),

          const SizedBox(height: 8),

          /// FACTORY NUMBERS
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _factoryChip("1-Zavod №", current.factory1),
              const SizedBox(width: 12),
              _factoryChip("2-Zavod №", current.factory2),
            ],
          ),

          const SizedBox(height: 10),

          /// DATE
          Text(
            "${current.dateFrom} → ${current.dateTo}",
            style: TextStyle(fontSize: 13, color: AppColors.grey),
          ),

          const SizedBox(height: 10),

          /// INDICATOR
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(
              widget.items.length,
              (i) => Container(
                width: i == currentIndex ? 18 : 6,
                height: 6,
                margin: const EdgeInsets.symmetric(horizontal: 3),
                decoration: BoxDecoration(
                  color: i == currentIndex
                      ? AppColors.blue
                      : AppColors.blue.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _arrow(IconData icon, Alignment alignment, VoidCallback onTap) {
    return Align(
      alignment: alignment,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 6),
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: AppColors.blue,
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: AppColors.white),
        ),
      ),
    );
  }

  Widget _factoryChip(String title, String value) {
    return Column(
      children: [
        Text(
          title,
          style: const TextStyle(fontSize: 12, color: AppColors.grey),
        ),
        const SizedBox(height: 4),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: AppColors.blue.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text(
            value,
            style: const TextStyle(
              color: AppColors.blue,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  Widget _egxuImageLarge(String? path) {
    const size = 110.0;

    if (path == null || path.isEmpty) {
      return Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: Colors.grey.shade200,
          borderRadius: BorderRadius.circular(14),
        ),
        child: const Icon(
          Icons.image_not_supported,
          size: 36,
          color: Colors.grey,
        ),
      );
    }

    return Container(
      width: size,
      height: size,
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(14),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: path.startsWith('https')
            ? Image.network(
                path,
                fit: BoxFit.contain, // 🔥 MUHIM
              )
            : Image.file(
                File(path),
                fit: BoxFit.contain, // 🔥 MUHIM
              ),
      ),
    );
  }
}
