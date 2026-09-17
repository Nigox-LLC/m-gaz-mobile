import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:m_gaz/core/api/base/base_api.dart';
import 'package:m_gaz/core/api/global/global_api.dart';
import 'package:m_gaz/core/hive/api_hive.dart';
import 'package:m_gaz/core/hive/hive_base.dart';
import 'package:m_gaz/features/actions/data/datasources/eghu_action_api.dart';
import 'package:m_gaz/features/actions/data/models/eghu_removal_flow.dart';

void main() {
  test('loads activity types from the paginated directory endpoint', () async {
    final adapter = _RecordingAdapter([
      _Response(200, {
        'count': 1,
        'next': null,
        'previous': null,
        'results': [
          {'id': '2', 'name': 'Isteʼmolchi'},
        ],
      }),
    ]);
    final dio = Dio()..httpClientAdapter = adapter;
    final api = GlobalApi(ApiBase(dio, _TestApiHive()));

    final items = await api.getActivityTypes();

    expect(items.single.id, 2);
    expect(items.single.name, 'Isteʼmolchi');
    expect(adapter.requests.single.path, 'directory/directory/');
    expect(
      adapter.requests.single.queryParameters['entity_type'],
      'Faoliyatturi',
    );
  });

  test('confirm uses the removals change-status endpoint', () async {
    final adapter = _RecordingAdapter([
      _Response(201, {'id': 77}),
      _Response(204, {}),
    ]);
    final dio = Dio()..httpClientAdapter = adapter;
    final api = EghuActionApi(ApiBase(dio, _TestApiHive()));

    final removalId = await api.createRemoval(
      EghuStampRemovalRequest(
        datetime: DateTime(2026, 9, 17, 12),
        documentId: 71332,
        egxuId: 25,
        gasUsageStatus: 'used',
      ),
    );
    await api.changeRemovalStatus(documentId: removalId, status: 'confirmed');

    expect(adapter.requests[0].path, 'working-with-egxu/removals/');
    expect(
      adapter.requests[1].path,
      'working-with-egxu/removals/77/change-status/',
    );
    expect(adapter.requests[1].data, {'status': 'confirmed'});
  });
}

class _RecordingAdapter implements HttpClientAdapter {
  _RecordingAdapter(this._responses);

  final List<_Response> _responses;
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
    final response = _responses.removeAt(0);
    return ResponseBody.fromString(
      jsonEncode(response.body),
      response.statusCode,
      headers: {
        Headers.contentTypeHeader: [Headers.jsonContentType],
      },
    );
  }
}

class _Response {
  const _Response(this.statusCode, this.body);

  final int statusCode;
  final Object body;
}

class _TestApiHive extends ApiHive {
  _TestApiHive() : super(_UnusedHiveBase());

  @override
  String get accessToken => '';

  @override
  String get refreshToken => '';

  @override
  Future<void> clear() async {}
}

class _UnusedHiveBase extends HiveBase {}
