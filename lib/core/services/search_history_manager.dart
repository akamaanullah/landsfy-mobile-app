import 'package:shared_preferences/shared_preferences.dart';

class SearchHistoryManager {
  static const String _key = 'recent_search_queries';

  static Future<List<String>> getRecentSearches() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList(_key) ?? [];
  }

  static Future<void> addSearch(String query) async {
    final cleanQuery = query.trim();
    if (cleanQuery.isEmpty) return;

    final prefs = await SharedPreferences.getInstance();
    List<String> list = prefs.getStringList(_key) ?? [];
    
    // Remove duplicate if exists
    list.removeWhere((item) => item.toLowerCase() == cleanQuery.toLowerCase());
    
    // Insert at beginning
    list.insert(0, cleanQuery);
    
    // Keep max 10 items
    if (list.length > 10) {
      list = list.sublist(0, 10);
    }
    
    await prefs.setStringList(_key, list);
  }

  static Future<void> removeSearch(String query) async {
    final prefs = await SharedPreferences.getInstance();
    List<String> list = prefs.getStringList(_key) ?? [];
    list.removeWhere((item) => item.toLowerCase() == query.toLowerCase());
    await prefs.setStringList(_key, list);
  }

  static Future<void> clearHistory() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_key);
  }
}
