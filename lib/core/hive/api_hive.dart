import 'dart:convert';
import 'package:flutter/material.dart';
import '../models/user/token_model.dart';
import 'hive_base.dart';

class ApiHive {
  final HiveBase _base;

  ApiHive(this._base);

  String get(String key) => _base.apiBox.get(key) ?? "";

  Future<void> put(String key, String value) async =>
      await _base.apiBox.put(key, value);

  TokenModel get token {
    final raw = _base.apiBox.get("token", defaultValue: "{}");
    final json = jsonDecode(raw);
    return TokenModel.fromJson(json);
  }

  String get refreshToken =>
      _base.apiBox.get("refresh_token", defaultValue: "") ?? "";

  String get accessToken =>
      _base.apiBox.get("access_token", defaultValue: "") ?? "";

  int? get employeeId {
    final raw = _base.apiBox.get("employee_id");
    if (raw is int) return raw;
    if (raw is String) return int.tryParse(raw);
    return null;
  }

  Future<void> putEmployeeId(int value) async {
    await _base.apiBox.put("employee_id", value);
  }

  Future<void> putToken(TokenModel value) async {
    debugPrint("Token saqlanmoqda: ${value.access} / ${value.refresh}");

    if (value.access.isNotEmpty) {
      await _base.apiBox.put("access_token", value.access);
    }

    if (value.refresh.isNotEmpty) {
      await _base.apiBox.put("refresh_token", value.refresh);
    }

    await _base.apiBox.put("token", jsonEncode(value.toJson()));
  }

  Future<void> clear() async => await _base.apiBox.clear();

  // ⭐⭐⭐ YANGI QO‘SHILGAN QISM ⭐⭐⭐

  String get lastAgreementDate =>
      _base.apiBox.get("last_agreement_date", defaultValue: "") ?? "";

  // SYNC SETTER — unawaited Future ichga tashlanadi
  set lastAgreementDate(String date) {
    // put qaytaradigan Future-ni kutmaymiz — bu oson va tez ishlaydi
    _base.apiBox.put("last_agreement_date", date);
  }

  // yoki agar siz async versiyasini ham saqlamoqchi bo'lsangiz:
  Future<void> setLastAgreementDate(String date) async {
    await _base.apiBox.put("last_agreement_date", date);
  }
}
