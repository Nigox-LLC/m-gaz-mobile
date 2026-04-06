import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:m_gaz/core/models/global/egxu_list_model.dart';
import 'package:m_gaz/core/models/global/global_model.dart';
import '../../models/grs/grs_detail_model/grs_gas_equipment.dart';
import '../../models/paginated_response/paginated_response.dart';
import '../base/base_api.dart';

class GlobalApi {
  final ApiBase _base;

  const GlobalApi(this._base);

  Future<List<GlobalModel>> getRegions() async {
    try {
      debugPrint("🔹 Regions so'rov yuborilmoqda...");

      final response = await _base.dio.get(
        'directory/region-district/regions/',
      );

      debugPrint("🔹 Regions javob status code: ${response.statusCode}");

      if (response.statusCode == 200) {
        return (response.data as List)
            .map((item) => GlobalModel.fromJson(item))
            .toList();
      } else {
        throw Exception('Xatolik yuz berdi: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint("❌ Regions xatolik: $e");
      rethrow;
    }
  }

  Future<List<GlobalModel>> getDistricts(int regionId) async {
    try {
      debugPrint("🔹 Districts so'rov yuborilmoqda... Region: $regionId");

      final response = await _base.dio.get(
        'directory/region-district/districts/',
        queryParameters: {'region': regionId},
      );

      debugPrint("🔹 Districts javob status code: ${response.statusCode}");

      if (response.statusCode == 200) {
        return (response.data as List)
            .map((item) => GlobalModel.fromJson(item))
            .toList();
      } else {
        throw Exception('Xatolik yuz berdi: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint("❌ Districts xatolik: $e");
      rethrow;
    }
  }

  Future<PaginatedResponse<GlobalModel>> getEmployees({
    required int regionId,
    required int districtId,
  }) async {
    try {
      debugPrint("🔹 Consumer Relations so'rov yuborilmoqda...");

      final response = await _base.dio.get(
        'directory/employees/all-list/',
        queryParameters: {'region': regionId, 'district': districtId},
      );

      debugPrint("🔹 Javob status code: ${response.statusCode}");

      if (response.statusCode == 200) {
        return PaginatedResponse<GlobalModel>.fromJson(
          response.data,
          GlobalModel.fromJson,
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

  Future<List<GlobalModel>> getConsumers({
    required int regionId,
    required int districtId,
  }) async {
    try {
      debugPrint(
        "🔹 Consumers so'rov yuborilmoqda... Region: $regionId, District: $districtId",
      );

      final response = await _base.dio.get(
        'directory/consumers/all-list/',
        queryParameters: {'region': regionId, 'district': districtId},
      );

      debugPrint("🔹 Consumers javob status code: ${response.statusCode}");

      if (response.statusCode == 200) {
        return (response.data as List)
            .map((item) => GlobalModel.fromJson(item))
            .toList();
      } else {
        throw Exception('Xatolik yuz berdi: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint("❌ Consumers xatolik: $e");
      rethrow;
    }
  }

  Future<List<EgxuListModel>> getEgxuTypes() async {
    try {
      debugPrint("🔹 Egxu Types so'rov yuborilmoqda...");

      final response = await _base.dio.get('directory/type-egxu/all-list/');

      debugPrint("🔹 Egxu Types javob status code: ${response.statusCode}");

      if (response.statusCode == 200) {
        return (response.data as List)
            .map((item) => EgxuListModel.fromJson(item))
            .toList();
      } else {
        throw Exception('Xatolik yuz berdi: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint("❌ Egxu Types xatolik: $e");
      rethrow;
    }
  }

  Future<List<GlobalModel>> getActivityTypes() async {
    try {
      debugPrint("🔹 Activity Types so'rov yuborilmoqda...");

      final response = await _base.dio.get(
        'directory/directory/all-list/',
        queryParameters: {'entity_type': 'Faoliyatturi'},
      );

      debugPrint("🔹 Activity Types javob status code: ${response.statusCode}");

      if (response.statusCode == 200) {
        return (response.data as List)
            .map((item) => GlobalModel.fromJson(item))
            .toList();
      } else {
        throw Exception('Xatolik yuz berdi: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint("❌ Activity Types xatolik: $e");
      rethrow;
    }
  }

  Future<List<GlobalModel>> getGasNetworks({
    required int regionId,
    required int districtId,
  }) async {
    try {
      debugPrint(
        "🔹 Gas Networks so'rov yuborilmoqda... Region: $regionId, District: $districtId",
      );

      final response = await _base.dio.get(
        'directory/gas-networks/all-list/',
        queryParameters: {'region': regionId, 'district': districtId},
      );

      debugPrint("🔹 Gas Networks javob status code: ${response.statusCode}");

      if (response.statusCode == 200) {
        return (response.data as List)
            .map((item) => GlobalModel.fromJson(item))
            .toList();
      } else {
        throw Exception('Xatolik yuz berdi: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint("❌ Gas Networks xatolik: $e");
      rethrow;
    }
  }

  Future<List<GlobalModel>> getEgxuConnectionPoints() async {
    try {
      debugPrint("🔹 Egxu Connection Points so'rov yuborilmoqda...");

      final response = await _base.dio.get(
        'directory/directory/all-list/',
        queryParameters: {'entity_type': 'EGXUulanishnuqtasi'},
      );

      debugPrint(
        "🔹 Egxu Connection Points javob status code: ${response.statusCode}",
      );

      if (response.statusCode == 200) {
        return (response.data as List)
            .map((item) => GlobalModel.fromJson(item))
            .toList();
      } else {
        throw Exception('Xatolik yuz berdi: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint("❌ Egxu Connection Points xatolik: $e");
      rethrow;
    }
  }

  Future<List<GlobalModel>> getDirections() async {
    try {
      debugPrint("🔹 Directions so'rov yuborilmoqda...");

      final response = await _base.dio.get(
        'directory/directory/all-list/',
        queryParameters: {'entity_type': 'Yonalish'},
      );

      debugPrint("🔹 Directions javob status code: ${response.statusCode}");

      if (response.statusCode == 200) {
        return (response.data as List)
            .map((item) => GlobalModel.fromJson(item))
            .toList();
      } else {
        throw Exception('Xatolik yuz berdi: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint("❌ Directions xatolik: $e");
      rethrow;
    }
  }

  Future<List<GlobalModel>> getMinistries() async {
    try {
      debugPrint("🔹 Ministries so'rov yuborilmoqda...");

      final response = await _base.dio.get(
        'directory/directory/all-list/',
        queryParameters: {'entity_type': 'Vazirliklar'},
      );

      debugPrint("🔹 Ministries javob status code: ${response.statusCode}");

      if (response.statusCode == 200) {
        return (response.data as List)
            .map((item) => GlobalModel.fromJson(item))
            .toList();
      } else {
        throw Exception('Xatolik yuz berdi: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint("❌ Ministries xatolik: $e");
      rethrow;
    }
  }

  Future<List<GlobalModel>> getGrsList({required int regionId}) async {
    try {
      debugPrint("🔹 GRS List so'rov yuborilmoqda... Region: $regionId");

      final response = await _base.dio.get(
        'directory/gtsh/all-list/',
        queryParameters: {'region': regionId},
      );

      debugPrint("🔹 GRS List javob status code: ${response.statusCode}");

      if (response.statusCode == 200) {
        return (response.data as List)
            .map((item) => GlobalModel.fromJson(item))
            .toList();
      } else {
        throw Exception('Xatolik yuz berdi: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint("❌ GRS List xatolik: $e");
      rethrow;
    }
  }

  Future<List<GlobalModel>> getIndustrialCollectors({
    required int regionId,
    required int grsId,
  }) async {
    try {
      debugPrint(
        "🔹 Industrial Collectors so'rov yuborilmoqda... Region: $regionId, GRS: $grsId",
      );

      final response = await _base.dio.get(
        'directory/industrial-collectors/all-list/',
        queryParameters: {'region': regionId, 'gtsh': grsId},
      );

      debugPrint(
        "🔹 Industrial Collectors javob status code: ${response.statusCode}",
      );

      if (response.statusCode == 200) {
        return (response.data as List)
            .map((item) => GlobalModel.fromJson(item))
            .toList();
      } else {
        throw Exception('Xatolik yuz berdi: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint("❌ Industrial Collectors xatolik: $e");
      rethrow;
    }
  }

  Future<List<GlobalModel>> getMeasuringDevices({
    required int regionId,
    required int grsId,
  }) async {
    try {
      debugPrint(
        "🔹 Measuring Devices so'rov yuborilmoqda... Region: $regionId, GRS: $grsId",
      );

      final response = await _base.dio.get(
        'directory/technological-measuring-devices/all-list/',
        queryParameters: {'region': regionId, 'gtsh': grsId},
      );

      debugPrint(
        "🔹 Measuring Devices javob status code: ${response.statusCode}",
      );

      if (response.statusCode == 200) {
        return (response.data as List)
            .map((item) => GlobalModel.fromJson(item))
            .toList();
      } else {
        throw Exception('Xatolik yuz berdi: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint("❌ Measuring Devices xatolik: $e");
      rethrow;
    }
  }

  Future<List<GlobalModel>> getGrpTypes() async {
    try {
      debugPrint("🔹 GRP Types so'rov yuborilmoqda...");

      final response = await _base.dio.get(
        'directory/directory/all-list/',
        queryParameters: {'entity_type': 'GRPturlari'},
      );

      debugPrint("🔹 GRP Types javob status code: ${response.statusCode}");

      if (response.statusCode == 200) {
        return (response.data as List)
            .map((item) => GlobalModel.fromJson(item))
            .toList();
      } else {
        throw Exception('Xatolik yuz berdi: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint("❌ GRP Types xatolik: $e");
      rethrow;
    }
  }

  Future<List<GlobalModel>> getNeighborhoods({
    required int regionId,
    required int districtId,
  }) async {
    try {
      debugPrint(
        "🔹 Neighborhoods so'rov yuborilmoqda... Region: $regionId, District: $districtId",
      );

      final response = await _base.dio.get(
        'directory/neighborhood/all-list/',
        queryParameters: {'region': regionId, 'district': districtId},
      );

      debugPrint("🔹 Neighborhoods javob status code: ${response.statusCode}");

      if (response.statusCode == 200) {
        return (response.data as List)
            .map((item) => GlobalModel.fromJson(item))
            .toList();
      } else {
        throw Exception('Xatolik yuz berdi: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint("❌ Neighborhoods xatolik: $e");
      rethrow;
    }
  }

  Future<List<GlobalModel>> getStampInstallationPoints() async {
    try {
      debugPrint("🔹 GRP Types so'rov yuborilmoqda...");

      final response = await _base.dio.get(
        'directory/directory/all-list/',
        queryParameters: {'entity_type': 'Tamgaornatishnuqtalari'},
      );

      debugPrint("🔹 Tamga ornatish nuqtalari Types javob status code: ${response.statusCode}");

      if (response.statusCode == 200) {
        return (response.data as List)
            .map((item) => GlobalModel.fromJson(item))
            .toList();
      } else {
        throw Exception('Xatolik yuz berdi: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint("❌ GRP Types xatolik: $e");
      rethrow;
    }
  }
  Future<PaginatedResponse<GrsGasEquipment>> getGasEquipment({
    int limit = 10,
    int offset = 0,
  }) async {
    try {
      debugPrint("🔹 Consumer Relations so'rov yuborilmoqda...");
      debugPrint("🔹 Limit: $limit, Offset: $offset");

      final response = await _base.dio.get(
        "directory/gas-equipment",
        queryParameters: {'limit': limit, 'offset': offset},
      );

      debugPrint("🔹 Javob status code: ${response.statusCode}");

      if (response.statusCode == 200) {
        return PaginatedResponse<GrsGasEquipment>.fromJson(
          response.data,
          GrsGasEquipment.fromJson,
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
  Future<PaginatedResponse<GrsGasEquipment>> getNextPage(
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
        return PaginatedResponse<GrsGasEquipment>.fromJson(
          response.data,
          GrsGasEquipment.fromJson,
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

}
