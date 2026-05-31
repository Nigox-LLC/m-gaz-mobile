import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:m_gaz/core/api/base/base_api.dart';
import 'package:m_gaz/core/hive/api_hive.dart';
import 'package:m_gaz/core/hive/hive_base.dart';
import 'package:m_gaz/features/actions/data/datasources/eghu_action_api.dart';
import 'package:m_gaz/features/actions/data/models/eghu_action_attachment.dart';
import 'package:m_gaz/features/actions/data/models/eghu_action_create_request.dart';
import 'package:m_gaz/features/actions/domain/entities/action_menu_item.dart';

void main() {
  group('EghuActionApi', () {
    late File actFile;
    late File comparisonFile;

    setUp(() {
      actFile = _tempFile('act.jpg');
      comparisonFile = _tempFile('comparison.pdf');
    });

    tearDown(() {
      if (actFile.existsSync()) actFile.deleteSync();
      if (comparisonFile.existsSync()) comparisonFile.deleteSync();
    });

    test('uploads akt files before creating removal document', () async {
      final adapter = _RecordingAdapter([
        _RecordedResponse(201, {'id': 3}),
        _RecordedResponse(201, {'id': 7}),
        _RecordedResponse(201, {'id': 1}),
      ]);
      final api = _api(adapter);

      await api.create(
        _request(actFile: actFile, comparisonFile: comparisonFile),
      );

      expect(adapter.requests.map((item) => item.method), [
        'POST',
        'POST',
        'POST',
      ]);
      expect(adapter.requests[0].path, EghuActionApi.egxuRemovalAktEndpoint);
      expect(adapter.requests[1].path, EghuActionApi.egxuRemovalAktEndpoint);
      expect(adapter.requests[2].path, EghuActionApi.egxuRemovalsEndpoint);

      expect(_formField(adapter.requests[0], 'akt_file_type'), 'akt');
      expect(_formField(adapter.requests[1], 'akt_file_type'), 'calibration');
      expect(_formFileKey(adapter.requests[0]), 'file');
      expect(_formFileKey(adapter.requests[1]), 'file');

      final createBody = adapter.requests[2].data as Map<String, Object?>;
      expect(createBody['consumer'], 12);
      expect(createBody['egxu'], 44);
      expect(createBody['document_type'], 'reinstall');
      expect(createBody['akt_ids'], [3, 7]);
    });

    test('cleans up uploaded akt files when create fails', () async {
      final adapter = _RecordingAdapter([
        _RecordedResponse(201, {'id': 3}),
        _RecordedResponse(201, {'id': 7}),
        _RecordedResponse(400, {
          'reals': ['Real number already exists'],
        }),
        _RecordedResponse(204, {}),
        _RecordedResponse(204, {}),
      ]);
      final api = _api(adapter);

      await expectLater(
        api.create(_request(actFile: actFile, comparisonFile: comparisonFile)),
        throwsA(
          isA<Exception>().having(
            (error) => error.toString(),
            'message',
            contains('reals: Real number already exists'),
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
        '${EghuActionApi.egxuRemovalAktEndpoint}3/',
      );
      expect(
        adapter.requests[4].path,
        '${EghuActionApi.egxuRemovalAktEndpoint}7/',
      );
    });

    test('filters list by action type and accepts array response', () async {
      final adapter = _RecordingAdapter([
        _RecordedResponse(200, [
          {
            'id': 1,
            'document_type': 'reinstall',
            'consumer': {'region': 'Andijon', 'district': 'Asaka'},
            'egxu': {'serial_number': 'EGX-001'},
            'reason_display': 'EGHU almashtirish',
          },
        ]),
      ]);
      final api = _api(adapter);

      final response = await api.getDocuments(
        actionType: ActionMenuType.reinstall,
      );

      expect(
        adapter.requests.single.queryParameters['document_type'],
        'reinstall',
      );
      expect(response.count, 1);
      expect(response.results.single.region, 'Andijon');
      expect(response.results.single.district, 'Asaka');
      expect(response.results.single.typeOfActivity, 'EGHU almashtirish');
    });
  });
}

EghuActionApi _api(_RecordingAdapter adapter) {
  final dio = Dio()..httpClientAdapter = adapter;
  return EghuActionApi(ApiBase(dio, _TestApiHive()));
}

EghuActionCreateRequest _request({
  required File actFile,
  required File comparisonFile,
}) {
  return EghuActionCreateRequest(
    actionType: ActionMenuType.reinstall,
    consumerDocumentId: 12,
    egxuItemId: 44,
    stampNumber: '123',
    stampDateTime: DateTime(2026, 5, 28, 17, 38),
    regionId: 3,
    districtId: 50,
    typeOfActivityId: 0,
    documentType: 'consumer',
    removalReason: '',
    gasUsageStatus: '',
    usageType: '',
    hourlyGasConsumption: 0,
    dailyConsumption: 0,
    replacementReason: '',
    actFile: _attachment(actFile),
    comparisonFile: _attachment(comparisonFile),
  );
}

EghuActionAttachment _attachment(File file) {
  return EghuActionAttachment(
    path: file.path,
    name: file.uri.pathSegments.last,
    sizeBytes: file.lengthSync(),
    isImage: false,
    sourceLabel: 'Test',
    createdAt: DateTime(2026, 5, 28),
  );
}

File _tempFile(String name) {
  return File(
    '${Directory.systemTemp.path}/eghu-action-api-${DateTime.now().microsecondsSinceEpoch}-$name',
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
