// lib/config/env.dart
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Environment configuration for the app
class Env {
  // Private constructor to prevent instantiation
  Env._();

  // Environment types
  static const String _dev = 'development';
  static const String _staging = 'staging';
  static const String _prod = 'production';

  // Current environment
  static String _environment = _dev;

  // Initialize environment
  static Future<void> initialize() async {
    try {
      // Load environment variables from .env file
      await dotenv.load();

      // Set environment from .env file or default to development
      _environment = dotenv.env['ENVIRONMENT'] ?? _dev;

      debugPrint('Environment: $_environment');
    } catch (e) {
      debugPrint('Error loading environment: $e');
      _environment = _dev;
    }
  }

  // Check if current environment is development
  static bool isDev() => _environment == _dev;

  // Check if current environment is staging
  static bool isStaging() => _environment == _staging;

  // Check if current environment is production
  static bool isProd() => _environment == _prod;

  // Get current environment
  static String get environment => _environment;

  // Set environment manually (useful for testing)
  static void setEnvironment(String env) {
    assert(env == _dev || env == _staging || env == _prod);
    _environment = env;
  }

  // Backend URL (alias for apiBaseUrl for compatibility)
  static String get backendUrl => apiBaseUrl;

  // API Base URL
  static String get apiBaseUrl {
    if (isProd()) {
      return dotenv.env['PROD_API_URL'] ?? 'https://api.kounselme.com';
    } else if (isStaging()) {
      return dotenv.env['STAGING_API_URL'] ??
          'https://staging-api.kounselme.com';
    } else {
      return dotenv.env['DEV_API_URL'] ?? 'http://localhost:3000';
    }
  }

  // WebSocket Base URL
  static String get wsBaseUrl {
    if (isProd()) {
      return dotenv.env['PROD_WS_URL'] ?? 'wss://api.kounselme.com';
    } else if (isStaging()) {
      return dotenv.env['STAGING_WS_URL'] ?? 'wss://staging-api.kounselme.com';
    } else {
      return dotenv.env['DEV_WS_URL'] ?? 'ws://localhost:3000';
    }
  }

  // WebSocket Port
  static int get wsPort {
    try {
      if (isProd()) {
        return int.parse(dotenv.env['PROD_WS_PORT'] ?? '0');
      } else if (isStaging()) {
        return int.parse(dotenv.env['STAGING_WS_PORT'] ?? '0');
      } else {
        return int.parse(dotenv.env['DEV_WS_PORT'] ?? '0');
      }
    } catch (e) {
      return 0; // Default to 0 (use default port)
    }
  }

  // API Version
  static String get apiVersion => dotenv.env['API_VERSION'] ?? 'v1';

  // Use mock data (for development and testing)
  static bool _forceMockData = false;

  static bool get useMockData {
    if (_forceMockData) return true;
    if (isProd()) return false;
    return dotenv.env['USE_MOCK_DATA'] == 'true';
  }

  // Set mock data flag manually (useful for testing)
  static void setUseMockData(bool useMock) {
    _forceMockData = useMock;
  }

  // OpenAI API Key
  static String get openAiApiKey => dotenv.env['OPENAI_API_KEY'] ?? '';

  // Together.ai API Key
  static String get togetherAiApiKey => dotenv.env['TOGETHER_AI_API_KEY'] ?? '';

  // Supabase URL
  static String get supabaseUrl => dotenv.env['SUPABASE_URL'] ?? '';

  // Supabase Anonymous Key
  static String get supabaseAnonKey => dotenv.env['SUPABASE_ANON_KEY'] ?? '';

  // App Base URL (for invite links, etc.)
  static String get appBaseUrl {
    if (isProd()) {
      return dotenv.env['PROD_APP_URL'] ?? 'https://kounselme.app';
    } else if (isStaging()) {
      return dotenv.env['STAGING_APP_URL'] ?? 'https://staging.kounselme.app';
    } else {
      return dotenv.env['DEV_APP_URL'] ?? 'http://localhost:3000';
    }
  }

  // Connection Timeout (in milliseconds)
  static int get connectionTimeout {
    if (isProd()) {
      return int.tryParse(dotenv.env['PROD_CONNECTION_TIMEOUT'] ?? '') ?? 30000;
    } else if (isStaging()) {
      return int.tryParse(dotenv.env['STAGING_CONNECTION_TIMEOUT'] ?? '') ?? 20000;
    } else {
      return int.tryParse(dotenv.env['DEV_CONNECTION_TIMEOUT'] ?? '') ?? 10000;
    }
  }

  // Get full API URL with version
  static String getApiUrl(String endpoint) {
    final baseUrl = apiBaseUrl;
    final version = apiVersion;

    // Ensure endpoint starts with '/'
    final path = endpoint.startsWith('/') ? endpoint : '/$endpoint';

    return '$baseUrl/$version$path';
  }

  // Get full app URL (for invite links, etc.)
  static String getAppUrl(String path) {
    final baseUrl = appBaseUrl;
    
    // Ensure path starts with '/'
    final formattedPath = path.startsWith('/') ? path : '/$path';

    return '$baseUrl$formattedPath';
  }

  // Toggle mock data (for development and testing)
  static void toggleMockData() {
    if (isProd()) return;

    final currentValue = dotenv.env['USE_MOCK_DATA'];
    final newValue = currentValue == 'true' ? 'false' : 'true';

    dotenv.env['USE_MOCK_DATA'] = newValue;
    debugPrint('Mock data: $newValue');
  }
}
