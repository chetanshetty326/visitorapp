import 'package:shared_preferences/shared_preferences.dart';

class ApiConstants {
  static const String _prefKeyBaseUrl = 'api_base_url';
  static const String _prefKeyEndpoint = 'api_endpoint';

  /// Default live MockAPI base URL provided by user
  static String defaultBaseUrl = 'https://6ae04efbbe3bc8fead96de47.mockapi.io';
  static String defaultEndpoint = '/vistor';

  static String _activeBaseUrl = defaultBaseUrl;
  static String _activeEndpoint = defaultEndpoint;

  static String get baseUrl => _activeBaseUrl;
  static String get visitorsEndpoint => _activeEndpoint;

  static String get fullVisitorsUrl => '$_activeBaseUrl$_activeEndpoint';

  static const int connectTimeoutMs = 12000;
  static const int receiveTimeoutMs = 12000;

  /// Load persisted base URL from SharedPreferences
  static Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    final savedBase = prefs.getString(_prefKeyBaseUrl);
    final savedEndpoint = prefs.getString(_prefKeyEndpoint);

    if (savedBase != null && savedBase.trim().isNotEmpty) {
      _activeBaseUrl = savedBase.trim();
    }
    if (savedEndpoint != null && savedEndpoint.trim().isNotEmpty) {
      _activeEndpoint = savedEndpoint.trim();
    }
  }

  /// Update the base URL dynamically and parse endpoint if included
  static Future<void> setBaseUrl(String input) async {
    var trimmed = input.trim();
    if (trimmed.endsWith('/')) {
      trimmed = trimmed.substring(0, trimmed.length - 1);
    }

    if (trimmed.endsWith('/vistor')) {
      _activeBaseUrl = trimmed.substring(0, trimmed.length - '/vistor'.length);
      _activeEndpoint = '/vistor';
    } else if (trimmed.endsWith('/visitors')) {
      _activeBaseUrl = trimmed.substring(0, trimmed.length - '/visitors'.length);
      _activeEndpoint = '/visitors';
    } else {
      _activeBaseUrl = trimmed;
      // keep current endpoint or default
    }

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_prefKeyBaseUrl, _activeBaseUrl);
    await prefs.setString(_prefKeyEndpoint, _activeEndpoint);
  }

  /// Reset to default
  static Future<void> resetToDefault() async {
    _activeBaseUrl = defaultBaseUrl;
    _activeEndpoint = defaultEndpoint;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_prefKeyBaseUrl);
    await prefs.remove(_prefKeyEndpoint);
  }
}
