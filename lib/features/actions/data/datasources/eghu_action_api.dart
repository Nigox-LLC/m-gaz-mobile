import 'package:dio/dio.dart';

import '../../../../core/api/base/base_api.dart';
import '../../../../core/models/paginated_response/paginated_response.dart';
import '../../domain/entities/action_menu_item.dart';
import '../models/eghu_action_attachment.dart';
import '../models/eghu_action_create_request.dart';
import '../models/eghu_working_document.dart';

abstract class EghuActionSubmitApi {
  Future<void> create(EghuActionCreateRequest request);
}

abstract class EghuActionListApi {
  Future<PaginatedResponse<EghuWorkingDocument>> getDocuments({
    int limit = 10,
    int offset = 0,
    ActionMenuType? actionType,
  });

  Future<PaginatedResponse<EghuWorkingDocument>> getNextPage(String url);
}

class EghuActionApi implements EghuActionSubmitApi, EghuActionListApi {
  const EghuActionApi(this._base);

  final ApiBase _base;

  static const String egxuActionsBaseEndpoint = 'documents/egxu-actions/';
  static const String egxuRemovalsEndpoint =
      '${egxuActionsBaseEndpoint}egxu-removals/';
  static const String egxuRemovalAktEndpoint =
      '${egxuActionsBaseEndpoint}egxu-removal-akt/';

  @override
  Future<PaginatedResponse<EghuWorkingDocument>> getDocuments({
    int limit = 10,
    int offset = 0,
    ActionMenuType? actionType,
  }) async {
    try {
      final response = await _base.dio.get(
        egxuRemovalsEndpoint,
        queryParameters: {
          'limit': limit,
          'offset': offset,
          if (_documentTypeForAction(actionType) != null)
            'document_type': _documentTypeForAction(actionType),
        },
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
  Future<PaginatedResponse<EghuWorkingDocument>> getNextPage(String url) async {
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
  Future<void> create(EghuActionCreateRequest request) async {
    if (request.actionType == ActionMenuType.indicatorUpload) {
      throw UnsupportedError(
        'EGHU indicator upload is not supported by this create flow.',
      );
    }

    final uploadedAktIds = <int>[];
    try {
      uploadedAktIds.add(await _uploadAktFile(request.actFile, 'akt'));
      uploadedAktIds.add(
        await _uploadAktFile(request.comparisonFile, 'calibration'),
      );

      final response = await _base.dio.post(
        egxuRemovalsEndpoint,
        data: request.toJson(aktIds: uploadedAktIds),
        options: Options(contentType: Headers.jsonContentType),
      );

      if (response.statusCode != 200 && response.statusCode != 201) {
        throw Exception('Xatolik yuz berdi: ${response.statusCode}');
      }
    } on DioException catch (e) {
      await _deleteUploadedAktFiles(uploadedAktIds);
      throw Exception(_messageFromDio(e));
    } catch (_) {
      await _deleteUploadedAktFiles(uploadedAktIds);
      rethrow;
    }
  }

  Future<int> _uploadAktFile(
    EghuActionAttachment attachment,
    String aktFileType,
  ) async {
    final response = await _base.dio.post(
      egxuRemovalAktEndpoint,
      data: FormData.fromMap({
        'file': await MultipartFile.fromFile(
          attachment.path,
          filename: attachment.name,
        ),
        'akt_file_type': aktFileType,
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

  Future<void> _deleteUploadedAktFiles(List<int> ids) async {
    for (final id in ids) {
      try {
        await _base.dio.delete('$egxuRemovalAktEndpoint$id/');
      } catch (_) {
        // Best-effort cleanup only; keep the original create/upload failure.
      }
    }
  }

  PaginatedResponse<EghuWorkingDocument> _documentsFromResponseData(
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

  List<EghuWorkingDocument> _documentsFromList(List<dynamic> data) {
    return data
        .whereType<Map>()
        .map(
          (item) =>
              EghuWorkingDocument.fromJson(Map<String, dynamic>.from(item)),
        )
        .toList();
  }

  String? _documentTypeForAction(ActionMenuType? actionType) {
    return switch (actionType) {
      ActionMenuType.reinstall => 'reinstall',
      ActionMenuType.detach => 'removal',
      ActionMenuType.indicatorUpload || null => null,
    };
  }

  int? _parseInt(Object? value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    if (value is String) return int.tryParse(value);
    return null;
  }

  String _messageFromDio(DioException e) {
    final data = e.response?.data;
    if (data is Map) {
      return _messageFromResponseData(data);
    }
    if (data is List) return data.map((item) => item.toString()).join('\n');
    if (data is String && data.trim().isNotEmpty) return data;
    return "So'rov bajarilmadi";
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
