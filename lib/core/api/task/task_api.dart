import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';
import 'package:m_gaz/core/models/task/task_analysis.dart';
import 'package:m_gaz/core/models/task/tasks_model.dart';

import '../../models/paginated_response/paginated_response.dart';
import '../base/base_api.dart';

class TaskApi {
  final ApiBase? _base;
  final Dio? _dioOverride;

  const TaskApi(ApiBase base) : _base = base, _dioOverride = null;

  @visibleForTesting
  const TaskApi.fromDio(Dio dio) : _base = null, _dioOverride = dio;

  Dio get _dio => _dioOverride ?? _base!.dio;

  Future<PaginatedResponse<TaskModel>> getTasks({
    int limit = 20,
    int offset = 0,
    String? type,
    String? search,
  }) async {
    try {
      debugPrint("🔹 Consumer Relations so'rov yuborilmoqda...");
      debugPrint("🔹 Limit: $limit, Offset: $offset");

      final query = <String, dynamic>{'limit': limit, 'offset': offset};
      if (search != null && search.trim().isNotEmpty) {
        query['search'] = search.trim();
      }

      final endpoint = type == null ? 'task/list/' : 'task/$type/';
      final response = await _dio.get(endpoint, queryParameters: query);

      debugPrint("🔹 Javob status code: ${response.statusCode}");

      if (response.statusCode == 200) {
        return PaginatedResponse<TaskModel>.fromJson(
          response.data,
          TaskModel.fromJson,
        );
      } else {
        throw Exception('Xatolik yuz berdi: ${response.statusCode}');
      }
    } on DioException catch (e) {
      final error = e.response?.data;
      String errorMessage =
          error?['message'] ?? error?['error'] ?? "So'rov bajarilmadi";
      debugPrint("❌ DioException: $errorMessage");
      throw Exception(errorMessage);
    } catch (e) {
      debugPrint("❌ UNKNOWN ERROR: $e");
      throw Exception("Kutilmagan xatolik: $e");
    }
  }

  Future<TaskAnalysisModel> getTaskAnalysis({
    DateTime? dateFrom,
    DateTime? dateTo,
  }) async {
    try {
      final queryParameters = <String, dynamic>{};
      if (dateFrom != null && dateTo != null) {
        final formatter = DateFormat('yyyy-MM-dd');
        queryParameters['from_date'] = formatter.format(dateFrom);
        queryParameters['to_date'] = formatter.format(dateTo);
      }

      final response = await _dio.get(
        "task/analysis/",
        queryParameters: queryParameters.isEmpty ? null : queryParameters,
      );

      // ❗ List bo‘lib kelsa 1-elementni olamiz
      if (response.data is List) {
        return TaskAnalysisModel.fromJson(response.data.first);
      }

      // ❗ Object bo‘lib kelsa to‘g‘ridan o‘qiymiz
      return TaskAnalysisModel.fromJson(response.data);
    } catch (e) {
      throw Exception("API error: $e");
    }
  }

  Future<PaginatedResponse<TaskModel>> getNextPage(String url) async {
    try {
      debugPrint("🔹 Keyingi sahifa so'rov yuborilmoqda...");
      debugPrint("🔹 URL: $url");

      // URL'ni parsing qilish va endpoint + queryParams ajratish
      final uri = Uri.parse(url);
      final path = uri.path; // /api/consumer-relations-documents/
      final queryParameters = uri.queryParameters; // {limit: 20, offset: 20}

      // /api/ prefiksini olib tashlash, chunki baseUrl allaqachon o'rnatilgan
      final endpoint = path.replaceFirst('/api/', '');

      final response = await _dio.get(
        endpoint,
        queryParameters: queryParameters,
      );

      debugPrint("🔹 Javob status code: ${response.statusCode}");

      if (response.statusCode == 200) {
        return PaginatedResponse<TaskModel>.fromJson(
          response.data,
          TaskModel.fromJson,
        );
      } else {
        throw Exception('Xatolik yuz berdi: ${response.statusCode}');
      }
    } on DioException catch (e) {
      final error = e.response?.data;
      String errorMessage =
          error?['message'] ?? error?['error'] ?? "So'rov bajarilmadi";
      debugPrint("❌ DioException: $errorMessage");
      throw Exception(errorMessage);
    } catch (e) {
      debugPrint("❌ UNKNOWN ERROR: $e");
      throw Exception("Kutilmagan xatolik: $e");
    }
  }

