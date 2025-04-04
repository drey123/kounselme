// lib/core/constants/app_constants.dart
class AppConstants {
  // Private constructor to prevent instantiation
  AppConstants._();
  
  // App Info
  static const String appName = 'KounselMe';
  static const String appVersion = '1.0.0';
  
  // Features Limits
  static const int freeChatMessageLimit = 50;
  static const int freeJournalEntryLimit = 10;
  
  // WebSocket
  static const int connectionRetryAttempts = 3;
  static const int connectionRetryDelaySeconds = 2;
  
  // Local Database
  static const String databaseName = 'kounselme.db';
  static const int databaseVersion = 1;
  
  // Preferences Keys
  static const String prefsKeyAccessToken = 'access_token';
  static const String prefsKeyRefreshToken = 'refresh_token';
  static const String prefsKeyUserId = 'user_id';
  static const String prefsKeyUserEmail = 'user_email';
  static const String prefsKeyIsPremium = 'is_premium';
}