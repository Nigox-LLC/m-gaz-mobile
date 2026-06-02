import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:m_gaz/core/common/words.dart';
import 'package:m_gaz/features/actions/data/models/eghu_action_stamp_entry.dart';
import 'package:m_gaz/global_widget/app_tools.dart';

import '../eghu_calendar_dialog.dart';

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

class EghuStampSection extends StatefulWidget {
  const EghuStampSection({
    super.key,
    required this.stamps,
    required this.onAdd,
    required this.onNumberChanged,
    required this.onDateChanged,
    required this.onRemoveUnsaved,
    this.employeeName,
  });

  final List<EghuActionStampEntry> stamps;
  final VoidCallback onAdd;
  final void Function(String localId, String value) onNumberChanged;
  final void Function(String localId, DateTime value) onDateChanged;
  final ValueChanged<String> onRemoveUnsaved;
  final String? employeeName;

  @override
  State<EghuStampSection> createState() => _EghuStampSectionState();
}

class _EghuStampSectionState extends State<EghuStampSection> {
  final Map<String, TextEditingController> _controllers = {};

  @override
  void didUpdateWidget(covariant EghuStampSection oldWidget) {
    super.didUpdateWidget(oldWidget);
    _syncControllers();
  }

  @override
  void initState() {
    super.initState();
    _syncControllers();
  }

  @override
  void dispose() {
    for (final controller in _controllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  void _syncControllers() {
    final ids = widget.stamps.map((stamp) => stamp.localId).toSet();
    final removed = _controllers.keys.where((id) => !ids.contains(id)).toList();
    for (final id in removed) {
      _controllers.remove(id)?.dispose();
    }

    for (final stamp in widget.stamps) {
      final controller = _controllers.putIfAbsent(
        stamp.localId,
        () => TextEditingController(),
      );
      if (controller.text != stamp.number) {
        controller.value = TextEditingValue(
          text: stamp.number,
          selection: TextSelection.collapsed(offset: stamp.number.length),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        EghuSectionHeader(title: Words.stampAdd.tr(), onAdd: widget.onAdd),
        const SizedBox(height: 4),
        ...widget.stamps.map(
          (stamp) => Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: _StampListItem(
              stamp: stamp,
              controller: _controllers[stamp.localId]!,
              employeeName: stamp.employeeName ?? widget.employeeName,
              onChanged: (value) =>
                  widget.onNumberChanged(stamp.localId, value),
              onDateChanged: (value) =>
                  widget.onDateChanged(stamp.localId, value),
              onRemove: stamp.isNew
                  ? () => widget.onRemoveUnsaved(stamp.localId)
                  : null,
            ),
          ),
        ),
      ],
    );
  }
}

class _StampListItem extends StatelessWidget {
  const _StampListItem({
    required this.stamp,
    required this.controller,
    required this.employeeName,
    required this.onChanged,
    required this.onDateChanged,
    this.onRemove,
  });

  final EghuActionStampEntry stamp;
  final TextEditingController controller;
  final String? employeeName;
  final ValueChanged<String> onChanged;
  final ValueChanged<DateTime> onDateChanged;
  final VoidCallback? onRemove;

  @override
  Widget build(BuildContext context) {
    final displayDate = DateFormat(
      'dd.MM.yyyy HH:mm',
    ).format(stamp.installedAt);
    final displayEmployee = employeeName?.trim();

    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: EghuActionCreateColors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: EghuActionCreateColors.stroke),
      ),
      child: Column(
        children: [
          SizedBox(
            height: 44,
            child: TextField(
              key: Key('eghu-stamp-number-field-${stamp.localId}'),
              controller: controller,
              onChanged: onChanged,
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
                suffixIcon: onRemove == null
                    ? null
                    : IconButton(
                        key: Key('eghu-stamp-remove-${stamp.localId}'),
                        onPressed: onRemove,
                        icon: const Icon(Icons.close_rounded, size: 18),
                      ),
                border: _border(),
                enabledBorder: _border(),
                focusedBorder: _border(EghuActionCreateColors.primary),
              ),
            ),
          ),
          const SizedBox(height: 4),
          Container(
            height: 44,
            padding: const EdgeInsets.symmetric(horizontal: 16),
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
            key: Key('eghu-stamp-date-field-${stamp.localId}'),
            color: EghuActionCreateColors.field,
            borderRadius: BorderRadius.circular(12),
            child: InkWell(
              borderRadius: BorderRadius.circular(12),
              onTap: () async {
                final value = await pickEghuStampDateTime(
                  context,
                  currentStampDateTime: stamp.installedAt,
                );
                if (value != null) onDateChanged(value);
              },
              child: Container(
                height: 44,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: EghuActionCreateColors.stroke),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        displayDate,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
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
      ),
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
