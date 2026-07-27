import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:m_gaz/core/network/api_client.dart';
import 'package:m_gaz/features/auth/data/datasources/auth_local_data_source.dart';
import 'package:m_gaz/features/auth/data/models/auth_token_model.dart';
import 'package:m_gaz/features/profile/data/datasources/profile_remote_data_source_impl.dart';

void main() {
  test(
    'updatePassword sends only the new password to the user patch endpoint',
    () async {
      final adapter = _RecordingAdapter(_RecordedResponse(200, {'id': 7}));
      final dio = Dio(BaseOptions(baseUrl: 'https://backend.m-gaz.uz/api/'))
        ..httpClientAdapter = adapter;
      final dataSource = ProfileRemoteDataSourceImpl(
        ApiClient(dio),
        _FakeAuthLocalDataSource(accessToken: 'token'),
      );

      await dataSource.updatePassword(userId: 7, password: 'new-password');

      expect(adapter.request.method, 'PATCH');
      expect(adapter.request.path, 'directory/users/7/');
      expect(adapter.request.data, {'password': 'new-password'});
      expect(adapter.request.headers['Authorization'], 'Bearer token');
    },
  );
}

class _RecordingAdapter implements HttpClientAdapter {
  _RecordingAdapter(this._response);

  final _RecordedResponse _response;
  late RequestOptions request;

  @override
  void close({bool force = false}) {}

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    request = options;
    if (requestStream != null) await requestStream.drain<void>();

    return ResponseBody.fromString(
      jsonEncode(_response.body),
      _response.statusCode,
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

class _FakeAuthLocalDataSource implements AuthLocalDataSource {
  _FakeAuthLocalDataSource({required this.accessToken});

  @override
  final String accessToken;

  @override
  String get refreshToken => '';

  @override
  String get savedUsername => '';

  @override
  Future<void> clear() async {}

  @override
  Future<void> clearAll() async {}

  @override
  Future<void> saveEmployeeId(int employeeId) async {}

  @override
  Future<void> saveToken(AuthTokenModel token) async {}

  @override
  Future<void> saveUsername(String value) async {}
}
