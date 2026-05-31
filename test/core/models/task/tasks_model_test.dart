import 'package:flutter_test/flutter_test.dart';
import 'package:m_gaz/core/models/task/tasks_model.dart';

void main() {
  group('TaskModel.fromJson', () {
    test('parses lookup objects as display text', () {
      final task = TaskModel.fromJson({
        'id': 12,
        'employee': {'id': 110, 'fio': 'Toshmatov Axrorjon'},
        'type_task': {'id': 1, 'name': 'Tekshiruv'},
        'status': {'id': 2, 'name': 'Yangi'},
        'situation': {'id': 3, 'title': 'Kutilmoqda'},
        'description': 'Izoh',
        'deadline': '2026-05-30T09:50:57Z',
        'done_date': null,
        'approved_date': null,
        'canceled_date': null,
        'created': '2026-05-30T09:00:00Z',
        'is_done': false,
        'is_approved': false,
        'is_canceled': 0,
        'is_answer_file': 'true',
        'consumer_document': {
          'document_id': '69335',
          'document_name': {'name': 'Iste\'molchi hujjati'},
        },
      });

      expect(task.id, 12);
      expect(task.employee, 'Toshmatov Axrorjon');
      expect(task.typeTask, 'Tekshiruv');
      expect(task.status, 'Yangi');
      expect(task.situation, 'Kutilmoqda');
      expect(task.deadline, DateTime.parse('2026-05-30T09:50:57Z'));
      expect(task.isAnswerFile, isTrue);
      expect(task.consumerDocument?.documentId, 69335);
      expect(task.consumerDocument?.documentName, 'Iste\'molchi hujjati');
    });

    test('keeps legacy string fields supported', () {
      final task = TaskModel.fromJson({
        'id': 1,
        'employee': 'Test User',
        'type_task': null,
        'status': 'Yangi',
        'situation': 'Jarayonda',
        'description': 'Oddiy task',
        'created': '2026-05-30T09:00:00Z',
        'is_done': false,
        'is_approved': false,
        'is_canceled': false,
        'is_answer_file': false,
        'consumer_docment': null,
      });

      expect(task.employee, 'Test User');
      expect(task.typeTask, isNull);
      expect(task.status, 'Yangi');
      expect(task.situation, 'Jarayonda');
      expect(task.description, 'Oddiy task');
    });
  });
}
