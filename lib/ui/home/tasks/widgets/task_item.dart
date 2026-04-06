import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:m_gaz/core/utils/colors.dart';
import '../../../../core/models/task/tasks_model.dart';

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
        onTap: onTap,
        borderRadius: BorderRadius.circular(22),
        child: Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(22),
            color: AppColors.white,

            /// 🧊 GLASS BLUR BORDER
            border: Border.all(color: AppColors.c1570EF, width: 1.2),

            /// 🔥 SOFT SHADOW0
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
              // HEADER
              Row(
                children: [
                  // Avatar with neon gradient
                  Container(
                    width: 52,
                    height: 52,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.c1570EF,
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

                  // Name
                  Expanded(
                    child: Text(
                      task.employee,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                        fontSize: 18,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),

                  // Status Chip
                  _ModernStatusChip(isDone: task.isDone),
                ],
              ),

              const SizedBox(height: 18),

              // INFO SECTIONS
              _InfoRowModern(
                icon: Icons.info_outline,
                label: "Status",
                value: task.status,
                colors: AppColors.c1570EF,
              ),
              const SizedBox(height: 12),

              _InfoRowModern(
                icon: Icons.warning_amber_rounded,
                label: "Vaziyat",
                value: task.situation,
                colors: AppColors.c1570EF,
              ),
              const SizedBox(height: 12),

              _InfoRowModern(
                icon: Icons.comment_outlined,
                label: "Izoh",
                value: task.description,
                colors: AppColors.c1570EF,
              ),

              const SizedBox(height: 18),

              // DATE
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Icon(Icons.schedule, size: 16, color: AppColors.c1570EF),
                  const SizedBox(width: 6),
                  Text(
                    formattedDate,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: AppColors.c1570EF,
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
}

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
            isDone ? "Bajarilgan" : "Kutilmoqda",
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

// MODERN ROW
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
        // Glass icon box
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            color: AppColors.transparent,
            border: Border.all(color: AppColors.c1570EF, width: 1),
          ),
          child: Icon(icon, size: 20, color: AppColors.c1570EF),
        ),

        const SizedBox(width: 14),

        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  color: AppColors.c1570EF,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: TextStyle(
                  color: AppColors.c1570EF,
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
