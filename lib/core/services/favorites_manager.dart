import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class FavoritesManager {
  static const String _key = 'saved_properties';

  static Future<List<Map<String, dynamic>>> getFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    final String? rawData = prefs.getString(_key);
    if (rawData == null || rawData.isEmpty) return [];
    try {
      final List<dynamic> decoded = jsonDecode(rawData) as List<dynamic>;
      return decoded.map((item) => Map<String, dynamic>.from(item as Map)).toList();
    } catch (_) {
      return [];
    }
  }

  static Future<bool> isFavorite(int propertyId) async {
    final list = await getFavorites();
    return list.any((item) => (item['id'] is int ? item['id'] as int : int.tryParse(item['id'].toString()) ?? 0) == propertyId);
  }

  static Future<void> toggleFavorite(Map<String, dynamic> property) async {
    final list = await getFavorites();
    final int id = property['id'] is int ? property['id'] as int : int.tryParse(property['id'].toString()) ?? 0;
    
    final exists = list.indexWhere((item) => (item['id'] is int ? item['id'] as int : int.tryParse(item['id'].toString()) ?? 0) == id);
    if (exists != -1) {
      list.removeAt(exists);
    } else {
      list.add(property);
    }
    
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, jsonEncode(list));
  }
}
