import 'package:flutter/material.dart';
import 'package:m_gaz/core/common/words.dart';
import 'package:m_gaz/core/models/task/tasks_model.dart';
import 'package:m_gaz/global_widget/app_tools.dart';

enum TaskStatus {
  completed,
  approved,
  cancelled,
  overdue,
  pending;

  static TaskStatus fromTask(TaskModel task) {
    if (task.isCanceled) return TaskStatus.cancelled;
    if (task.isApproved) return TaskStatus.approved;
    if (task.isDone) return TaskStatus.completed;
    if (task.isOverdue) return TaskStatus.overdue;
    return TaskStatus.pending;
  }

  static TaskStatus? fromFilterValue(String? value) {
    for (final status in TaskStatus.values) {
      if (status.filterValue == value) return status;
    }
    return null;
  }

  DateTime displayDateFor(TaskModel task) {
    return switch (this) {
      TaskStatus.completed => task.doneDate ?? task.created,
      TaskStatus.approved => task.approvedDate ?? task.created,
      TaskStatus.cancelled => task.canceledDate ?? task.created,
      TaskStatus.overdue || TaskStatus.pending => task.deadline ?? task.created,
    };
  }

  Words get label {
    return switch (this) {
      TaskStatus.completed => Words.completed,
      TaskStatus.approved => Words.taskApproved,
      TaskStatus.cancelled => Words.taskCanceled,
      TaskStatus.overdue => Words.taskExpired,
      TaskStatus.pending => Words.pending,
    };
  }

  /// Localized, human-readable status name.
  String get localizedName => label.tr();

  /// Backend list-endpoint value used when filtering tasks by status.
  String get filterValue {
    return switch (this) {
      TaskStatus.completed => 'done-list',
      TaskStatus.approved => 'approved-list',
      TaskStatus.cancelled => 'canceled-list',
      TaskStatus.overdue => 'overdue-list',
      TaskStatus.pending => 'not-done-list',
    };
  }

  Color get color {
    return switch (this) {
      TaskStatus.completed => const Color(0xFF1FC16B),
      TaskStatus.approved => const Color(0xFF335CFF),
      TaskStatus.cancelled => const Color(0xFF99A0AE),
      TaskStatus.overdue => const Color(0xFFFB3748),
      TaskStatus.pending => const Color(0xFFFA7319),
    };
  }

  String get iconAsset {
    return switch (this) {
      TaskStatus.completed => AppTools.icZap,
      TaskStatus.approved => AppTools.icCheckCircle,
      TaskStatus.cancelled => AppTools.x,
      TaskStatus.overdue => AppTools.icClock,
      TaskStatus.pending => AppTools.icLoader,
    };
  }
}
