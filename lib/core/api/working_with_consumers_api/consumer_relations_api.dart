import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:m_gaz/core/models/working_with_consumers_document/working_with_consumers_document_detail.dart';
import '../../models/paginated_response/paginated_response.dart';
import '../../models/working_with_consumers_document/consumer_factory_exist_model.dart';
import '../../models/working_with_consumers_document/consumer_file_models.dart';
import '../../models/working_with_consumers_document/working_with_consumer_create_get/consumer_create_model.dart';
import '../../models/working_with_consumers_document/working_with_consumers_list.dart';
import '../base/base_api.dart';

class ConsumerRelationsApi {
  final ApiBase _base;

  const ConsumerRelationsApi(this._base);

  Future<PaginatedResponse<WorkingWithConsumersList>> getDocuments({
    int limit = 20,
    int offset = 0,
    String? search,
    int? region,
    int? district,
  }) async {
    try {
      debugPrint("🔹 Consumer Relations so'rov yuborilmoqda...");
      debugPrint(
        "🔹 Limit: $limit, Offset: $offset, search: $search, region: $region, district: $district",
      );

      final query = <String, dynamic>{'limit': limit, 'offset': offset};
      if (search != null && search.trim().isNotEmpty) {
        query['search'] = search.trim();
      }
      if (region != null) query['region'] = region;
      if (district != null) query['district'] = district;

      final response = await _base.dio.get(
        'consumer-relations-documents/',
        queryParameters: query,
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

  Future<WorkingWithConsumersDetailModel> patchDocument({
    required int id,
    required WorkingWithConsumersDetailModel document,
  }) async {
    try {
      final response = await _base.dio.patch(
        'consumer-relations-documents/$id/',
        data: buildConsumerDocumentPatchPayload(document),
      );

      if (response.statusCode == 200) {
        return WorkingWithConsumersDetailModel.fromJson(response.data);
      }
      throw Exception('Xatolik yuz berdi: ${response.statusCode}');
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

  Future<ConsumerFactoryExistResponse> checkFactoryExist({
    required String factory1,
    required String factory2,
  }) async {
    // Debug print uchun
    debugPrint(
      "🔹 Tekshirilayotgan fabrikalar: factory1=$factory1, factory2=$factory2",
    );

    final response = await _base.dio.get(
      'consumer-relations-documents/factory-exist/',
      queryParameters: {
        'factory': [factory1],
      },
    );

    // Javobni ham tekshirish uchun debugPrint
    debugPrint("🔹 Response status: ${response.statusCode}");
    debugPrint("🔹 Response data: ${response.data}");

    if (response.statusCode == 200) {
      return ConsumerFactoryExistResponse.fromJson(response.data);
    } else {
      throw Exception('Factory tekshirishda xatolik');
    }
  }

  // ============= Iste'molchi fayllari (Loyiha/Shartnoma) =============

  /// GET /api/directory/consumers/files/?consumer_id=&file_type=
  Future<List<ConsumerFile>> getConsumerFiles({
    required int consumerId,
    String? fileType,
  }) async {
    try {
      final query = <String, dynamic>{'consumer_id': consumerId};
      if (fileType != null && fileType.isNotEmpty) {
        query['file_type'] = fileType;
      }

      final response = await _base.dio.get(
        'directory/consumers/files/',
        queryParameters: query,
      );

      if (response.statusCode == 200) {
        final data = response.data;
        final list = data is List ? data : (data?['consumer_files'] ?? []);
        return (list as List)
            .map((e) => ConsumerFile.fromJson(e as Map<String, dynamic>))
            .toList();
      }
      throw Exception('Xatolik yuz berdi: ${response.statusCode}');
    } on DioException catch (e) {
      throw Exception(_dioMessage(e));
    } catch (e) {
      debugPrint("❌ getConsumerFiles: $e");
      throw Exception("Kutilmagan xatolik: $e");
    }
  }

  /// POST /api/directory/consumers/files/ (multipart)
  Future<void> uploadConsumerFiles({
    required int consumerId,
    List<String> technicalPaths = const [],
    List<String> contractPaths = const [],
  }) async {
    if (technicalPaths.isEmpty && contractPaths.isEmpty) return;
    try {
      final formData = FormData();
      formData.fields.add(MapEntry('consumer_id', consumerId.toString()));
      for (final path in technicalPaths) {
        formData.files.add(
          MapEntry('technical_documents', await MultipartFile.fromFile(path)),
        );
      }
      for (final path in contractPaths) {
        formData.files.add(
          MapEntry('contracts', await MultipartFile.fromFile(path)),
        );
      }

      final response = await _base.dio.post(
        'directory/consumers/files/',
        data: formData,
      );

      if (response.statusCode != 200 && response.statusCode != 201) {
        throw Exception('Xatolik yuz berdi: ${response.statusCode}');
      }
    } on DioException catch (e) {
      throw Exception(_dioMessage(e));
    } catch (e) {
      debugPrint("❌ uploadConsumerFiles: $e");
      throw Exception("Kutilmagan xatolik: $e");
    }
  }

  // ============= EGHU sertifikatlari =============

  /// GET /api/consumer-relations-documents/egxu/certificates/?egxu_id=
  Future<List<EgxuCertificate>> getEgxuCertificates({
    required int egxuId,
  }) async {
    try {
      final response = await _base.dio.get(
        'consumer-relations-documents/egxu/certificates/',
        queryParameters: {'egxu_id': egxuId},
      );

      if (response.statusCode == 200) {
        final data = response.data;
        final list = data is List ? data : (data?['certificate_files'] ?? []);
        return (list as List)
            .map((e) => EgxuCertificate.fromJson(e as Map<String, dynamic>))
            .toList();
      }
      throw Exception('Xatolik yuz berdi: ${response.statusCode}');
    } on DioException catch (e) {
      throw Exception(_dioMessage(e));
    } catch (e) {
      debugPrint("❌ getEgxuCertificates: $e");
      throw Exception("Kutilmagan xatolik: $e");
    }
  }

  /// POST /api/consumer-relations-documents/egxu/certificates/ (multipart)
  Future<void> uploadEgxuCertificates({
    required int egxuId,
    required List<String> paths,
  }) async {
    if (paths.isEmpty) return;
    try {
      final formData = FormData();
      formData.fields.add(MapEntry('egxu_id', egxuId.toString()));
      for (final path in paths) {
        formData.files.add(
          MapEntry('certificate_files', await MultipartFile.fromFile(path)),
        );
      }

      final response = await _base.dio.post(
        'consumer-relations-documents/egxu/certificates/',
        data: formData,
      );

      if (response.statusCode != 200 && response.statusCode != 201) {
        throw Exception('Xatolik yuz berdi: ${response.statusCode}');
      }
    } on DioException catch (e) {
      throw Exception(_dioMessage(e));
    } catch (e) {
      debugPrint("❌ uploadEgxuCertificates: $e");
      throw Exception("Kutilmagan xatolik: $e");
    }
  }

  String _dioMessage(DioException e) {
    final error = e.response?.data;
    if (error is Map) {
      return error['message'] ?? error['error'] ?? "So'rov bajarilmadi";
    }
    return "So'rov bajarilmadi";
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

@visibleForTesting
Map<String, dynamic> buildConsumerDocumentPatchPayload(
  WorkingWithConsumersDetailModel document,
) {
  final payload = Map<String, dynamic>.from(document.toJson());

  // Backend PATCH expects top-level relations as PK values, not GET objects.
  payload['region'] = document.region?.id;
  payload['district'] = document.district?.id;
  payload['employee'] = document.employee?.id;
  payload['consumers'] = document.consumers?.id;

  return payload;
}
