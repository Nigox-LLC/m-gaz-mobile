import 'package:flutter/material.dart';

import '../../../../../../../core/common/words.dart';
import '../../../../../../../global_widget/app_tools.dart';
import '../widgets/create/eghu_action_form_fields.dart';

enum EghuRemovalFieldTrailing { none, close, chevron }

class EghuRemovalHeader extends StatelessWidget {
  const EghuRemovalHeader({super.key, required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 40,
      child: Row(
        children: [
          GestureDetector(
            key: const Key('eghu-removal-back'),
            onTap: () => Navigator.of(context).maybePop(),
            child: AppTools.svg(AppTools.icChervonLeft, width: 24, height: 24),
          ),
          Expanded(
            child: Text(
              title,
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: eghuText(
                fontSize: 17,
                lineHeight: 28,
                fontWeight: FontWeight.w800,
                color: EghuActionCreateColors.textStrong,
              ),
            ),
          ),
          AppTools.svg(AppTools.help, width: 24, height: 24),
        ],
      ),
    );
  }
}

class EghuRemovalField extends StatelessWidget {
  const EghuRemovalField({
    super.key,
    required this.label,
    this.value,
    this.placeholder = '-',
    this.trailing = EghuRemovalFieldTrailing.none,
    this.onTap,
  });

  final String label;
  final String? value;
  final String placeholder;
  final EghuRemovalFieldTrailing trailing;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final text = value?.trim();
    final hasText = text?.isNotEmpty == true;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: eghuText(
            fontSize: 11,
            lineHeight: 16,
            letterSpacing: 0.4,
            color: const Color(0xFF202020),
          ),
        ),
        const SizedBox(height: 4),
        Material(
          color: EghuActionCreateColors.field,
          borderRadius: BorderRadius.circular(12),
          child: InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: onTap,
            child: Container(
              height: 44,
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: EghuActionCreateColors.stroke),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      hasText ? text! : placeholder,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: eghuText(
                        fontSize: 13,
                        lineHeight: 20,
                        color: hasText
                            ? EghuActionCreateColors.text
                            : EghuActionCreateColors.textSub,
                      ),
                    ),
                  ),
                  switch (trailing) {
                    EghuRemovalFieldTrailing.close => AppTools.svg(
                      AppTools.x,
                      width: 18,
                      height: 18,
                    ),
                    EghuRemovalFieldTrailing.chevron => const Icon(
                      Icons.keyboard_arrow_down_rounded,
                      size: 20,
                      color: EghuActionCreateColors.text,
                    ),
                    EghuRemovalFieldTrailing.none => const SizedBox.shrink(),
                  },
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class EghuRemovalNextBar extends StatelessWidget {
  const EghuRemovalNextBar({
    super.key,
    required this.enabled,
    required this.onTap,
    this.label,
  });

  final bool enabled;
  final VoidCallback onTap;
  final String? label;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: EghuActionCreateColors.white,
      padding: EdgeInsets.fromLTRB(
        20,
        16,
        20,
        MediaQuery.paddingOf(context).bottom + 8,
      ),
      child: SizedBox(
        height: 56,
        width: double.infinity,
        child: ElevatedButton(
          key: const Key('eghu-removal-next-button'),
          onPressed: enabled ? onTap : null,
          style: ElevatedButton.styleFrom(
            elevation: 0,
            backgroundColor: const Color(0xFF3F57B3),
            disabledBackgroundColor: EghuActionCreateColors.soft,
            disabledForegroundColor: EghuActionCreateColors.textSub,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            textStyle: eghuText(
              fontSize: 17,
              lineHeight: 28,
              fontWeight: FontWeight.w800,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              AppTools.svg(
                AppTools.check,
                width: 20,
                height: 20,
                colorFilter: const ColorFilter.mode(
                  Colors.white,
                  BlendMode.srcIn,
                ),
              ),
              const SizedBox(width: 4),
              Text(label ?? Words.continueAction.tr()),
            ],
          ),
        ),
      ),
    );
  }
}

class EghuDashedAddButton extends StatelessWidget {
  const EghuDashedAddButton({
    super.key,
    required this.label,
    required this.onTap,
  });

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: CustomPaint(
        painter: _DashedBorderPainter(
          color: EghuActionCreateColors.stroke,
          radius: 12,
        ),
        child: SizedBox(
          height: 42,
          width: double.infinity,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.add_rounded, size: 16, color: Color(0xFF3F57B3)),
              const SizedBox(width: 6),
              Text(
                label,
                style: eghuText(
                  fontSize: 13,
                  lineHeight: 20,
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFF3F57B3),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DashedBorderPainter extends CustomPainter {
  const _DashedBorderPainter({required this.color, required this.radius});

  final Color color;
  final double radius;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;
    final path = Path()
      ..addRRect(
        RRect.fromRectAndRadius(Offset.zero & size, Radius.circular(radius)),
      );
    for (final metric in path.computeMetrics()) {
      var distance = 0.0;
      while (distance < metric.length) {
        final end = (distance + 4).clamp(0, metric.length).toDouble();
        canvas.drawPath(metric.extractPath(distance, end), paint);
        distance += 8;
      }
    }
  }

  @override
  bool shouldRepaint(covariant _DashedBorderPainter oldDelegate) =>
      oldDelegate.color != color || oldDelegate.radius != radius;
}
