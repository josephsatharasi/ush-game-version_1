class EnvironmentConfig {
  static const bool _isLocal = bool.fromEnvironment('USE_LOCAL', defaultValue: true);
  
  static const String _localUrl = 'http://192.168.0.12:3001';
  static const String _liveUrl = 'http://200.69.21.209:5000';
  
  static String get baseUrl => _isLocal ? _localUrl : _liveUrl;
  static String get environment => _isLocal ? 'local' : 'live';
  
  static void printConfig() {
    print('🔧 Flutter Environment: $environment');
    print('🌐 API Base URL: $baseUrl');
  }
}