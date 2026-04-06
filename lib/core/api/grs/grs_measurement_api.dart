import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:m_gaz/core/models/grs/grs_detail_model/grs_detail_model.dart';
import 'package:m_gaz/core/models/grs/grs_measurement_model.dart';
import '../../models/paginated_response/paginated_response.dart';
import '../base/base_api.dart';

class GrsMeasurementDevicesApi {
  final ApiBase _base;

  const GrsMeasurementDevicesApi(this._base);

  Future<PaginatedResponse<GrsMeasurementModel>> getDocuments({
    int limit = 20,
    int offset = 0,
  }) async {
    try {
      debugPrint("🔹 Consumer Relations so'rov yuborilmoqda...");
      debugPrint("🔹 Limit: $limit, Offset: $offset");

      final response = await _base.dio.get(
        'grs-measuring-devices-documents/',
        queryParameters: {'limit': limit, 'offset': offset},
      );

      debugPrint("🔹 Javob status code: ${response.statusCode}");

      if (response.statusCode == 200) {
        return PaginatedResponse<GrsMeasurementModel>.fromJson(
          response.data,
          GrsMeasurementModel.fromJson,
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

  Future<PaginatedResponse<GrsMeasurementModel>> getNextPage(
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
        return PaginatedResponse<GrsMeasurementModel>.fromJson(
          response.data,
          GrsMeasurementModel.fromJson,
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

  Future<GrsDetailModel> getDocumentById(int id) async {
    try {
      debugPrint(
        "🔹 Consumer Relations Document ID:$id so'rov yuborilmoqda...",
      );

      final response = await _base.dio.get('grs-measuring-devices-documents/$id/');

      debugPrint("🔹 Javob status code: ${response.statusCode}");

      if (response.statusCode == 200) {
        return GrsDetailModel.fromJson(response.data);
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
