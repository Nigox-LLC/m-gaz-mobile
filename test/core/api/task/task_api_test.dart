import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:m_gaz/core/api/task/task_api.dart';

void main() {
  group('TaskApi.getTasks', () {
    test('uses default task list endpoint without filter', () async {
      final adapter = _RecordingAdapter();
      final api = _api(adapter);

      await api.getTasks();

      expect(adapter.requests.single.path, 'task/list/');
      expect(adapter.requests.single.queryParameters, {
        'limit': 20,
        'offset': 0,
      });
    });

    test('uses filtered endpoint when type is provided', () async {
      final adapter = _RecordingAdapter();
      final api = _api(adapter);

      await api.getTasks(type: 'not-done-list');

      expect(adapter.requests.single.path, 'task/not-done-list/');
      expect(adapter.requests.single.queryParameters, {
        'limit': 20,
        'offset': 0,
      });
    });

    test('sends non-empty search query', () async {
      final adapter = _RecordingAdapter();
      final api = _api(adapter);

      await api.getTasks(search: ' abc ');

      expect(adapter.requests.single.queryParameters, {
        'limit': 20,
        'offset': 0,
        'search': 'abc',
      });
    });

    test('does not send blank search query', () async {
      final adapter = _RecordingAdapter();
      final api = _api(adapter);

      await api.getTasks(search: '   ');

      expect(adapter.requests.single.queryParameters, {
        'limit': 20,
        'offset': 0,
      });
    });
  });

  group('TaskApi.getTaskAnalysis', () {
    test('sends no query parameters when no dates are provided', () async {
      final adapter = _RecordingAdapter();
      final api = _api(adapter);

      await api.getTaskAnalysis();

      expect(adapter.requests.single.path, 'task/analysis/');
      expect(adapter.requests.single.queryParameters, isEmpty);
    });

    test('sends from_date and to_date query parameters', () async {
      final adapter = _RecordingAdapter();
      final api = _api(adapter);

      await api.getTaskAnalysis(
        dateFrom: DateTime(2026, 3),
        dateTo: DateTime(2026, 6),
      );

      expect(adapter.requests.single.path, 'task/analysis/');
      expect(adapter.requests.single.queryParameters, {
        'from_date': '2026-03-01',
        'to_date': '2026-06-01',
      });
    });
  });
}

TaskApi _api(_RecordingAdapter adapter) {
  final dio = Dio(BaseOptions(baseUrl: 'https://backend.m-gaz.uz/api/'))
    ..httpClientAdapter = adapter;
  return TaskApi.fromDio(dio);
}

class _RecordingAdapter implements HttpClientAdapter {
  final List<RequestOptions> requests = [];

  @override
  void close({bool force = false}) {}

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    requests.add(options);
    if (requestStream != null) await requestStream.drain<void>();

    if (options.path != 'task/analysis/') {
      return ResponseBody.fromString(
        jsonEncode({
          'count': 1,
          'next': null,
          'previous': null,
          'results': [_taskJson(1)],
        }),
        200,
        headers: {
          Headers.contentTypeHeader: [Headers.jsonContentType],
        },
      );
    }

    return ResponseBody.fromString(
      jsonEncode({
        'all_task': 27,
        'done_task': 10,
        'not_done_task': 17,
        'expired_task': 20,
        'consumer_count': 4,
      }),
      200,
      headers: {
        Headers.contentTypeHeader: [Headers.jsonContentType],
      },
    );
  }
}

Map<String, dynamic> _taskJson(int id) {
  return {
    'id': id,
    'employee': 'Employee $id',
    'type_task': 'Task type',
    'status': 'Status',
    'situation': 'Situation',
    'description': 'Description',
    'deadline': null,
    'done_date': null,
    'approved_date': null,
    'canceled_date': null,
    'created': '2026-01-01T00:00:00.000Z',
    'is_done': false,
    'is_approved': false,
    'is_canceled': false,
    'is_answer_file': false,
    'consumer_document': null,
  };
}
