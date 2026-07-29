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

  bool get hasStoredSession =>
      accessToken.isNotEmpty && refreshToken.isNotEmpty;

  int? get employeeId {
    final value = _base.apiBox.get("employee_id");
    if (value is int) return value;
    if (value is String) return int.tryParse(value);
    return null;
  }

  Future<void> putToken(TokenModel value) async {
    debugPrint("Token saqlanmoqda: ${value.access} / ${value.refresh}");

    if (value.access.isNotEmpty) {
      await _base.apiBox.put("access_token", value.access);
    }

    if (value.refresh.isNotEmpty) {
      await _base.apiBox.put("refresh_token", value.refresh);
    }

    if (value.employeeId != null) {
      await saveEmployeeId(value.employeeId!);
    }

    await _base.apiBox.put("token", jsonEncode(value.toJson()));
  }

  Future<void> saveEmployeeId(int employeeId) async {
    await _base.apiBox.put("employee_id", employeeId);
  }

  Future<void> clear() async {
    // Saqlangan username logout/token tozalashda yo‘qolmasin — prefill uchun kerak.
    final username = savedUsername;
    await _base.apiBox.clear();
    if (username.isNotEmpty) {
      await _base.apiBox.put("saved_username", username);
    }
  }

  /// Hard wipe — clears the entire box including the saved username. Used on
  /// explicit logout when no local state should survive.
  Future<void> clearAll() async => await _base.apiBox.clear();

  // ⭐⭐⭐ YANGI QO‘SHILGAN QISM ⭐⭐⭐

  String get savedUsername =>
      _base.apiBox.get("saved_username", defaultValue: "") ?? "";

  Future<void> setSavedUsername(String value) async =>
      await _base.apiBox.put("saved_username", value);

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

  // Ilova oxirgi marta faol bo'lgan (orqa fonga o'tgan) vaqt — epoch millis.
  // Splash va lifecycle 5 daqiqalik sessiya oynasini shu qiymat bilan hisoblaydi.
  int get lastActiveMillis {
    final value = _base.apiBox.get("last_active_millis");
    if (value is int) return value;
    if (value is String) return int.tryParse(value) ?? 0;
    return 0;
  }

  Future<void> setLastActiveNow() async => await _base.apiBox.put(
    "last_active_millis",
    DateTime.now().millisecondsSinceEpoch,
  );

  // Foydalanuvchi kamera/face-verification bo'limidan chiqib ketsa — qaytganda
  // 30 soniyalik oynani kutmasdan darhol login majburlanishi kerak. Bu bayroq
  // process o'lsa ham saqlanib qoladi (splash ham, lifecycle ham o'qiy oladi).
  bool get pendingRelogin => _base.apiBox.get("pending_relogin") == true;

  Future<void> setPendingRelogin(bool value) async =>
      await _base.apiBox.put("pending_relogin", value);
}
