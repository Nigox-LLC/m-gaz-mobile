import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/common/words.dart';

class FilterResult {
  final String? type;
  final bool cleared;

  const FilterResult({this.type, this.cleared = false});

  factory FilterResult.clear() => const FilterResult(cleared: true);
}

enum TaskFilterType {
  pending('not-done-list'),
  done('done-list'),
  expired('canceled-list');

  const TaskFilterType(this.value);

  final String value;

  String get val => value;

  String label() => switch (this) {
    TaskFilterType.pending => Words.pending.tr(),
    TaskFilterType.done => Words.completed.tr(),
    TaskFilterType.expired => Words.expiredTasks.tr(),
  };
}

class TaskFilterBottomSheet extends StatefulWidget {
  final String? initialType;

  const TaskFilterBottomSheet({super.key, this.initialType});

  @override
  State<TaskFilterBottomSheet> createState() => _TaskFilterBottomSheetState();
}

class _TaskFilterBottomSheetState extends State<TaskFilterBottomSheet> {
  static const Color _primaryColor = Color(0xFF526ED3);
  static const Color _fieldColor = Color(0xFFF9F9F9);
  static const Color _strokeColor = Color(0xFFE8E8E8);
  static const Color _selectedColor = Color(0xFFE9E9E9);
  static const Color _textStrongColor = Color(0xFF1A1D2E);

  TaskFilterType? _selectedType;
  bool _isStatusOpen = false;

  @override
  void initState() {
    super.initState();
    for (final type in TaskFilterType.values) {
      if (type.val == widget.initialType) {
        _selectedType = type;
        break;
      }
    }
  }

  void _onApply() {
    Navigator.pop(context, FilterResult(type: _selectedType?.val));
  }

  void _onClear() {
    Navigator.pop(context, FilterResult.clear());
  }

  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.of(context);
    return Padding(
      padding: EdgeInsets.only(bottom: mq.viewInsets.bottom),
      child: Container(
        height: mq.size.height * 0.75,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          children: [
            const SizedBox(height: 12),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            const SizedBox(height: 28),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  Words.filters.tr(),
                  style: GoogleFonts.manrope(
                    fontSize: 20,
                    height: 36 / 28,
                    fontWeight: FontWeight.w800,
                    color: Colors.black,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 18),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      Words.status.tr(),
                      style: GoogleFonts.manrope(
                        fontSize: 11,
                        height: 24 / 17,
                        fontWeight: FontWeight.w500,
                        color: _textStrongColor,
                      ),
                    ),
                    const SizedBox(height: 4),
                    _buildStatusSelector(),
                    if (_isStatusOpen) _buildStatusOptions(),
                  ],
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(20, 8, 20, mq.padding.bottom + 16),
              child: Row(
                children: [
                  Expanded(
                    child: _SheetActionButton(
                      label: Words.clear.tr(),
                      icon: Icons.close_rounded,
                      backgroundColor: const Color(0xFFF0F0F0),
                      foregroundColor: _textStrongColor,
                      onPressed: _onClear,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _SheetActionButton(
                      label: Words.search.tr().replaceAll('...', ''),
                      icon: Icons.search_rounded,
                      backgroundColor: _primaryColor,
                      foregroundColor: Colors.white,
                      onPressed: _onApply,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusSelector() {
    return Material(
      color: _fieldColor,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => setState(() => _isStatusOpen = !_isStatusOpen),
        child: Container(
          // constraints: const BoxConstraints(minHeight: 44),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: _strokeColor, width: 1.2),
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  _selectedType?.label() ?? Words.select.tr(),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.manrope(
                    fontSize: 13,
                    height: 26 / 18,
                    fontWeight: FontWeight.w500,
                    color: _textStrongColor,
                  ),
                ),
              ),
              Icon(
                _isStatusOpen
                    ? Icons.keyboard_arrow_up_rounded
                    : Icons.keyboard_arrow_down_rounded,
                size: 30,
                color: const Color(0xFF202020),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusOptions() {
    return Container(
      margin: const EdgeInsets.only(top: 8),
      padding: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: _fieldColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _strokeColor, width: 1.2),
      ),
      child: Column(
        children: TaskFilterType.values.map((type) {
          final selected = type == _selectedType;
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
            child: Material(
              color: selected ? _selectedColor : Colors.transparent,
              borderRadius: BorderRadius.circular(12),
              child: InkWell(
                borderRadius: BorderRadius.circular(12),
                onTap: () {
                  setState(() {
                    _selectedType = type;
                    _isStatusOpen = false;
                  });
                },
                child: Container(
                  constraints: const BoxConstraints(minHeight: 44),
                  alignment: Alignment.centerLeft,
                  padding: const EdgeInsets.symmetric(horizontal: 6),
                  child: Text(
                    type.label(),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.manrope(
                      fontSize: 13,
                      height: 26 / 18,
                      fontWeight: FontWeight.w500,
                      color: const Color(0xFF202020),
                    ),
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _SheetActionButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color backgroundColor;
  final Color foregroundColor;
  final VoidCallback onPressed;

  const _SheetActionButton({
    required this.label,
    required this.icon,
    required this.backgroundColor,
    required this.foregroundColor,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 52,
      child: ElevatedButton.icon(
        onPressed: onPressed,
        icon: Icon(icon, color: foregroundColor, size: 16),
        label: Text(
          label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: GoogleFonts.manrope(
            fontSize: 15,
            height: 28 / 20,
            fontWeight: FontWeight.w800,
            color: foregroundColor,
          ),
        ),
        style: ElevatedButton.styleFrom(
          elevation: 0,
          backgroundColor: backgroundColor,
          foregroundColor: foregroundColor,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
        ),
      ),
    );
  }
}
