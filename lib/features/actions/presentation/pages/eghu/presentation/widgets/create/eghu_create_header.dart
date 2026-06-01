import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'eghu_action_form_fields.dart';

class EghuCreateHeader extends StatefulWidget {
  const EghuCreateHeader({
    super.key,
    required this.title,
    required this.helpText,
    required this.helpButtonKey,
    required this.helpTooltipKey,
  });

  final String title;
  final String helpText;
  final Key helpButtonKey;
  final Key helpTooltipKey;

  @override
  State<EghuCreateHeader> createState() => _EghuCreateHeaderState();
}

class _EghuCreateHeaderState extends State<EghuCreateHeader> {
  final LayerLink _helpLink = LayerLink();
  OverlayEntry? _tooltipEntry;

  @override
  void dispose() {
    _hideTooltip();
    super.dispose();
  }

  void _toggleTooltip() {
    if (_tooltipEntry != null) {
      _hideTooltip();
      return;
    }

    _tooltipEntry = OverlayEntry(
      builder: (context) => Positioned.fill(
        child: IgnorePointer(
          child: CompositedTransformFollower(
            link: _helpLink,
            showWhenUnlinked: false,
            offset: const Offset(-250, 32),
            child: Align(
              alignment: Alignment.topLeft,
              widthFactor: 1,
              heightFactor: 1,
              child: _EghuCreateHeaderHelpTooltip(
                tooltipKey: widget.helpTooltipKey,
                text: widget.helpText,
              ),
            ),
          ),
        ),
      ),
    );

    Overlay.of(context).insert(_tooltipEntry!);
  }

  void _hideTooltip() {
    _tooltipEntry?.remove();
    _tooltipEntry = null;
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 40,
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.of(context).maybePop(),
            icon: const Icon(Icons.chevron_left_rounded),
            color: EghuActionCreateColors.textStrong,
            iconSize: 28,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints.tightFor(width: 32, height: 40),
          ),
          Expanded(
            child: Text(
              widget.title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: GoogleFonts.manrope(
                fontSize: 17,
                height: 28 / 17,
                fontWeight: FontWeight.w800,
                color: EghuActionCreateColors.textStrong,
              ),
            ),
          ),
          CompositedTransformTarget(
            link: _helpLink,
            child: IconButton(
              key: widget.helpButtonKey,
              onPressed: _toggleTooltip,
              icon: const Icon(Icons.help_outline_rounded),
              color: EghuActionCreateColors.textStrong,
              iconSize: 24,
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints.tightFor(width: 32, height: 40),
            ),
          ),
        ],
      ),
    );
  }
}

class _EghuCreateHeaderHelpTooltip extends StatelessWidget {
  const _EghuCreateHeaderHelpTooltip({
    required this.tooltipKey,
    required this.text,
  });

  final Key tooltipKey;
  final String text;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      key: tooltipKey,
      width: 275,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            margin: const EdgeInsets.only(top: 8),
            padding: const EdgeInsets.fromLTRB(12, 9, 13, 9),
            decoration: BoxDecoration(
              color: const Color(0xFFF9F9F9),
              borderRadius: BorderRadius.circular(16),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x0D000000),
                  blurRadius: 1.5,
                  offset: Offset(0, 1),
                ),
                BoxShadow(
                  color: Color(0x1F000000),
                  blurRadius: 15,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: Material(
              type: MaterialType.transparency,
              child: Text(
                text,
                textAlign: TextAlign.center,
                style: GoogleFonts.manrope(
                  fontSize: 11,
                  height: 16 / 11,
                  fontWeight: FontWeight.w500,
                  letterSpacing: 0.4,
                  color: EghuActionCreateColors.textStrong,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
