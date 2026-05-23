import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';

import '../../../di.dart';
import '../../hive/api_hive.dart';
import '../../models/user/token_model.dart';
import '../../utils/locationService/location_service.dart';

class ApiBase {
  final Dio _dio;
  final ApiHive _hive;
  bool _retryAttempted = false;

  static const baseUrl = "https://backend.m-gaz.uz/api/";

  ApiBase(this._dio, this._hive) {
    _init();
  }

  void _init() {
    _dio.options.baseUrl = baseUrl;

    _dio.interceptors.add(
      InterceptorsWrapper(
        // REQUEST
        onRequest: (options, handler) async {
          final accessToken = _hive.accessToken;

          if (options.extra['no_token'] != true && accessToken.isNotEmpty) {
            options.headers["Authorization"] = "Bearer $accessToken";
            options.headers["Accept-Language"] =
                mainKey.currentContext?.locale.languageCode ?? "uz";
          }
          return handler.next(options);
        },

        // ERROR
        onError: (error, handler) async {
          debugPrint(
            "*** ON_ERROR ***\n"
            "URL: ${error.response?.realUri}\n"
            "StatusCode: ${error.response?.statusCode}\n"
            "Message: ${error.message}\n"
            "*********************",
          );

          // 🔑 401 → Token yaroqsiz → refresh qilish
          if (error.response?.statusCode == 401 &&
              !_retryAttempted &&
              error.requestOptions.extra['no_token'] != true) {
            _retryAttempted = true;

            final refreshed = await _refreshToken();

            if (refreshed) {
              final accessToken = _hive.accessToken;
              final opts = error.requestOptions;

              opts.headers["Authorization"] = "Bearer $accessToken";

              try {
                final retryResponse = await _dio.fetch(opts);
                return handler.resolve(retryResponse);
              } catch (e) {
                debugPrint("Retry after refresh error: $e");
              }
            } else {
              await DailyRouteLocationService().stop();
              await _hive.clear();
              debugPrint("❌ Token yaroqsiz, logout qilinadi.");
              // logout logikasini shu yerda chaqirishingiz mumkin
            }
          }

          // 🔑 403 → Permission yo‘q
          if (error.response?.statusCode == 403) {
            debugPrint("🚫 Permission denied (403)");

            // UI layer bilan aloqa qilish uchun global handler ishlatish kerak
            // Masalan, event yuborish yoki SnackBar chiqarish
            _showPermissionDeniedWidget();
          }

          // 🔑 500 → Server xatoligi
          if (error.response?.statusCode == 500) {
            debugPrint("💥 Server error (500)");
            // Istasangiz global error widget yoki dialog chiqaring
          }

          return handler.next(error);
        },
      ),
    );
  }

  Future<bool> _refreshToken() async {
    final refresh = _hive.refreshToken;
    if (refresh.isEmpty) return false;

    try {
      final response = await _dio.post(
        "user/token/refresh/",
        data: {"refresh": refresh},
        options: Options(
          headers: {"Content-Type": "application/json"},
          extra: {"no_token": true}, // interceptor token qo‘shmaydi
        ),
      );

      final model = TokenModel.fromJson(response.data);
      await _hive.putToken(model);
      debugPrint("✅ Token yangilandi: ${model.access}");
      _retryAttempted = false;
      return true;
    } catch (e) {
      debugPrint("❌ Token refresh error: $e");
      return false;
    }
  }

  // 🔔 403 uchun global widget ko‘rsatish
  void _showPermissionDeniedWidget() {
    final context = mainKey.currentContext;
    if (context == null) return;

    // Widget _buildForbiddenWidget() {
    //   return Center(
    //     child: Padding(
    //       padding: const EdgeInsets.all(24.0),
    //       child: Column(
    //         mainAxisAlignment: MainAxisAlignment.center,
    //         children: [
    //           Container(
    //             width: 120,
    //             height: 120,
    //             decoration: const BoxDecoration(
    //               color: Colors.red,
    //               shape: BoxShape.circle,
    //             ),
    //             child: const Icon(
    //               Icons.lock,
    //               size: 60,
    //               color: Colors.white,
    //             ),
    //           ),
    //           const SizedBox(height: 24),
    //           const Text(
    //             'Ruxsat yo\'q (403)',
    //             style: TextStyle(
    //               fontSize: 24,
    //               fontWeight: FontWeight.bold,
    //               color: Colors.red,
    //             ),
    //             textAlign: TextAlign.center,
    //           ),
    //           const SizedBox(height: 12),
    //           const Text(
    //             'Sizda ushbu bo\'limga kirish huquqi yo\'q.\nAdmin bilan bog\'laning yoki boshqa hisob bilan kiring.',
    //             style: TextStyle(fontSize: 16, color: Colors.grey),
    //             textAlign: TextAlign.center,
    //           ),
    //           const SizedBox(height: 32),
    //           Row(
    //             mainAxisAlignment: MainAxisAlignment.spaceEvenly,
    //             children: [
    //               ElevatedButton.icon(
    //                 onPressed: () {
    //                   // Admin bilan bog'lanish yoki support
    //                   // _showContactSupportDialog();
    //                 },
    //                 style: ElevatedButton.styleFrom(
    //                   backgroundColor: Colors.orange,
    //                   foregroundColor: Colors.white,
    //                 ),
    //                 icon: const Icon(Icons.support_agent),
    //                 label: const Text('Yordam'),
    //               ),
    //               ElevatedButton.icon(
    //                 onPressed: (){},
    //                 style: ElevatedButton.styleFrom(
    //                   backgroundColor: Colors.blue,
    //                   foregroundColor: Colors.white,
    //                 ),
    //                 icon: const Icon(Icons.refresh),
    //                 label: const Text('Qayta urinish'),
    //               ),
    //             ],
    //           ),
    //         ],
    //       ),
    //     ),
    //   );
    // }
  }

  Dio get dio => _dio;

  ApiHive get hive => _hive;
}
