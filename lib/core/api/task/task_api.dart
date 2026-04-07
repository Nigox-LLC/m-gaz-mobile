import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:m_gaz/core/models/task/task_analysis.dart';
import 'package:m_gaz/core/models/task/tasks_model.dart';

import '../../models/paginated_response/paginated_response.dart';
import '../base/base_api.dart';

class TaskApi {
  final ApiBase _base;

  const TaskApi(this._base);

  Future<PaginatedResponse<TaskModel>> getTasks({
    int limit = 20,
    int offset = 0,
  }) async {
    try {
      debugPrint("🔹 Consumer Relations so'rov yuborilmoqda...");
      debugPrint("🔹 Limit: $limit, Offset: $offset");

      final response = await _base.dio.get(
        'task/list/',
        queryParameters: {'limit': limit, 'offset': offset},
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

  Future<TaskAnalysisModel> getTaskAnalysis() async {
    try {
      final response = await _base.dio.get("task/analysis");

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

      final response = await _base.dio.get(
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

      final response = await _base.dio.get('consumer-relations-documents/$id/');

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

  Future<TaskModel> completeTask({
    required int taskId,
    String? filePath,
  }) async {
    try {
      debugPrint("🔹 Task bajarildi deb belgilanmoqda... ID: $taskId");

      FormData formData;

      if (filePath != null) {
        // Fayl bilan birga yuborish
        final fileName = filePath.split('/').last;
        formData = FormData.fromMap({
          'answer_file': await MultipartFile.fromFile(
            filePath,
            filename: fileName,
          ),
        });
        debugPrint("📎 Fayl biriktirildi: $fileName");
      } else {
        // Faylsiz yuborish (agar kerak bo'lsa)
        formData = FormData.fromMap({});
      }

      final response = await _base.dio.patch(
        'task/done/$taskId/',
        data: formData,
      );

      debugPrint("🔹 Javob status code: ${response.statusCode}");

      if (response.statusCode == 200 || response.statusCode == 201) {
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
}
