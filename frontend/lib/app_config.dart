class AppConfig {
  static const apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://10.0.2.2:4001',
  );

  static bool get hasApiBaseUrl => apiBaseUrl.isNotEmpty;
}