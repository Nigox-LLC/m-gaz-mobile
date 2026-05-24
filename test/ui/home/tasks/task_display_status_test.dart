import 'package:flutter_test/flutter_test.dart';
import 'package:m_gaz/core/models/task/tasks_model.dart';
import 'package:m_gaz/ui/home/tasks/widgets/task_display_status.dart';

void main() {
  group('TaskDisplayStatus', () {
    test('done task stays completed even when deadline is expired', () {
      final now = DateTime(2026, 5, 23, 12);
      final task = _task(
        isDone: true,
        deadline: now.subtract(const Duration(days: 1)),
      );

      expect(
        TaskDisplayStatus.fromTask(task, now: now),
        TaskDisplayStatus.completed,
      );
    });

    test('not done task with past deadline is expired', () {
      final now = DateTime(2026, 5, 23, 12);
      final task = _task(
        isDone: false,
        deadline: now.subtract(const Duration(minutes: 1)),
      );

      expect(
        TaskDisplayStatus.fromTask(task, now: now),
        TaskDisplayStatus.expired,
      );
    });

    test('not done task with future or null deadline is pending', () {
      final now = DateTime(2026, 5, 23, 12);

      expect(
        TaskDisplayStatus.fromTask(
          _task(isDone: false, deadline: now.add(const Duration(minutes: 1))),
          now: now,
        ),
        TaskDisplayStatus.pending,
      );
      expect(
        TaskDisplayStatus.fromTask(_task(isDone: false), now: now),
        TaskDisplayStatus.pending,
      );
    });

    test(
      'date pill uses doneDate for completed task and falls back to created',
      () {
        final created = DateTime(2026, 5, 20, 9);
        final doneDate = DateTime(2026, 5, 22, 10, 30);

        expect(
          TaskDisplayStatus.completed.displayDateFor(
            _task(isDone: true, created: created, doneDate: doneDate),
          ),
          doneDate,
        );
        expect(
          TaskDisplayStatus.completed.displayDateFor(
            _task(isDone: true, created: created),
          ),
          created,
        );
      },
    );

    test(
      'date pill uses deadline for pending or expired and falls back to created',
      () {
        final created = DateTime(2026, 5, 20, 9);
        final deadline = DateTime(2026, 5, 24, 18);

        expect(
          TaskDisplayStatus.pending.displayDateFor(
            _task(isDone: false, created: created, deadline: deadline),
          ),
          deadline,
        );
        expect(
          TaskDisplayStatus.expired.displayDateFor(
            _task(isDone: false, created: created, deadline: deadline),
          ),
          deadline,
        );
        expect(
          TaskDisplayStatus.pending.displayDateFor(
            _task(isDone: false, created: created),
          ),
          created,
        );
      },
    );
  });
}

TaskModel _task({
  required bool isDone,
  DateTime? deadline,
  DateTime? doneDate,
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
    approvedDate: null,
    canceledDate: null,
    created: created ?? DateTime(2026, 5, 20, 9),
    isDone: isDone,
    isApproved: false,
    isCanceled: false,
    isAnswerFile: false,
    consumerDocument: null,
  );
}
