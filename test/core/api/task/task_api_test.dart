import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:m_gaz/core/api/task/task_api.dart';

void main() {
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
