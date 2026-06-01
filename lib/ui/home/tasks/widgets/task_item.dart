import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:m_gaz/core/utils/colors.dart';
import 'package:m_gaz/global_widget/app_tools.dart';
import '../../../../core/common/words.dart';
import '../../../../core/models/task/tasks_model.dart';
import 'task_action_modal.dart';
import 'task_display_status.dart';

class TaskItemWidget extends StatelessWidget {
  final TaskModel task;
  final VoidCallback? onTap;

  const TaskItemWidget({super.key, required this.task, this.onTap});

  @override
  Widget build(BuildContext context) {
    final displayStatus = TaskDisplayStatus.fromTask(task);
    final formattedDate = DateFormat(
      'd MMM, HH:mm',
    ).format(displayStatus.displayDateFor(task));

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          onTap:
              onTap ??
              (displayStatus == TaskDisplayStatus.pending
                  ? () => _showTaskActionDialog(context)
                  : null),
          borderRadius: BorderRadius.circular(16),
          child: Ink(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              color: const Color(0xFFF0F0F0),
              border: Border.all(color: const Color(0xFFEEF1F7)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                LayoutBuilder(
                  builder: (context, constraints) {
                    final statusMaxWidth = constraints.maxWidth < 320
                        ? 112.0
                        : 130.0;

                    return Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        _TaskAvatar(initials: _buildInitials(task.employee)),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.only(top: 4),
                            child: Text(
                              _readable(task.employee),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: GoogleFonts.manrope(
                                fontSize: 15,
                                height: 24 / 15,
                                fontWeight: FontWeight.w800,
                                color: const Color(0xFF1A1D2E),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        ConstrainedBox(
                          constraints: BoxConstraints(maxWidth: statusMaxWidth),
                          child: _ModernStatusChip(status: displayStatus),
                        ),
                      ],
                    );
                  },
                ),
                const SizedBox(height: 12),
                _TaskInfoBlock(
                  label: Words.status.tr(),
                  value: _readable(task.status),
                  maxLines: 2,
                ),
                const SizedBox(height: 8),
                _TaskInfoBlock(
                  label: Words.situation.tr(),
                  value: _readable(task.situation),
                  maxLines: 2,
                ),
                const SizedBox(height: 8),
                _TaskInfoBlock(
                  label: Words.comment.tr(),
                  value: _readable(task.description),
                  maxLines: 3,
                ),
                const SizedBox(height: 8),
                Align(
                  alignment: Alignment.centerRight,
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 180),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.white,
                        borderRadius: BorderRadius.circular(21),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.access_time,
                            size: 16,
                            color: Color(0xFF202020),
                          ),
                          const SizedBox(width: 4),
                          Flexible(
                            child: Text(
                              formattedDate,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: GoogleFonts.manrope(
                                fontSize: 13,
                                height: 20 / 13,
                                fontWeight: FontWeight.w500,
                                color: const Color(0xFF202020),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _buildInitials(String value) {
    final parts = value.trim().split(RegExp(r'\s+'));
    final initials = parts
        .where((part) => part.isNotEmpty)
        .take(2)
        .map((part) => part.characters.first)
        .join()
        .toUpperCase();

    return initials.isEmpty ? '?' : initials;
  }

  String _readable(String value) {
    final trimmed = value.trim();
    return trimmed.isEmpty ? Words.noData.tr() : trimmed;
  }

  void _showTaskActionDialog(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => TaskActionModal(task: task),
    );
  }
}

// ================= HELPER WIDGETS =================
class _TaskAvatar extends StatelessWidget {
  final String initials;

  const _TaskAvatar({required this.initials});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 32,
      height: 32,
      alignment: Alignment.center,
      decoration: const BoxDecoration(
        color: Color(0xFF9AA1B5),
        shape: BoxShape.circle,
      ),
      child: Text(
        initials,
        maxLines: 1,
        overflow: TextOverflow.clip,
        style: GoogleFonts.manrope(
          fontSize: initials.characters.length > 1 ? 11 : 13,
          height: 20 / 13,
          fontWeight: FontWeight.w800,
          color: AppColors.white,
        ),
      ),
    );
  }
}

class _ModernStatusChip extends StatelessWidget {
  final TaskDisplayStatus status;

  const _ModernStatusChip({required this.status});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15),
        color: status.color,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          AppTools.svg(
            status.iconAsset,
            colorFilter: ColorFilter.mode(AppColors.white, BlendMode.srcIn),
          ),
          const SizedBox(width: 4),
          Flexible(
            child: Text(
              status.label.tr(),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.manrope(
                fontWeight: FontWeight.w800,
                fontSize: 11,
                height: 16 / 11,
                letterSpacing: 0.4,
                color: AppColors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TaskInfoBlock extends StatelessWidget {
  final String label;
  final String value;
  final int maxLines;

  const _TaskInfoBlock({
    required this.label,
    required this.value,
    required this.maxLines,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: GoogleFonts.manrope(
            fontSize: 13,
            height: 20 / 13,
            fontWeight: FontWeight.w500,
            color: const Color(0xFFBBBBBB),
          ),
        ),
        Text(
          value,
          maxLines: maxLines,
          overflow: TextOverflow.ellipsis,
          style: GoogleFonts.manrope(
            fontSize: 13,
            height: 20 / 13,
            fontWeight: FontWeight.w800,
            color: const Color(0xFF202020),
          ),
        ),
      ],
    );
  }
}
