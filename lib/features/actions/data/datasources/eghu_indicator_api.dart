import 'package:dio/dio.dart';

import '../../../../core/api/base/base_api.dart';
import '../../../../core/models/paginated_response/paginated_response.dart';
import '../models/eghu_action_attachment.dart';
import '../models/eghu_indicator_create_request.dart';
import '../models/eghu_indicator_document.dart';

abstract class EghuIndicatorSubmitApi {
  Future<void> create(EghuIndicatorCreateRequest request);
}

abstract class EghuIndicatorDetailApi {
  Future<EghuIndicatorDocument> getDetail(int id);

  Future<void> update(EghuIndicatorUpdateRequest request);
}

abstract class EghuIndicatorListApi {
  Future<PaginatedResponse<EghuIndicatorDocument>> getDocuments({
    int limit = 10,
    int offset = 0,
    String? search,
    DateTime? startDate,
    DateTime? endDate,
    int? regionId,
    int? districtId,
  });

  Future<PaginatedResponse<EghuIndicatorDocument>> getNextPage(String url);
}

class EghuIndicatorApi
    implements
        EghuIndicatorSubmitApi,
        EghuIndicatorListApi,
        EghuIndicatorDetailApi {
  const EghuIndicatorApi(this._base);

  final ApiBase _base;

  static const String indicatorsEndpoint = 'egxu-indicators/indicators/';
  static const String indicatorFilesEndpoint = 'egxu-indicators/files/';

  @override
  Future<PaginatedResponse<EghuIndicatorDocument>> getDocuments({
    int limit = 10,
    int offset = 0,
    String? search,
    DateTime? startDate,
    DateTime? endDate,
    int? regionId,
    int? districtId,
  }) async {
    try {
      final queryParameters = <String, Object?>{
        'limit': limit,
        'offset': offset,
      };
      final normalizedSearch = search?.trim();
      if (normalizedSearch?.isNotEmpty == true) {
        queryParameters['search'] = normalizedSearch;
      }
      if (startDate != null) {
        queryParameters['start_date'] = _dateQueryValue(startDate);
      }
      if (endDate != null) {
        queryParameters['end_date'] = _dateQueryValue(endDate);
      }
      if (regionId != null) queryParameters['region'] = regionId;
      if (districtId != null) queryParameters['district'] = districtId;

      final response = await _base.dio.get(
        indicatorsEndpoint,
        queryParameters: queryParameters,
      );

      if (response.statusCode == 200) {
        return _documentsFromResponseData(response.data);
      }

      throw Exception('Xatolik yuz berdi: ${response.statusCode}');
    } on DioException catch (e) {
      throw Exception(_messageFromDio(e));
    }
  }

  @override
  Future<PaginatedResponse<EghuIndicatorDocument>> getNextPage(
    String url,
  ) async {
    try {
      final uri = Uri.parse(url);
      final endpoint = uri.path.replaceFirst('/api/', '');
      final response = await _base.dio.get(
        endpoint,
        queryParameters: uri.queryParameters,
      );

      if (response.statusCode == 200) {
        return _documentsFromResponseData(response.data);
      }

      throw Exception('Xatolik yuz berdi: ${response.statusCode}');
    } on DioException catch (e) {
      throw Exception(_messageFromDio(e));
    }
  }

  @override
  Future<EghuIndicatorDocument> getDetail(int id) async {
    try {
      final response = await _base.dio.get('$indicatorsEndpoint$id/');

      if (response.statusCode == 200 && response.data is Map) {
        return EghuIndicatorDocument.fromJson(
          Map<String, dynamic>.from(response.data as Map),
        );
      }

      throw Exception('Xatolik yuz berdi: ${response.statusCode}');
    } on DioException catch (e) {
      throw Exception(_messageFromDio(e));
    }
  }

  @override
  Future<void> create(EghuIndicatorCreateRequest request) async {
    final uploadedFileIds = <int>[];
    int? indicatorId;

    try {
      indicatorId = await _createIndicator(request);
      uploadedFileIds.add(
        await _uploadFile(
          indicatorId: indicatorId,
          createdAt: request.createdAt,
          attachment: request.basicFile,
          fileType: 'basic',
        ),
      );
      uploadedFileIds.add(
        await _uploadFile(
          indicatorId: indicatorId,
          createdAt: request.createdAt,
          attachment: request.printFile,
          fileType: 'print',
        ),
      );
    } on DioException catch (e) {
      await _cleanup(
        uploadedFileIds: uploadedFileIds,
        indicatorId: indicatorId,
      );
      throw Exception(_messageFromDio(e));
    } catch (_) {
      await _cleanup(
        uploadedFileIds: uploadedFileIds,
        indicatorId: indicatorId,
      );
      rethrow;
    }
  }

  @override
  Future<void> update(EghuIndicatorUpdateRequest request) async {
    try {
      if (request.mainChanged) {
        await updateIndicator(
          id: request.id,
          consumerId: request.consumerId,
          egxuId: request.egxuId,
          value: request.value,
        );
      }

      final basicFile = request.basicFile;
      if (request.basicFileChanged && basicFile != null) {
        final fileId = request.basicFileId;
        if (fileId == null) {
          await createFile(
            indicatorId: request.id,
            fileType: 'basic',
            attachment: basicFile,
          );
        } else {
          await updateFile(
            fileId: fileId,
            indicatorId: request.id,
            fileType: 'basic',
            attachment: basicFile,
          );
        }
      }

      final printFile = request.printFile;
      if (request.printFileChanged && printFile != null) {
        final fileId = request.printFileId;
        if (fileId == null) {
          await createFile(
            indicatorId: request.id,
            fileType: 'print',
            attachment: printFile,
          );
        } else {
          await updateFile(
            fileId: fileId,
            indicatorId: request.id,
            fileType: 'print',
            attachment: printFile,
          );
        }
      }
    } on DioException catch (e) {
      throw Exception(_messageFromDio(e));
    }
  }

  Future<void> updateIndicator({
    required int id,
    required int consumerId,
    required int egxuId,
    required String value,
  }) async {
    final response = await _base.dio.patch(
      '$indicatorsEndpoint$id/',
      data: {'consumer': consumerId, 'egxu': egxuId, 'value': value},
      options: Options(contentType: Headers.jsonContentType),
    );

    if (response.statusCode != 200 &&
        response.statusCode != 202 &&
        response.statusCode != 204) {
      throw Exception('Xatolik yuz berdi: ${response.statusCode}');
    }
  }

  Future<int> createFile({
    required int indicatorId,
    required String fileType,
    required EghuActionAttachment attachment,
    DateTime? createdAt,
  }) {
    return _uploadFile(
      indicatorId: indicatorId,
      createdAt: createdAt ?? DateTime.now(),
      attachment: attachment,
      fileType: fileType,
    );
  }

  Future<int> updateFile({
    required int fileId,
    required int indicatorId,
    required String fileType,
    required EghuActionAttachment attachment,
  }) async {
    final response = await _base.dio.patch(
      '$indicatorFilesEndpoint$fileId/',
      data: FormData.fromMap({
        'file': await MultipartFile.fromFile(
          attachment.path,
          filename: attachment.name,
        ),
        'file_type': fileType,
        'egxu_indicator': indicatorId,
      }),
    );

    if (response.statusCode != 200 &&
        response.statusCode != 202 &&
        response.statusCode != 204) {
      throw Exception('Xatolik yuz berdi: ${response.statusCode}');
    }

    final data = response.data;
    if (data is Map) {
      final id = _parseInt(data['id']);
      if (id != null) return id;
    }
    return fileId;
  }

  Future<int> _createIndicator(EghuIndicatorCreateRequest request) async {
    final response = await _base.dio.post(
      indicatorsEndpoint,
      data: request.toJson(),
      options: Options(contentType: Headers.jsonContentType),
    );

    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception('Xatolik yuz berdi: ${response.statusCode}');
    }

    final data = response.data;
    if (data is Map) {
      final id = _parseInt(data['id']);
      if (id != null) return id;
    }
    throw Exception("Yaratilgan ko'rsatkich ID'si qaytmadi");
  }

  Future<int> _uploadFile({
    required int indicatorId,
    required DateTime createdAt,
    required EghuActionAttachment attachment,
    required String fileType,
  }) async {
    final response = await _base.dio.post(
      indicatorFilesEndpoint,
      data: FormData.fromMap({
        'created_at': createdAt.toUtc().toIso8601String(),
        'is_active': true,
        'file': await MultipartFile.fromFile(
          attachment.path,
          filename: attachment.name,
        ),
        'file_type': fileType,
        'egxu_indicator': indicatorId,
      }),
    );

    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception('Xatolik yuz berdi: ${response.statusCode}');
    }

    final data = response.data;
    if (data is Map) {
      final id = _parseInt(data['id']);
      if (id != null) return id;
    }
    throw Exception("Yuklangan fayl ID'si qaytmadi");
  }

  Future<void> _cleanup({
    required List<int> uploadedFileIds,
    required int? indicatorId,
  }) async {
    for (final id in uploadedFileIds) {
      try {
        await _base.dio.delete('$indicatorFilesEndpoint$id/');
      } catch (_) {
        // Best-effort cleanup only; keep the original create/upload failure.
      }
    }

    if (indicatorId == null) return;
    try {
      await _base.dio.delete('$indicatorsEndpoint$indicatorId/');
    } catch (_) {
      // Best-effort cleanup only; keep the original create/upload failure.
    }
  }

  PaginatedResponse<EghuIndicatorDocument> _documentsFromResponseData(
    Object? data,
  ) {
    if (data is List) {
      final documents = _documentsFromList(data);
      return PaginatedResponse(count: documents.length, results: documents);
    }

    if (data is Map) {
      final json = Map<String, dynamic>.from(data);
      final results = json['results'];
      if (results is List) {
        return PaginatedResponse(
          count: _parseInt(json['count']) ?? results.length,
          next: json['next'] as String?,
          previous: json['previous'] as String?,
          results: _documentsFromList(results),
        );
      }
    }

    throw Exception("Noto'g'ri javob formati");
  }

  List<EghuIndicatorDocument> _documentsFromList(List<dynamic> data) {
    return data
        .whereType<Map>()
        .map(
          (item) =>
              EghuIndicatorDocument.fromJson(Map<String, dynamic>.from(item)),
        )
        .toList();
  }

  int? _parseInt(Object? value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    if (value is String) return int.tryParse(value);
    return null;
  }

  String _dateQueryValue(DateTime value) {
    final local = value.toLocal();
    final month = local.month.toString().padLeft(2, '0');
    final day = local.day.toString().padLeft(2, '0');
    return '${local.year}-$month-$day';
  }

  String _messageFromDio(DioException e) {
    if (_isIndicatorFileUploadMethodError(e)) {
      return "Ko'rsatkich faylini yuklash API endpointi POST metodini qabul qilmayapti";
    }

    final data = e.response?.data;
    if (data is Map) return _messageFromResponseData(data);
    if (data is List) return data.map((item) => item.toString()).join('\n');
    if (data is String && data.trim().isNotEmpty) return data;
    return "So'rov bajarilmadi";
  }

  bool _isIndicatorFileUploadMethodError(DioException e) {
    if (e.response?.statusCode != 405) return false;

    final path = e.requestOptions.path;
    final realPath = e.response?.realUri.path;
    return path == indicatorFilesEndpoint ||
        path.endsWith('/$indicatorFilesEndpoint') ||
        realPath == '/api/$indicatorFilesEndpoint';
  }

  String _messageFromResponseData(Map<dynamic, dynamic> data) {
    final directMessage = data['message'] ?? data['error'] ?? data['detail'];
    if (directMessage != null) return _stringifyErrorValue(directMessage);

    final fieldErrors = data.entries
        .map((entry) {
          final message = _stringifyErrorValue(entry.value);
          if (message.isEmpty) return '';
          return '${entry.key}: $message';
        })
        .where((message) => message.isNotEmpty)
        .join('\n');

    return fieldErrors.isEmpty ? "So'rov bajarilmadi" : fieldErrors;
  }

  String _stringifyErrorValue(Object? value) {
    if (value == null) return '';
    if (value is List) {
      return value
          .map(_stringifyErrorValue)
          .where((e) => e.isNotEmpty)
          .join(', ');
    }
    if (value is Map) return _messageFromResponseData(value);
    return value.toString();
  }
}
