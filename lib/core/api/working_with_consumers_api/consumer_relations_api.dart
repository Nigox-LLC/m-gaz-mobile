import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:m_gaz/core/models/working_with_consumers_document/working_with_consumers_document_detail.dart';
import '../../models/paginated_response/paginated_response.dart';
import '../../models/working_with_consumers_document/consumer_factory_exist_model.dart';
import '../../models/working_with_consumers_document/working_with_consumer_create_get/consumer_create_model.dart';
import '../../models/working_with_consumers_document/working_with_consumers_list.dart';
import '../base/base_api.dart';

class ConsumerRelationsApi {
  final ApiBase _base;

  const ConsumerRelationsApi(this._base);

  Future<PaginatedResponse<WorkingWithConsumersList>> getDocuments({
    int limit = 20,
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
        return PaginatedResponse<WorkingWithConsumersList>.fromJson(
          response.data,
          WorkingWithConsumersList.fromJson,
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
  Future<PaginatedResponse<WorkingWithConsumersList>> getNextPage(
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
        return PaginatedResponse<WorkingWithConsumersList>.fromJson(
          response.data,
          WorkingWithConsumersList.fromJson,
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

  Future<WorkingWithConsumersDetailModel> getDocumentById(int id) async {
    try {
      debugPrint(
        "🔹 Consumer Relations Document ID:$id so'rov yuborilmoqda...",
      );

      final response = await _base.dio.get('consumer-relations-documents/$id/');

      debugPrint("🔹 Javob status code: ${response.statusCode}");

      if (response.statusCode == 200) {
        return WorkingWithConsumersDetailModel.fromJson(response.data);
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

  Future<ConsumerFactoryExistResponse> checkFactoryExist({
    required String factory1,
    required String factory2,
  }) async {
    final response = await _base.dio.get(
      'consumer-relations-documents/factory-exist/',
      queryParameters: {
        'factory': [factory1, factory2],
      },
    );

    if (response.statusCode == 200) {
      return ConsumerFactoryExistResponse.fromJson(response.data);
    } else {
      throw Exception('Factory tekshirishda xatolik');
    }
  }

  Future<void> createEgxu(ConsumerCreateModel model) async {
    try {
      debugPrint("🔹 EGXU create so'rov yuborilmoqda...");
      debugPrint("🔹 Data: ${model.toJson()}");

      final response = await _base.dio.post(
        'consumer-relations-documents/',
        data: model.toJson(),
      );

      debugPrint("🔹 EGXU create javob status code: ${response.statusCode}");

      if (response.statusCode != 201 && response.statusCode != 200) {
        throw Exception('Xatolik yuz berdi: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint("❌ EGXU create xatolik: $e");
      rethrow;
    }
  }
}
