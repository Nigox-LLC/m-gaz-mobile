import 'package:flutter_test/flutter_test.dart';
import 'package:m_gaz/core/common/words.dart';
import 'package:m_gaz/core/enums/task_status_enum.dart';
import 'package:m_gaz/core/models/task/tasks_model.dart';

void main() {
  group('TaskStatus.fromTask', () {
    test('all flags false is pending', () {
      expect(TaskStatus.fromTask(_task()), TaskStatus.pending);
    });

    test('is_done maps to completed', () {
      expect(TaskStatus.fromTask(_task(isDone: true)), TaskStatus.completed);
    });

    test('is_approved maps to approved', () {
      expect(TaskStatus.fromTask(_task(isApproved: true)), TaskStatus.approved);
    });

    test('is_canceled maps to cancelled', () {
      expect(
        TaskStatus.fromTask(_task(isCanceled: true)),
        TaskStatus.cancelled,
      );
    });

    test('is_overdue maps to overdue', () {
      expect(TaskStatus.fromTask(_task(isOverdue: true)), TaskStatus.overdue);
    });

    test('precedence: cancelled beats approved, done and overdue', () {
      expect(
        TaskStatus.fromTask(
          _task(
            isCanceled: true,
            isApproved: true,
            isDone: true,
            isOverdue: true,
          ),
        ),
        TaskStatus.cancelled,
      );
    });

    test('precedence: approved beats done and overdue', () {
      expect(
        TaskStatus.fromTask(
          _task(isApproved: true, isDone: true, isOverdue: true),
        ),
        TaskStatus.approved,
      );
    });

    test('precedence: done beats overdue', () {
      expect(
        TaskStatus.fromTask(_task(isDone: true, isOverdue: true)),
        TaskStatus.completed,
      );
    });
  });

  group('TaskStatus.label', () {
    test('each status maps to its localization key', () {
      expect(TaskStatus.completed.label, Words.completed);
      expect(TaskStatus.approved.label, Words.taskApproved);
      expect(TaskStatus.cancelled.label, Words.taskCanceled);
      expect(TaskStatus.overdue.label, Words.taskExpired);
      expect(TaskStatus.pending.label, Words.pending);
    });
  });

  group('TaskStatus.fromFilterValue', () {
    test('maps backend list filters to display statuses', () {
      expect(TaskStatus.fromFilterValue('done-list'), TaskStatus.completed);
      expect(TaskStatus.fromFilterValue('approved-list'), TaskStatus.approved);
      expect(TaskStatus.fromFilterValue('canceled-list'), TaskStatus.cancelled);
      expect(TaskStatus.fromFilterValue('overdue-list'), TaskStatus.overdue);
      expect(TaskStatus.fromFilterValue('not-done-list'), TaskStatus.pending);
      expect(TaskStatus.fromFilterValue(null), isNull);
      expect(TaskStatus.fromFilterValue('unknown'), isNull);
    });
  });

  group('TaskStatus.displayDateFor', () {
    test('completed uses doneDate then falls back to created', () {
      final created = DateTime(2026, 5, 20, 9);
      final doneDate = DateTime(2026, 5, 22, 10, 30);

      expect(
        TaskStatus.completed.displayDateFor(
          _task(isDone: true, created: created, doneDate: doneDate),
        ),
        doneDate,
      );
      expect(
        TaskStatus.completed.displayDateFor(
          _task(isDone: true, created: created),
        ),
        created,
      );
    });

    test('approved uses approvedDate then falls back to created', () {
      final created = DateTime(2026, 5, 20, 9);
      final approvedDate = DateTime(2026, 5, 23, 14);

      expect(
        TaskStatus.approved.displayDateFor(
          _task(isApproved: true, created: created, approvedDate: approvedDate),
        ),
        approvedDate,
      );
      expect(
        TaskStatus.approved.displayDateFor(
          _task(isApproved: true, created: created),
        ),
        created,
      );
    });

    test('cancelled uses canceledDate then falls back to created', () {
      final created = DateTime(2026, 5, 20, 9);
      final canceledDate = DateTime(2026, 5, 23, 16);

      expect(
        TaskStatus.cancelled.displayDateFor(
          _task(isCanceled: true, created: created, canceledDate: canceledDate),
        ),
        canceledDate,
      );
      expect(
        TaskStatus.cancelled.displayDateFor(
          _task(isCanceled: true, created: created),
        ),
        created,
      );
    });

    test('pending or overdue uses deadline then falls back to created', () {
      final created = DateTime(2026, 5, 20, 9);
      final deadline = DateTime(2026, 5, 24, 18);

      expect(
        TaskStatus.pending.displayDateFor(
          _task(created: created, deadline: deadline),
        ),
        deadline,
      );
      expect(
        TaskStatus.overdue.displayDateFor(
          _task(isOverdue: true, created: created, deadline: deadline),
        ),
        deadline,
      );
      expect(
        TaskStatus.pending.displayDateFor(_task(created: created)),
        created,
      );
    });
  });
}

TaskModel _task({
  bool isDone = false,
  bool isApproved = false,
  bool isCanceled = false,
  bool isOverdue = false,
  DateTime? deadline,
  DateTime? doneDate,
  DateTime? approvedDate,
  DateTime? canceledDate,
  DateTime? created,
}) {
  return TaskModel(
    id: 1,
    employee: 'Test User',
    typeTask: null,
    status: 'Status',
    situation: 'Situation',
    description: 'Description',
    deadline: deadline,
    doneDate: doneDate,
    approvedDate: approvedDate,
    canceledDate: canceledDate,
    created: created ?? DateTime(2026, 5, 20, 9),
    isDone: isDone,
    isApproved: isApproved,
    isCanceled: isCanceled,
    isOverdue: isOverdue,
    isAnswerFile: false,
    consumerDocument: null,
  );
}