  Future<TaskModel> getDocumentById(int id) async {
    try {
      debugPrint(
        "🔹 Consumer Relations Document ID:$id so'rov yuborilmoqda...",
      );

      final response = await _dio.get('consumer-relations-documents/$id/');

      debugPrint("🔹 Javob status code: ${response.statusCode}");

      if (response.statusCode == 200) {
        return TaskModel.fromJson(response.data);
      } else {
        throw Exception('Xatolik yuz berdi: ${response.statusCode}');
      }
    } on DioException catch (e) {
      final error = e.response?.data;
      String errorMessage =
          error?['message'] ?? error?['error'] ?? "So'rov bajarilmadi";
      debugPrint("❌ DioException: $errorMessage");
      throw Exception(errorMessage);
    } catch (e) {
      debugPrint("❌ UNKNOWN ERROR: $e");
      throw Exception("Kutilmagan xatolik: $e");
    }
  }

  Future<void> completeTask({
    required int taskId,
    List<String> filePaths = const [],
    double? latitude,
    double? longitude,
  }) async {
    try {
      debugPrint("🔹 Task bajarildi deb belgilanmoqda... ID: $taskId");

      debugPrint("Task location: lat=$latitude, long=$longitude");

      final Map<String, dynamic> bodyMap = {};

      if (latitude != null && longitude != null) {
        bodyMap['location'] =
            'https://www.google.com/maps?q=$latitude,$longitude';
      }

      if (filePaths.isNotEmpty) {
        final files = <MultipartFile>[];
        for (final filePath in filePaths) {
          final fileName = filePath.replaceAll('\\', '/').split('/').last;
          files.add(
            await MultipartFile.fromFile(filePath, filename: fileName),
          );
        }
        bodyMap['answer_file'] = files;
        debugPrint("📎 ${files.length} ta fayl biriktirildi");
      }

      final formData = FormData.fromMap(bodyMap);
      debugPrint("📎 Fayl biriktirildi: $formData");

      final response = await _dio.patch('task/done/$taskId/', data: formData);

      debugPrint("🔹 Javob status code: ${response.statusCode}");
      debugPrint("🔹 Javob: ${response.data}");

      if (response.statusCode != 200 && response.statusCode != 201) {
        throw Exception('Xatolik yuz berdi: ${response.statusCode}');
      }
    } on DioException catch (e) {
      final error = e.response?.data;
      String errorMessage =
          error?['message'] ?? error?['error'] ?? "So'rov bajarilmadi";
      debugPrint("❌ DioException: $errorMessage");
      throw Exception(errorMessage);
    } catch (e) {
      debugPrint("❌ UNKNOWN ERROR: $e");
      throw Exception("Kutilmagan xatolik: $e");
    }
  }

  Future<void> cancelTask({
    required int taskId,
    required String description,
    List<String> filePaths = const [],
  }) async {
    try {
      debugPrint("рџ”№ Task bekor qilinmoqda... ID: $taskId");

      final files = <MultipartFile>[];
      for (final filePath in filePaths) {
        final fileName = filePath.replaceAll('\\', '/').split('/').last;
        files.add(await MultipartFile.fromFile(filePath, filename: fileName));
      }
      final formData = FormData.fromMap({
        if (files.isNotEmpty) 'file': files,
        'description': description,
      });
      debugPrint("рџ“Ћ Bekor qilish body tayyorlandi: $formData");

      final response = await _dio.patch(
        'task/update-status/$taskId/',
        data: formData,
        queryParameters: {'action': 'cancel'},
      );

      debugPrint("рџ”№ Javob status code: ${response.statusCode}");
      debugPrint("рџ”№ Javob: ${response.data}");

      if (response.statusCode != 200 &&
          response.statusCode != 201 &&
          response.statusCode != 204) {
        throw Exception('Xatolik yuz berdi: ${response.statusCode}');
      }
    } on DioException catch (e) {
      final error = e.response?.data;
      String errorMessage =
          error?['message'] ?? error?['error'] ?? "So'rov bajarilmadi";
      debugPrint("вќЊ DioException: $errorMessage");
      throw Exception(errorMessage);
    } catch (e) {
      debugPrint("вќЊ UNKNOWN ERROR: $e");
      throw Exception("Kutilmagan xatolik: $e");
    }
  }
}
