import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:m_gaz/core/common/words.dart';
import 'package:m_gaz/global_widget/app_tools.dart';

class EghuActionCreateColors {
  const EghuActionCreateColors._();

  static const white = Color(0xFFFCFCFC);
  static const field = Color(0xFFF9F9F9);
  static const soft = Color(0xFFF0F0F0);
  static const stroke = Color(0xFFE8E8E8);
  static const strokeStrong = Color(0xFFD0D5E2);
  static const textStrong = Color(0xFF1A1D2E);
  static const text = Color(0xFF202020);
  static const textSub = Color(0xFFBBBBBB);
  static const primary = Color(0xFF526ED3);
}

TextStyle eghuText({
  required double fontSize,
  required double lineHeight,
  FontWeight fontWeight = FontWeight.w500,
  Color color = EghuActionCreateColors.text,
  double letterSpacing = 0,
}) {
  return GoogleFonts.manrope(
    fontSize: fontSize,
    height: lineHeight / fontSize,
    fontWeight: fontWeight,
    color: color,
    letterSpacing: letterSpacing,
  );
}

class EghuSelectorField extends StatelessWidget {
  const EghuSelectorField({
    super.key,
    required this.label,
    required this.value,
    required this.onTap,
    this.placeholder = false,
  });

  final String label;
  final String value;
  final VoidCallback onTap;
  final bool placeholder;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SmallLabel(label),
        const SizedBox(height: 4),
        Material(
          color: EghuActionCreateColors.field,
          borderRadius: BorderRadius.circular(12),
          child: InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: onTap,
            child: Container(
              height: 44,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: EghuActionCreateColors.stroke),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      value,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: eghuText(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        lineHeight: 20,
                        color: placeholder
                            ? EghuActionCreateColors.textSub
                            : EghuActionCreateColors.text,
                      ),
                    ),
                  ),
                  const Icon(
                    Icons.keyboard_arrow_down_rounded,
                    size: 20,
                    color: EghuActionCreateColors.text,
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class EghuStampSection extends StatelessWidget {
  const EghuStampSection({
    super.key,
    required this.controller,
    required this.onNumberChanged,
    required this.onPickDate,
    this.employeeName,
    this.selectedDate,
  });

  final TextEditingController controller;
  final ValueChanged<String> onNumberChanged;
  final VoidCallback onPickDate;
  final String? employeeName;
  final DateTime? selectedDate;

  @override
  Widget build(BuildContext context) {
    final displayDate = DateFormat(
      'dd.MM.yyyy HH:mm',
    ).format(selectedDate ?? DateTime.now());
    final displayEmployee = employeeName?.trim();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        EghuSectionHeader(title: Words.stampAdd.tr(), onAdd: () {}),
        const SizedBox(height: 4),
        SizedBox(
          height: 44,
          child: TextField(
            key: const Key('eghu-stamp-number-field'),
            controller: controller,
            onChanged: onNumberChanged,
            keyboardType: TextInputType.number,
            style: eghuText(fontSize: 13, lineHeight: 20),
            decoration: InputDecoration(
              hintText: Words.stampNumberHint.tr(),
              hintStyle: eghuText(
                fontSize: 13,
                lineHeight: 20,
                color: EghuActionCreateColors.textSub,
              ),
              filled: true,
              fillColor: EghuActionCreateColors.field,
              contentPadding: const EdgeInsets.symmetric(horizontal: 16),
              border: _border(),
              enabledBorder: _border(),
              focusedBorder: _border(EghuActionCreateColors.primary),
            ),
          ),
        ),
        const SizedBox(height: 4),
        Container(
          padding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
          decoration: BoxDecoration(
            color: EghuActionCreateColors.field,
            borderRadius: BorderRadius.circular(12),
          ),
          alignment: Alignment.center,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              AppTools.svg(AppTools.icUserCheck),
              const SizedBox(width: 8),
              Flexible(
                child: Text(
                  displayEmployee?.isNotEmpty == true
                      ? displayEmployee!
                      : Words.fallbackUser.tr(),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: eghuText(
                    fontSize: 13,
                    lineHeight: 20,
                    color: const Color(0xA61B1F3B),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 4),
        Material(
          color: EghuActionCreateColors.field,
          borderRadius: BorderRadius.circular(12),
          child: InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: onPickDate,
            child: Container(
              key: const Key('eghu-stamp-date-field'),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: EghuActionCreateColors.stroke),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Flexible(
                    child: Text(
                      displayDate,
                      style: eghuText(fontSize: 13, lineHeight: 20),
                    ),
                  ),
                  AppTools.svg(AppTools.icCalendar),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  OutlineInputBorder _border([Color color = EghuActionCreateColors.stroke]) {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(color: color),
    );
  }
}

class EghuSectionHeader extends StatelessWidget {
  const EghuSectionHeader({
    super.key,
    required this.title,
    required this.onAdd,
    this.showHelp = false,
    this.onHelp,
    this.helpKey,
  });

  final String title;
  final VoidCallback onAdd;
  final bool showHelp;
  final VoidCallback? onHelp;
  final Key? helpKey;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Flexible(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Flexible(child: _SmallLabel(title)),
              if (showHelp) ...[
                const SizedBox(width: 8),
                InkWell(
                  key: helpKey,
                  borderRadius: BorderRadius.circular(8),
                  onTap: onHelp,
                  child: const Icon(Icons.help_outline_rounded, size: 16),
                ),
              ],
            ],
          ),
        ),
        _AddChip(onTap: onAdd),
      ],
    );
  }
}

class EghuSubmitBar extends StatelessWidget {
  const EghuSubmitBar({
    super.key,
    required this.enabled,
    required this.loading,
    required this.onTap,
    this.label,
  });

  final bool enabled;
  final bool loading;
  final VoidCallback onTap;
  final String? label;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: EdgeInsets.fromLTRB(
        20,
        16,
        20,
        MediaQuery.paddingOf(context).bottom + 8,
      ),
      child: SizedBox(
        height: 56,
        width: double.infinity,
        child: ElevatedButton.icon(
          key: const Key('eghu-submit-button'),
          onPressed: enabled && !loading ? onTap : null,
          icon: loading
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Icon(Icons.check_rounded),
          label: Text(
            loading ? Words.submitting.tr() : (label ?? Words.finish.tr()),
          ),
          style: ElevatedButton.styleFrom(
            elevation: 0,
            backgroundColor: enabled
                ? EghuActionCreateColors.primary
                : const Color(0xFFF4F4F4),
            disabledBackgroundColor: const Color(0xFFF4F4F4),
            disabledForegroundColor: EghuActionCreateColors.textSub,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            textStyle: eghuText(
              fontSize: 17,
              lineHeight: 28,
              fontWeight: FontWeight.w800,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }
}

class _SmallLabel extends StatelessWidget {
  const _SmallLabel(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: eghuText(fontSize: 11, lineHeight: 16, letterSpacing: 0.4),
    );
  }
}

class _AddChip extends StatelessWidget {
  const _AddChip({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: EghuActionCreateColors.soft,
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.add_rounded, size: 14),
              const SizedBox(width: 4),
              Text(
                Words.add.tr(),
                style: eghuText(fontSize: 13, lineHeight: 20),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
