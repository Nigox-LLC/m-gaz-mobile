import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:m_gaz/core/api/base/base_api.dart';
import 'package:m_gaz/core/hive/api_hive.dart';
import 'package:m_gaz/core/hive/hive_base.dart';
import 'package:m_gaz/features/actions/data/datasources/eghu_indicator_api.dart';
import 'package:m_gaz/features/actions/data/models/eghu_action_attachment.dart';
import 'package:m_gaz/features/actions/data/models/eghu_indicator_create_request.dart';

void main() {
  group('EghuIndicatorApi', () {
    late File basicFile;
    late File printFile;

    setUp(() {
      basicFile = _tempFile('basic.pdf');
      printFile = _tempFile('print.pdf');
    });

    tearDown(() {
      if (basicFile.existsSync()) basicFile.deleteSync();
      if (printFile.existsSync()) printFile.deleteSync();
    });

    test('loads paginated indicators', () async {
      final adapter = _RecordingAdapter([
        _RecordedResponse(200, {
          'count': 1,
          'next': null,
          'previous': null,
          'results': [
            {
              'id': 1,
              'created_at': '2026-05-31T07:36:58.008Z',
              'is_active': true,
              'value': '2924.00',
              'consumer': 12,
              'consumer_info': {
                'id': 12,
                'name': 'Test Consumer',
                'region_info': {'id': 7, 'name': 'Hududgaz Samarqand GTF'},
                'district_info': {'id': 88, 'name': 'Samarqand shahar'},
                'facial': '1430200078',
                'employee': null,
              },
              'egxu': 44,
              'egxu_info': {
                'one_factory': '11140',
                'two_factory': null,
                'egxu_type': 'СТГ 80/400',
              },
              'files': [
                {
                  'id': 3,
                  'egxu_indicator': 1,
                  'file': 'https://example.com/print.jpg',
                  'file_type': 'print',
                  'created_at': '2026-05-31T18:01:23.614209+05:00',
                },
                {
                  'id': 2,
                  'egxu_indicator': 1,
                  'file': 'https://example.com/basic.jpg',
                  'file_type': 'basic',
                  'created_at': '2026-05-31T18:01:23.386457+05:00',
                },
              ],
            },
          ],
        }),
      ]);
      final api = _api(adapter);

      final response = await api.getDocuments(
        limit: 10,
        search: '1430200078',
        startDate: DateTime(2026, 5),
        endDate: DateTime(2026, 5, 31),
        regionId: 7,
        districtId: 88,
      );

      expect(adapter.requests.single.path, EghuIndicatorApi.indicatorsEndpoint);
      expect(adapter.requests.single.queryParameters['limit'], 10);
      expect(adapter.requests.single.queryParameters['search'], '1430200078');
      expect(
        adapter.requests.single.queryParameters['start_date'],
        '2026-05-01',
      );
      expect(adapter.requests.single.queryParameters['end_date'], '2026-05-31');
      expect(adapter.requests.single.queryParameters['region'], 7);
      expect(adapter.requests.single.queryParameters['district'], 88);
      expect(response.count, 1);
      expect(response.results.single.value, '2924.00');
      expect(response.results.single.consumerId, 12);
      expect(response.results.single.egxuId, 44);
      expect(response.results.single.personalAccount, '1430200078');
      expect(response.results.single.consumerName, 'Test Consumer');
      expect(response.results.single.region, 'Hududgaz Samarqand GTF');
      expect(response.results.single.district, 'Samarqand shahar');
      expect(response.results.single.factoryNumber, '11140');
      expect(response.results.single.egxuType, 'СТГ 80/400');
      expect(response.results.single.files, hasLength(2));
      expect(response.results.single.files.first.fileType, 'print');
    });

    test('does not send empty search and null filters', () async {
      final adapter = _RecordingAdapter([
        _RecordedResponse(200, {'count': 0, 'results': []}),
      ]);
      final api = _api(adapter);

      await api.getDocuments(limit: 10, offset: 20, search: '   ');

      expect(adapter.requests.single.queryParameters, {
        'limit': 10,
        'offset': 20,
      });
    });

    test('loads indicator detail', () async {
      final adapter = _RecordingAdapter([
        _RecordedResponse(200, _indicatorBody(id: 8)),
      ]);
      final api = _api(adapter);

      final detail = await api.getDetail(8);

      expect(adapter.requests.single.method, 'GET');
      expect(
        adapter.requests.single.path,
        '${EghuIndicatorApi.indicatorsEndpoint}8/',
      );
      expect(detail.id, 8);
      expect(detail.personalAccount, '1430200078');
      expect(detail.files.map((item) => item.fileType), ['print', 'basic']);
    });

    test('creates indicator then uploads basic and print files', () async {
      final adapter = _RecordingAdapter([
        _RecordedResponse(201, {'id': 91}),
        _RecordedResponse(201, {'id': 7}),
        _RecordedResponse(201, {'id': 8}),
      ]);
      final api = _api(adapter);

      await api.create(_request(basicFile: basicFile, printFile: printFile));

      expect(adapter.requests.map((item) => item.method), [
        'POST',
        'POST',
        'POST',
      ]);
      expect(adapter.requests[0].path, EghuIndicatorApi.indicatorsEndpoint);
      expect(adapter.requests[1].path, EghuIndicatorApi.indicatorFilesEndpoint);
      expect(adapter.requests[2].path, EghuIndicatorApi.indicatorFilesEndpoint);

      final createBody = adapter.requests[0].data as Map<String, Object?>;
      expect(createBody['created_at'], '2026-05-31T07:36:58.008Z');
      expect(createBody['is_active'], true);
      expect(createBody['value'], '2924.00');
      expect(createBody['consumer'], 12);
      expect(createBody['egxu'], 44);

      expect(_formField(adapter.requests[1], 'file_type'), 'basic');
      expect(_formField(adapter.requests[1], 'egxu_indicator'), '91');
      expect(
        _formField(adapter.requests[1], 'created_at'),
        '2026-05-31T07:36:58.008Z',
      );
      expect(_formField(adapter.requests[1], 'is_active'), 'true');
      expect(_formField(adapter.requests[2], 'file_type'), 'print');
      expect(_formField(adapter.requests[2], 'egxu_indicator'), '91');
      expect(
        _formField(adapter.requests[2], 'created_at'),
        '2026-05-31T07:36:58.008Z',
      );
      expect(_formField(adapter.requests[2], 'is_active'), 'true');
      expect(_formFileKey(adapter.requests[1]), 'file');
      expect(_formFileKey(adapter.requests[2]), 'file');
    });

    test('patches main indicator and existing file changes', () async {
      final adapter = _RecordingAdapter([
        _RecordedResponse(200, {'id': 91}),
        _RecordedResponse(200, {'id': 7}),
      ]);
      final api = _api(adapter);

      await api.update(
        EghuIndicatorUpdateRequest(
          id: 91,
          value: '2924.50',
          consumerId: 12,
          egxuId: 44,
          mainChanged: true,
          basicFileChanged: true,
          printFileChanged: false,
          basicFile: _attachment(basicFile),
          basicFileId: 7,
        ),
      );

      expect(adapter.requests.map((item) => item.method), ['PATCH', 'PATCH']);
      expect(
        adapter.requests[0].path,
        '${EghuIndicatorApi.indicatorsEndpoint}91/',
      );
      expect(adapter.requests[0].data, {
        'consumer': 12,
        'egxu': 44,
        'value': '2924.50',
      });
      expect(
        adapter.requests[1].path,
        '${EghuIndicatorApi.indicatorFilesEndpoint}7/',
      );
      expect(_formField(adapter.requests[1], 'file_type'), 'basic');
      expect(_formField(adapter.requests[1], 'egxu_indicator'), '91');
      expect(_formFileKey(adapter.requests[1]), 'file');
    });

    test('creates file when changed slot has no existing file id', () async {
      final adapter = _RecordingAdapter([
        _RecordedResponse(201, {'id': 8}),
      ]);
      final api = _api(adapter);

      await api.update(
        EghuIndicatorUpdateRequest(
          id: 91,
          value: '2924.50',
          consumerId: 12,
          egxuId: 44,
          mainChanged: false,
          basicFileChanged: false,
          printFileChanged: true,
          printFile: _attachment(printFile),
        ),
      );

      expect(adapter.requests.single.method, 'POST');
      expect(
        adapter.requests.single.path,
        EghuIndicatorApi.indicatorFilesEndpoint,
      );
      expect(_formField(adapter.requests.single, 'file_type'), 'print');
      expect(_formField(adapter.requests.single, 'egxu_indicator'), '91');
      expect(_formField(adapter.requests.single, 'is_active'), 'true');
      expect(_formFileKey(adapter.requests.single), 'file');
    });

    test('does not send unchanged remote files', () async {
      final adapter = _RecordingAdapter([]);
      final api = _api(adapter);

      await api.update(
        const EghuIndicatorUpdateRequest(
          id: 91,
          value: '2924.50',
          consumerId: 12,
          egxuId: 44,
          mainChanged: false,
          basicFileChanged: false,
          printFileChanged: false,
        ),
      );

      expect(adapter.requests, isEmpty);
    });

    test(
      'cleans up uploaded file and indicator when second upload fails',
      () async {
        final adapter = _RecordingAdapter([
          _RecordedResponse(201, {'id': 91}),
          _RecordedResponse(201, {'id': 7}),
          _RecordedResponse(400, {
            'file': ['Invalid file'],
          }),
          _RecordedResponse(204, {}),
          _RecordedResponse(204, {}),
        ]);
        final api = _api(adapter);

        await expectLater(
          api.create(_request(basicFile: basicFile, printFile: printFile)),
          throwsA(
            isA<Exception>().having(
              (error) => error.toString(),
              'message',
              contains('file: Invalid file'),
            ),
          ),
        );

        expect(adapter.requests.map((item) => item.method), [
          'POST',
          'POST',
          'POST',
          'DELETE',
          'DELETE',
        ]);
        expect(
          adapter.requests[3].path,
          '${EghuIndicatorApi.indicatorFilesEndpoint}7/',
        );
        expect(
          adapter.requests[4].path,
          '${EghuIndicatorApi.indicatorsEndpoint}91/',
        );
      },
    );

    test(
      'surfaces clear message when file upload endpoint rejects POST',
      () async {
        final adapter = _RecordingAdapter([
          _RecordedResponse(201, {'id': 91}),
          _RecordedResponse(405, {'detail': 'Method "POST" not allowed.'}),
          _RecordedResponse(204, {}),
        ]);
        final api = _api(adapter);

        await expectLater(
          api.create(_request(basicFile: basicFile, printFile: printFile)),
          throwsA(
            isA<Exception>().having(
              (error) => error.toString(),
              'message',
              contains("POST metodini qabul qilmayapti"),
            ),
          ),
        );

        expect(adapter.requests.map((item) => item.method), [
          'POST',
          'POST',
          'DELETE',
        ]);
        expect(
          adapter.requests[2].path,
          '${EghuIndicatorApi.indicatorsEndpoint}91/',
        );
      },
    );
  });
}

