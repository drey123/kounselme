// lib/config/env_dev.dart
class EnvDev {
  // API Configuration
  static const String backendUrl = 'http://localhost:3000';
  static const bool useMockBackend = true;
  static const int connectionTimeout = 10000; // 10 seconds
  
  // Feature Flags
  static const bool enableVoiceInput = true;
  static const bool enableMultiUserChat = true;
  static const bool enableFileSharing = true;
  
  // Session Configuration
  static const int defaultSessionLength = 30; // minutes
  static const int maxSessionLength = 60; // minutes
  static const int sessionCooldown = 120; // minutes
  
  // Authentication
  static const String supabaseUrl = 'https://your-dev-supabase-url.supabase.co';
  static const String supabaseAnonKey = 'your-dev-supabase-anon-key';
  
  // AI Configuration
  static const String openAiApiKey = 'your-dev-openai-api-key';
  static const String defaultModel = 'gpt-4o';
  
  // Payment Configuration
  static const String lemonSqueezyApiKey = 'your-dev-lemonsqueezy-api-key';
  static const String lemonSqueezyStoreId = 'your-dev-lemonsqueezy-store-id';
}
