import 'package:dio/dio.dart';

import '../../../../core/api/base/base_api.dart';
import '../../../../core/models/paginated_response/paginated_response.dart';
import '../../domain/entities/action_menu_item.dart';
import '../models/eghu_action_create_request.dart';
import '../models/eghu_working_document.dart';

abstract class EghuActionSubmitApi {
  Future<void> create(EghuActionCreateRequest request);
}

abstract class EghuActionListApi {
  Future<PaginatedResponse<EghuWorkingDocument>> getDocuments({
    int limit = 10,
    int offset = 0,
  });

  Future<PaginatedResponse<EghuWorkingDocument>> getNextPage(String url);
}

class EghuActionApi implements EghuActionSubmitApi, EghuActionListApi {
  const EghuActionApi(this._base);

  final ApiBase _base;

  static const String workingWithEgxuEndpoint = 'working-with-egxu/';

  @override
  Future<PaginatedResponse<EghuWorkingDocument>> getDocuments({
    int limit = 10,
    int offset = 0,
  }) async {
    try {
      final response = await _base.dio.get(
        workingWithEgxuEndpoint,
        queryParameters: {'limit': limit, 'offset': offset},
      );

      if (response.statusCode == 200) {
        return PaginatedResponse<EghuWorkingDocument>.fromJson(
          response.data,
          EghuWorkingDocument.fromJson,
        );
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
        return PaginatedResponse<EghuWorkingDocument>.fromJson(
          response.data,
          EghuWorkingDocument.fromJson,
        );
      }

      throw Exception('Xatolik yuz berdi: ${response.statusCode}');
    } on DioException catch (e) {
      throw Exception(_messageFromDio(e));
    }
  }

  @override
  Future<void> create(EghuActionCreateRequest request) async {
    final endpoint = switch (request.actionType) {
      ActionMenuType.reinstall ||
      ActionMenuType.detach => workingWithEgxuEndpoint,
      ActionMenuType.indicatorUpload => throw UnsupportedError(
        'EGHU indicator upload is not supported by this create flow.',
      ),
    };

    try {
      final response = await _base.dio.post(
        endpoint,
        data: request.toJson(),
        options: Options(contentType: Headers.jsonContentType),
      );

      if (response.statusCode != 200 && response.statusCode != 201) {
        throw Exception('Xatolik yuz berdi: ${response.statusCode}');
      }
    } on DioException catch (e) {
      throw Exception(_messageFromDio(e));
    }
  }

  String _messageFromDio(DioException e) {
    final data = e.response?.data;
    if (data is Map) {
      return (data['message'] ?? data['error'] ?? "So'rov bajarilmadi")
          .toString();
    }
    return "So'rov bajarilmadi";
  }
}