Map<String, Object?> _indicatorBody({required int id}) {
  return {
    'id': id,
    'created_at': '2026-05-31T18:01:23.057508+05:00',
    'value': '50.00',
    'consumer': 68424,
    'consumer_info': {
      'id': 68424,
      'name': '"ZO`R SHASHLIK" OILAVIY KORXONA',
      'region_info': {'id': 7, 'name': '"Hududgaz Samarqand" GTF'},
      'district_info': {'id': 88, 'name': 'Samarqand shahar'},
      'facial': '1430200078',
      'employee': null,
    },
    'egxu': 1436318,
    'egxu_info': {
      'from_date': null,
      'to_date': '2026-05-30',
      'one_factory': '11140',
      'two_factory': null,
      'egxu_type': 'СТГ 80/400',
      'egxu_connection_point': null,
    },
    'files': [
      {
        'id': 3,
        'egxu_indicator': id,
        'file': 'https://example.com/print.jpg',
        'file_type': 'print',
        'created_at': '2026-05-31T18:01:23.614209+05:00',
      },
      {
        'id': 2,
        'egxu_indicator': id,
        'file': 'https://example.com/basic.jpg',
        'file_type': 'basic',
        'created_at': '2026-05-31T18:01:23.386457+05:00',
      },
    ],
  };
}

