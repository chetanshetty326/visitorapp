class ApiConstants {
  /// Base URL for the Mock REST API service (e.g. MockAPI.io, Beeceptor, or custom server).
  /// You can update this with your actual MockAPI URL endpoint:
  /// e.g. 'https://67...mockapi.io/api/v1'
  static String baseUrl = 'https://mockapi.io/api/v1';

  static const String visitorsEndpoint = '/visitors';

  static const int connectTimeoutMs = 10000;
  static const int receiveTimeoutMs = 10000;
}
