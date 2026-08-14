import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart';

class SecureStorageService {
  static const _storage = FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
    iOptions: IOSOptions(accessibility: KeychainAccessibility.first_unlock),
  );

  static const String _tokenKey = 'jwt_token';
  static const String _userSessionKey = 'user_session';

  static Future<void> saveToken(String token) async {
    try {
      await _storage.write(key: _tokenKey, value: token);
    } catch (e) {
      debugPrint('SecureStorage write error, falling back: $e');
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_tokenKey, token);
    }
  }

  static Future<String?> getToken() async {
    try {
      final token = await _storage.read(key: _tokenKey);
      if (token != null && token.isNotEmpty) return token;
    } catch (e) {
      debugPrint('SecureStorage read error, checking prefs: $e');
    }
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_tokenKey);
  }

  static Future<void> saveUserSession(String sessionJson) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_userSessionKey, sessionJson);
  }

  static Future<String?> getUserSession() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_userSessionKey);
  }

  static Future<void> clearAll() async {
    try {
      await _storage.delete(key: _tokenKey);
    } catch (e) {
      debugPrint('SecureStorage delete error: $e');
    }
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
    await prefs.remove(_userSessionKey);
  }
}
