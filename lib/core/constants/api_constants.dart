import 'package:shared_preferences/shared_preferences.dart';

class ApiConstants {
  static const String _prefKeyBaseUrl = 'api_base_url';

  /// Default mock API base URL. Can be updated to your live MockAPI endpoint:
  /// e.g. 'https://67abcdef123456.mockapi.io/api/v1'
  static String defaultBaseUrl = 'https://mockapi.io/api/v1';

  static String _activeBaseUrl = defaultBaseUrl;

  static String get baseUrl => _activeBaseUrl;

  static const String visitorsEndpoint = '/visitors';

  static const int connectTimeoutMs = 10000;
  static const int receiveTimeoutMs = 10000;

  /// Load persisted base URL from SharedPreferences
  static Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getString(_prefKeyBaseUrl);
    if (saved != null && saved.trim().isNotEmpty) {
      _activeBaseUrl = saved.trim();
    }
  }

  /// Update the base URL dynamically and persist it
  static Future<void> setBaseUrl(String newUrl) async {
    _activeBaseUrl = newUrl.trim();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_prefKeyBaseUrl, _activeBaseUrl);
  }

  /// Reset to default
  static Future<void> resetToDefault() async {
    _activeBaseUrl = defaultBaseUrl;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_prefKeyBaseUrl);
  }
}
