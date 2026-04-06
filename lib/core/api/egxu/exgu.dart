// import 'package:dio/dio.dart';
// import 'package:flutter/cupertino.dart';
// import '../../models/egxu/egxu.dart';
// import '../../models/egxu/egxu_detail/working_with_egxu_detail.dart';
// import '../../models/paginated_response/paginated_response.dart';
// import '../base/base_api.dart';
//
// class EGXUApi {
//   final ApiBase _base;
//
//   const EGXUApi(this._base);
//
//   Future<PaginatedResponse<EGXUDocument>> getDocuments({
//     int limit = 20,
//     int offset = 0,
//   }) async {
//     try {
//       debugPrint("🔹 Consumer Relations so'rov yuborilmoqda...");
//       debugPrint("🔹 Limit: $limit, Offset: $offset");
//
//       final response = await _base.dio.get(
//         "working-with-egxu/",
//         queryParameters: {'limit': limit, 'offset': offset},
//       );
//
//       debugPrint("🔹 Javob status code: ${response.statusCode}");
//
//       if (response.statusCode == 200) {
//         return PaginatedResponse<EGXUDocument>.fromJson(
//           response.data,
//           EGXUDocument.fromJson,
//         );
//       } else {
//         throw Exception('Xatolik yuz berdi: ${response.statusCode}');
//       }
//     } on DioException catch (e) {
//       final error = e.response?.data;
//       String errorMessage =
//           error?['message'] ?? error?['error'] ?? "So'rov bajarilmadi";
//       debugPrint("❌ DioException: $errorMessage");
//       throw Exception(errorMessage);
//     } catch (e) {
//       debugPrint("❌ UNKNOWN ERROR: $e");
//       throw Exception("Kutilmagan xatolik: $e");
//     }
//   }
//
//   // Keyingi sahifani "next" URL orqali olish
//   Future<PaginatedResponse<EGXUDocument>> getNextPage(String url) async {
//     try {
//       debugPrint("🔹 Keyingi sahifa so'rov yuborilmoqda...");
//       debugPrint("🔹 URL: $url");
//
//       // URL'ni parsing qilish va endpoint + queryParams ajratish
//       final uri = Uri.parse(url);
//       final path = uri.path; // /api/consumer-relations-documents/
//       final queryParameters = uri.queryParameters; // {limit: 20, offset: 20}
//
//       // /api/ prefiksini olib tashlash, chunki baseUrl allaqachon o'rnatilgan
//       final endpoint = path.replaceFirst('/api/', '');
//
//       final response = await _base.dio.get(
//         endpoint,
//         queryParameters: queryParameters,
//       );
//
//       debugPrint("🔹 Javob status code: ${response.statusCode}");
//
//       if (response.statusCode == 200) {
//         return PaginatedResponse<EGXUDocument>.fromJson(
//           response.data,
//           EGXUDocument.fromJson,
//         );
//       } else {
//         throw Exception('Xatolik yuz berdi: ${response.statusCode}');
//       }
//     } on DioException catch (e) {
//       final error = e.response?.data;
//       String errorMessage =
//           error?['message'] ?? error?['error'] ?? "So'rov bajarilmadi";
//       debugPrint("❌ DioException: $errorMessage");
//       throw Exception(errorMessage);
//     } catch (e) {
//       debugPrint("❌ UNKNOWN ERROR: $e");
//       throw Exception("Kutilmagan xatolik: $e");
//     }
//   }
//
//   Future<WorkingWithEgxuDetail> getDocumentById(int id) async {
//     try {
//       debugPrint(
//         "🔹 Consumer Relations Document ID:$id so'rov yuborilmoqda...",
//       );
//
//       final response = await _base.dio.get('working-with-egxu//$id/');
//
//       debugPrint("🔹 Javob status code: ${response.statusCode}");
//
//       if (response.statusCode == 200) {
//         return WorkingWithEgxuDetail.fromJson(response.data);
//       } else {
//         throw Exception('Xatolik yuz berdi: ${response.statusCode}');
//       }
//     } on DioException catch (e) {
//       final error = e.response?.data;
//       String errorMessage =
//           error?['message'] ?? error?['error'] ?? "So'rov bajarilmadi";
//       debugPrint("❌ DioException: $errorMessage");
//       throw Exception(errorMessage);
//     } catch (e) {
//       debugPrint("❌ UNKNOWN ERROR: $e");
//       throw Exception("Kutilmagan xatolik: $e");
//     }
//   }
//
//
// }
