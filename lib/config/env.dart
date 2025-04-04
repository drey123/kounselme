// lib/config/env.dart
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

enum Environment {
  dev,
  prod,
}

class Env {
  // Private constructor to prevent instantiation
  Env._();

  // Current environment
  static Environment _environment = Environment.dev;
  static Environment get environment => _environment;

  // API URLs
  static String backendUrl = '';
  static String wsBaseUrl = '';
  static int wsPort = 0;

  // Supabase
  static String supabaseUrl = '';
  static String supabaseAnonKey = '';

  // Neon Database
  static String neonDatabaseUrl = '';
  static String neonHost = '';
  static int neonPort = 5432;
  static String neonDatabase = '';
  static String neonUsername = '';
  static String neonPassword = '';

  // API Keys - only include in production, use dummy/test keys in dev
  static String openaiApiKey = '';

  // Feature Flags
  static bool enableVoiceTranscription = false;
  static bool enableMultiUser = false;
  static bool enableOfflineMode = false;
  static bool useMockData = true; // For testing without backend

  // Chat settings
  static int defaultSessionLengthMinutes = 30;
  static int freeSessionCooldownMinutes = 120;
  static int maxSessionLengthMinutes = 60;
  static int maxMonthlyMinutesFree = 60; // 1 hour/month free plan

  // Development convenience settings
  static String devUserId = 'dev_user_123';
  static String devAuthToken = 'dev_token_abc';

  // Initialize the environment
  static Future<void> initialize({Environment env = Environment.dev}) async {
    _environment = env;

    // Load the appropriate .env file
    final envFile = _environment == Environment.prod ? '.env.prod' : '.env.dev';
    await dotenv.load(fileName: envFile);

    // Set up values from .env file
    backendUrl = dotenv.env['BACKEND_URL'] ?? _getDefaultBackendUrl();
    wsBaseUrl = dotenv.env['WS_BASE_URL'] ?? _getDefaultWsUrl();
    wsPort = int.parse(dotenv.env['WS_PORT'] ?? '3001');

    // Supabase
    supabaseUrl = dotenv.env['SUPABASE_URL'] ?? '';
    supabaseAnonKey = dotenv.env['SUPABASE_ANON_KEY'] ?? '';

    // Neon Database
    neonDatabaseUrl = dotenv.env['NEON_DATABASE_URL'] ?? '';
    neonHost = dotenv.env['NEON_HOST'] ?? 'localhost';
    neonPort = int.parse(dotenv.env['NEON_PORT'] ?? '5432');
    neonDatabase = dotenv.env['NEON_DATABASE'] ?? 'kounselme';
    neonUsername = dotenv.env['NEON_USERNAME'] ?? '';
    neonPassword = dotenv.env['NEON_PASSWORD'] ?? '';

    openaiApiKey = dotenv.env['OPENAI_API_KEY'] ?? '';

    // Feature flags
    enableVoiceTranscription = dotenv.env['ENABLE_VOICE'] == 'true';
    enableMultiUser = dotenv.env['ENABLE_MULTI_USER'] == 'true';
    enableOfflineMode = dotenv.env['ENABLE_OFFLINE'] == 'true';
    useMockData =
        env == Environment.dev && dotenv.env['USE_MOCK_DATA'] == 'true';

    // Chat settings
    defaultSessionLengthMinutes =
        int.parse(dotenv.env['DEFAULT_SESSION_LENGTH'] ?? '30');
    freeSessionCooldownMinutes =
        int.parse(dotenv.env['FREE_SESSION_COOLDOWN'] ?? '120');
    maxSessionLengthMinutes =
        int.parse(dotenv.env['MAX_SESSION_LENGTH'] ?? '60');
    maxMonthlyMinutesFree =
        int.parse(dotenv.env['MAX_MONTHLY_MINUTES_FREE'] ?? '60');

    // Dev user credentials for testing
    if (env == Environment.dev) {
      devUserId = dotenv.env['DEV_USER_ID'] ?? 'dev_user_123';
      devAuthToken = dotenv.env['DEV_AUTH_TOKEN'] ?? 'dev_token_abc';
    }

    // Log configuration in debug mode
    if (kDebugMode) {
      print('=== KounselMe Initialized in ${env.name.toUpperCase()} mode ===');
      print('Backend URL: $backendUrl');
      print('WebSocket URL: $wsBaseUrl (port: $wsPort)');
      print('Voice transcription enabled: $enableVoiceTranscription');
      print('Multi-user enabled: $enableMultiUser');
      print('Using mock data: $useMockData');
    }
  }

  // Helper method to get default backend URL based on environment
  static String _getDefaultBackendUrl() {
    return _environment == Environment.prod
        ? 'https://api.kounselme.com/api/v1'
        : 'http://localhost:3000/api/v1';
  }

  // Helper method to get default WebSocket URL based on environment
  static String _getDefaultWsUrl() {
    return _environment == Environment.prod
        ? 'wss://api.kounselme.com'
        : 'ws://localhost';
  }

  // Helper method to check if we're in production
  static bool isProd() => _environment == Environment.prod;

  // Helper method to check if we're in development
  static bool isDev() => _environment == Environment.dev;
}
