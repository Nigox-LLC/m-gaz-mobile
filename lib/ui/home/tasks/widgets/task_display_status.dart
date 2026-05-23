import 'package:flutter/material.dart';
import 'package:m_gaz/core/common/words.dart';
import 'package:m_gaz/core/models/task/tasks_model.dart';
import 'package:m_gaz/global_widget/app_tools.dart';

enum TaskDisplayStatus {
  completed,
  expired,
  pending;

  static TaskDisplayStatus fromTask(TaskModel task, {DateTime? now}) {
    if (task.isDone) {
      return TaskDisplayStatus.completed;
    }

    final deadline = task.deadline;
    if (deadline != null && deadline.isBefore(now ?? DateTime.now())) {
      return TaskDisplayStatus.expired;
    }

    return TaskDisplayStatus.pending;
  }

  DateTime displayDateFor(TaskModel task) {
    return switch (this) {
      TaskDisplayStatus.completed => task.doneDate ?? task.created,
      TaskDisplayStatus.expired ||
      TaskDisplayStatus.pending => task.deadline ?? task.created,
    };
  }

  Words get label {
    return switch (this) {
      TaskDisplayStatus.completed => Words.completed,
      TaskDisplayStatus.expired => Words.taskExpired,
      TaskDisplayStatus.pending => Words.pending,
    };
  }

  Color get color {
    return switch (this) {
      TaskDisplayStatus.completed => const Color(0xFF1FC16B),
      TaskDisplayStatus.expired => const Color(0xFFFB3748),
      TaskDisplayStatus.pending => const Color(0xFFFA7319),
    };
  }

  String get iconAsset {
    return switch (this) {
      TaskDisplayStatus.completed => AppTools.icZap,
      TaskDisplayStatus.expired => AppTools.icClock,
      TaskDisplayStatus.pending => AppTools.icLoader,
    };
  }
}