EghuIndicatorApi _api(_RecordingAdapter adapter) {
  final dio = Dio()..httpClientAdapter = adapter;
  return EghuIndicatorApi(ApiBase(dio, _TestApiHive()));
}

EghuIndicatorCreateRequest _request({
  required File basicFile,
  required File printFile,
}) {
  return EghuIndicatorCreateRequest(
    createdAt: DateTime.utc(2026, 5, 31, 7, 36, 58, 8),
    value: '2924.00',
    consumerId: 12,
    egxuId: 44,
    basicFile: _attachment(basicFile),
    printFile: _attachment(printFile),
  );
}

EghuActionAttachment _attachment(File file) {
  return EghuActionAttachment(
    path: file.path,
    name: file.uri.pathSegments.last,
    sizeBytes: file.lengthSync(),
    isImage: false,
    sourceLabel: 'Test',
    createdAt: DateTime(2026, 5, 31),
  );
}

File _tempFile(String name) {
  return File(
    '${Directory.systemTemp.path}/eghu-indicator-api-${DateTime.now().microsecondsSinceEpoch}-$name',
  )..writeAsBytesSync(List<int>.filled(16, 1));
}

String? _formField(RequestOptions options, String key) {
  final formData = options.data as FormData;
  for (final field in formData.fields) {
    if (field.key == key) return field.value;
  }
  return null;
}

String? _formFileKey(RequestOptions options) {
  final formData = options.data as FormData;
  return formData.files.isEmpty ? null : formData.files.single.key;
}

class _RecordingAdapter implements HttpClientAdapter {
  _RecordingAdapter(this._responses);

  final List<_RecordedResponse> _responses;
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

class _RecordedResponse {
  const _RecordedResponse(this.statusCode, this.body);

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
