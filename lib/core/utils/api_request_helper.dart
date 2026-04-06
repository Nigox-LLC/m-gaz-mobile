import 'package:dio/dio.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../di.dart';

class ApiUtils {
  static Options get noTokenLanguageHeader => Options(
    extra: {"no_token": true},
    headers: {
      'Accept-Language': mainKey.currentState?.context.locale.languageCode,
    },
  );
}
