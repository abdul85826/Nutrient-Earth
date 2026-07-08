import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class CacheService {
  static late SharedPreferences _prefs;

  static Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  static Future<void> set(String key, dynamic value, {Duration? ttl}) async {
    final data = {
      'value': value,
      'expiry': ttl != null ? DateTime.now().add(ttl).toIso8601String() : null,
    };
    await _prefs.setString(key, jsonEncode(data));
  }

  static dynamic get(String key) {
    final raw = _prefs.getString(key);
    if (raw == null) return null;

    final data = jsonDecode(raw);
    final expiryStr = data['expiry'];
    
    if (expiryStr != null) {
      final expiry = DateTime.parse(expiryStr);
      if (DateTime.now().isAfter(expiry)) {
        _prefs.remove(key);
        return null;
      }
    }

    return data['value'];
  }

  static Future<void> remove(String key) async {
    await _prefs.remove(key);
  }

  static Future<void> clear() async {
    await _prefs.clear();
  }
}
