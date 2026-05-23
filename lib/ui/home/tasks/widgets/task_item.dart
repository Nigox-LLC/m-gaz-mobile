import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:file_picker/file_picker.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:m_gaz/core/utils/colors.dart';
import 'package:m_gaz/core/utils/services/location_service.dart';
import 'package:m_gaz/global_widget/app_tools.dart';
import 'package:m_gaz/ui/home/tasks/bloc/task_bloc.dart';
import 'package:m_gaz/ui/home/tasks/bloc/task_event.dart';
import '../../../../core/common/words.dart';
import '../../../../core/models/task/tasks_model.dart';
import '../bloc/task_state.dart';
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
          onTap: displayStatus == TaskDisplayStatus.pending
              ? () => _showTaskActionDialog(context)
              : null,
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
                      crossAxisAlignment: CrossAxisAlignment.start,
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

// ================= MODAL =================
class TaskActionModal extends StatefulWidget {
  final TaskModel task;

  const TaskActionModal({super.key, required this.task});

  @override
  State<TaskActionModal> createState() => _TaskActionModalState();
}

class _TaskActionModalState extends State<TaskActionModal> {
  String? selectedFilePath;
  bool isLoadingComplete = false;
  bool isLoadingCancel = false;

  @override
  Widget build(BuildContext context) {
    return BlocListener<TaskBloc, TaskState>(
      listener: (context, state) {
        if (!isLoadingComplete || state.isCompletingTask) return;

        if (state.status == TaskStatus.success) {
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(Words.taskCompleted.tr()),
              backgroundColor: Colors.green,
            ),
          );
          return;
        }

        if (state.status == TaskStatus.fail) {
          setState(() => isLoadingComplete = false);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                state.errorMessage ?? "Vazifani bajarishda xatolik yuz berdi",
              ),
              backgroundColor: Colors.red,
            ),
          );
        }
      },
      child: Container(
        margin: EdgeInsets.only(
          left: 16,
          right: 16,
          top: 16,
          bottom: 16 + MediaQuery.of(context).viewInsets.bottom,
        ),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.2),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxHeight:
                MediaQuery.of(context).size.height * 0.85 -
                MediaQuery.of(context).viewInsets.bottom,
          ),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Handle bar
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // Title
                Text(
                  Words.taskAction.tr(),
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.c1570EF,
                  ),
                ),
                const SizedBox(height: 16),

                // VAZIFA HOLATI (SITUATION)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: _getSituationColor(
                      widget.task.situation,
                    ).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: _getSituationColor(
                        widget.task.situation,
                      ).withValues(alpha: 0.3),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.warning_amber_rounded,
                            color: _getSituationColor(widget.task.situation),
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            Words.taskSituation.tr(),
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade600,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        widget.task.situation,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: _getSituationColor(widget.task.situation),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Izoh
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade50,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        Words.comment.tr(),
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        widget.task.description,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // File attachment (only if isAnswerFile is true)
                if (widget.task.isAnswerFile == true) ...[
                  _buildFileSection(),
                  const SizedBox(height: 24),
                ],

                // Action buttons
                Row(
                  children: [
                    Expanded(
                      child: _buildActionButton(
                        icon: Icons.check_circle_outline,
                        label: Words.done.tr(),
                        color: Colors.green,
                        isLoading: isLoadingComplete,
                        onTap: () => _handleAction(true),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildActionButton(
                        icon: Icons.cancel_outlined,
                        label: Words.cancelAction.tr(),
                        color: Colors.red,
                        isLoading: isLoadingCancel,
                        onTap: () => _handleAction(false),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Cancel button
                SizedBox(
                  width: double.infinity,
                  child: TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text(
                      Words.close.tr(),
                      style: TextStyle(color: Colors.grey.shade600),
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

  Color _getSituationColor(String situation) {
    final lower = situation.toLowerCase();
    if (lower.contains('muhim') ||
        lower.contains('critical') ||
        lower.contains('darhol')) {
      return Colors.red;
    } else if (lower.contains('o\'rta') ||
        lower.contains('medium') ||
        lower.contains('normal')) {
      return Colors.orange;
    } else if (lower.contains('past') ||
        lower.contains('low') ||
        lower.contains('oddiy')) {
      return Colors.green;
    }
    return AppColors.c1570EF;
  }

  Widget _buildFileSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.c1570EF.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.c1570EF.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.attach_file, color: AppColors.c1570EF),
              const SizedBox(width: 8),
              Text(
                Words.attachFile.tr(),
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: AppColors.c1570EF,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (selectedFilePath != null)
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.green.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.green.shade200),
              ),
              child: Row(
                children: [
                  Icon(Icons.check_circle, color: Colors.green, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      selectedFilePath!.split('/').last,
                      style: TextStyle(
                        color: Colors.green.shade700,
                        fontWeight: FontWeight.w500,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  IconButton(
                    icon: Icon(
                      Icons.close,
                      color: Colors.green.shade700,
                      size: 20,
                    ),
                    onPressed: () => setState(() => selectedFilePath = null),
                  ),
                ],
              ),
            )
          else
            InkWell(
              onTap: _pickFile,
              borderRadius: BorderRadius.circular(12),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 16),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: AppColors.c1570EF.withValues(alpha: 0.3),
                    style: BorderStyle.solid,
                  ),
                ),
                child: Column(
                  children: [
                    Icon(Icons.upload_file, color: AppColors.c1570EF, size: 32),
                    const SizedBox(height: 8),
                    Text(
                      Words.chooseFile.tr(),
                      style: TextStyle(
                        color: AppColors.c1570EF,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      Words.fileLimitHint.tr(),
                      style: TextStyle(
                        color: Colors.grey.shade500,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
    required bool isLoading,
  }) {
    return InkWell(
      onTap: isLoading ? null : onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withValues(alpha: 0.3)),
        ),
        child: isLoading
            ? Center(
                child: CircularProgressIndicator(color: color, strokeWidth: 2),
              )
            : Column(
                children: [
                  Icon(icon, color: color, size: 28),
                  const SizedBox(height: 8),
                  Text(
                    label,
                    style: TextStyle(
                      color: color,
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  Future<void> _pickFile() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        allowMultiple: false,
        type: FileType.custom,
        allowedExtensions: const ['pdf', 'jpg', 'jpeg', 'png'],
        withData: false,
      );

      final file = result?.files.single;
      final path = file?.path;
      if (file == null || path == null) return;

      const maxBytes = 10 * 1024 * 1024;
      if (file.size > maxBytes) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(Words.fileTooLarge.tr()),
            backgroundColor: Colors.orange,
          ),
        );
        return;
      }

      setState(() => selectedFilePath = path);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Faylni tanlab bo'lmadi: ${_cleanError(e)}"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _handleAction(bool isCompleted) async {
    if (widget.task.isAnswerFile == true &&
        selectedFilePath == null &&
        isCompleted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(Words.fileRequired.tr()),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    if (!isCompleted) {
      return;
    }

    setState(() {
      isLoadingComplete = true;
    });

    try {
      final position = await LocationService.getCurrentLocation().timeout(
        const Duration(seconds: 20),
      );
      if (position == null) {
        throw Exception("Joylashuv topilmadi");
      }
      if (!mounted) return;

      context.read<TaskBloc>().add(
        TaskComplete(
          taskId: widget.task.id,
          filePath: selectedFilePath,
          latitude: position.latitude,
          longitude: position.longitude,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => isLoadingComplete = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            "Lokatsiyani olib bo'lmadi. Qayta urinib ko'ring: ${_cleanError(e)}",
          ),
          backgroundColor: Colors.orange,
        ),
      );
    }
  }

  String _cleanError(Object error) {
    return error.toString().replaceAll('Exception: ', '');
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
