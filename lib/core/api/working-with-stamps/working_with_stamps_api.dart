import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:m_gaz/core/models/working-with-stamps/working_with_stamps.dart';
import '../../models/paginated_response/paginated_response.dart';
import '../../models/working-with-stamps/detail/workign_with_stamp_detail.dart';
import '../base/base_api.dart';

class WorkingWithStampsApi {
  final ApiBase _base;

  const WorkingWithStampsApi(this._base);

  Future<PaginatedResponse<WorkingWithStampsModel>> getDocuments({
    int limit = 200,
    int offset = 0,
  }) async {
    try {
      debugPrint("🔹 Consumer Relations so'rov yuborilmoqda...");
      debugPrint("🔹 Limit: $limit, Offset: $offset");

      final response = await _base.dio.get(
        'consumer-relations-documents/',
        queryParameters: {'limit': limit, 'offset': offset},
      );

      debugPrint("🔹 Javob status code: ${response.statusCode}");

      if (response.statusCode == 200) {
        return PaginatedResponse<WorkingWithStampsModel>.fromJson(
          response.data,
          WorkingWithStampsModel.fromJson,
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

  // Keyingi sahifani "next" URL orqali olish
  Future<PaginatedResponse<WorkingWithStampsModel>> getNextPage(
    String url,
  ) async {
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
        return PaginatedResponse<WorkingWithStampsModel>.fromJson(
          response.data,
          WorkingWithStampsModel.fromJson,
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

  Future<WorkingWithStampsDetailModel> getDocumentById(int id) async {
    try {
      final response = await _base.dio.get(
        'consumer-relations-documents/real-detail/$id/',
      );

      if (response.statusCode == 200) {
        if (response.data is List) {
          // agar list bo'lsa, birinchi elementni olish
          final listData = response.data as List<dynamic>;
          if (listData.isNotEmpty) {
            return WorkingWithStampsDetailModel.fromJson(listData[0]);
          } else {
            throw Exception("Ma'lumot topilmadi");
          }
        } else if (response.data is Map<String, dynamic>) {
          return WorkingWithStampsDetailModel.fromJson(response.data);
        } else {
          throw Exception(
            "Notanish ma'lumot turi: ${response.data.runtimeType}",
          );
        }
      } else {
        throw Exception('Xatolik yuz berdi: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint("❌ UNKNOWN ERROR: $e");
      throw Exception("Kutilmagan xatolik: $e");
    }
  }
}
