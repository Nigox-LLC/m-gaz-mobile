import 'package:shared_preferences/shared_preferences.dart';

class StorageRepository {
  static StorageRepository? _storageUtil;

  static SharedPreferences? _preferences;

  static Future<StorageRepository> getInstance() async {
    if (_storageUtil == null) {
      final secureStorage = StorageRepository();
      await secureStorage._init();
      _storageUtil = secureStorage;
    }
    return _storageUtil!;
  }

  StorageRepository();

  static String getStoreKey(String identifier) => identifier;

  Future _init() async => _preferences = await SharedPreferences.getInstance();

  static Future<bool>? putString(String key, String value) {
    if (_preferences == null) return null;
    return _preferences!.setString(getStoreKey(key), value);
  }

  static Future<bool>? putList(String key, List<String> value) {
    if (_preferences == null) return null;
    return _preferences!.setStringList(getStoreKey(key), value);
  }

  static String getString(String key, {String defValue = ''}) {
    if (_preferences == null) return defValue;
    return _preferences!.getString(getStoreKey(key)) ?? defValue;
  }

  static Future<bool>? deleteString(String key) {
    if (_preferences == null) return null;
    return _preferences!.remove(getStoreKey(key));
  }

  static double getDouble(String key, {double defValue = 0.0}) {
    if (_preferences == null) return defValue;
    return _preferences!.getDouble(getStoreKey(key)) ?? defValue;
  }

  static int getInt(String key, {int defValue = 0}) {
    if (_preferences == null) return defValue;
    return _preferences!.getInt(getStoreKey(key)) ?? defValue;
  }

  static List<String> getList(String key, {List<String> defValue = const []}) {
    if (_preferences == null) return List.empty(growable: true);
    return _preferences!.getStringList(getStoreKey(key)) ??
        List.empty(growable: true);
  }

  static Future<bool>? putDouble(String key, double value) {
    if (_preferences == null) return null;
    return _preferences!.setDouble(getStoreKey(key), value);
  }

  static Future<bool>? deleteDouble(String key) {
    if (_preferences == null) return null;
    return _preferences!.remove(getStoreKey(key));
  }

  static bool getBool(String key, {bool defValue = true}) {
    if (_preferences == null) return defValue;
    return _preferences!.getBool(getStoreKey(key)) ?? defValue;
  }

  static Future<bool>? putBool({required String key, required bool value}) {
    if (_preferences == null) return null;
    return _preferences!.setBool(getStoreKey(key), value);
  }

  static Future<bool>? putInt(String key, int value) {
    if (_preferences == null) return null;
    return _preferences!.setInt(getStoreKey(key), value);
  }

  static Future<bool>? deleteBool(String key) {
    if (_preferences == null) return null;
    return _preferences!.remove(getStoreKey(key));
  }

  /// Wipes every shared-preferences entry. Used on logout to fully clear
  /// cached state.
  static Future<bool>? clear() {
    if (_preferences == null) return null;
    return _preferences!.clear();
  }
}
