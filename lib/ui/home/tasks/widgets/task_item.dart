import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:file_picker/file_picker.dart';
import 'package:intl/intl.dart';
import 'package:m_gaz/core/utils/colors.dart';
import 'package:m_gaz/core/utils/services/location_service.dart';
import 'package:m_gaz/ui/home/tasks/bloc/task_bloc.dart';
import 'package:m_gaz/ui/home/tasks/bloc/task_event.dart';
import '../../../../core/common/words.dart';
import '../../../../core/models/task/tasks_model.dart';
import '../bloc/task_state.dart';

class TaskItemWidget extends StatelessWidget {
  final TaskModel task;
  final VoidCallback? onTap;

  const TaskItemWidget({super.key, required this.task, this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final formattedDate = DateFormat('dd MMM, HH:mm').format(task.created);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: InkWell(
        onTap: task.isDone ? null : () => _showTaskActionDialog(context),
        borderRadius: BorderRadius.circular(22),
        child: Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(22),
            color: AppColors.white,
            border: Border.all(
              color: task.isDone ? Colors.grey.shade300 : AppColors.c1570EF,
              width: 1.2,
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.black.withValues(alpha: 0.08),
                blurRadius: 12,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ... (qolgan UI o'zgarishsiz)
              Row(
                children: [
                  Container(
                    width: 52,
                    height: 52,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      gradient: LinearGradient(
                        colors: task.isDone
                            ? [Colors.grey, Colors.grey.shade400]
                            : [
                                AppColors.c1570EF,
                                AppColors.c1570EF.withValues(alpha: 0.7),
                              ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: task.isDone
                              ? Colors.grey.withValues(alpha: 0.4)
                              : AppColors.c1570EF.withValues(alpha: 0.4),
                          blurRadius: 8,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Center(
                      child: Text(
                        task.employee.characters.first.toUpperCase(),
                        style: TextStyle(
                          color: AppColors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Text(
                      task.employee,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                        fontSize: 18,
                        color: task.isDone ? Colors.grey.shade600 : null,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  _ModernStatusChip(isDone: task.isDone),
                ],
              ),
              const SizedBox(height: 18),
              _InfoRowModern(
                icon: Icons.info_outline,
                label: Words.status.tr(),
                value: task.status,
                colors: task.isDone ? Colors.grey : AppColors.c1570EF,
              ),
              const SizedBox(height: 12),
              _InfoRowModern(
                icon: Icons.warning_amber_rounded,
                label: Words.situation.tr(),
                value: task.situation,
                colors: task.isDone ? Colors.grey : AppColors.c1570EF,
              ),
              const SizedBox(height: 12),
              _InfoRowModern(
                icon: Icons.comment_outlined,
                label: Words.comment.tr(),
                value: task.description,
                colors: task.isDone ? Colors.grey : AppColors.c1570EF,
              ),
              const SizedBox(height: 18),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Icon(
                    Icons.schedule,
                    size: 16,
                    color: task.isDone ? Colors.grey : AppColors.c1570EF,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    formattedDate,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: task.isDone ? Colors.grey : AppColors.c1570EF,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
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
        margin: const EdgeInsets.all(16),
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
        child: Padding(
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
                      "PDF, JPG, PNG (max 10MB)",
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
        type: FileType.any,
      );

      final path = result?.files.single.path;
      if (path == null) return;

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
class _ModernStatusChip extends StatelessWidget {
  final bool isDone;

  const _ModernStatusChip({required this.isDone});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30),
        color: (isDone ? Colors.green : Colors.orange).withValues(alpha: 0.15),
        border: Border.all(
          color: isDone ? Colors.green : Colors.orange,
          width: 1.4,
        ),
        boxShadow: [
          BoxShadow(
            color: (isDone ? Colors.green : Colors.orange).withValues(
              alpha: 0.25,
            ),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(
            isDone ? Icons.check_circle : Icons.timelapse,
            color: isDone ? Colors.green : Colors.orange,
            size: 18,
          ),
          const SizedBox(width: 6),
          Text(
            isDone ? Words.completed.tr() : Words.pending.tr(),
            style: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 13,
              color: isDone ? Colors.green : Colors.orange,
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoRowModern extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color colors;

  const _InfoRowModern({
    required this.icon,
    required this.label,
    required this.value,
    required this.colors,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            color: AppColors.transparent,
            border: Border.all(color: colors, width: 1),
          ),
          child: Icon(icon, size: 20, color: colors),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(color: colors, fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: TextStyle(
                  color: colors,
                  fontWeight: FontWeight.w700,
                  fontSize: 15,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
