// lib/config/env_prod.dart
class EnvProd {
  // API Configuration
  static const String backendUrl = 'https://api.kounselme.com';
  static const bool useMockBackend = false;
  static const int connectionTimeout = 30000; // 30 seconds
  
  // Feature Flags
  static const bool enableVoiceInput = true;
  static const bool enableMultiUserChat = true;
  static const bool enableFileSharing = true;
  
  // Session Configuration
  static const int defaultSessionLength = 30; // minutes
  static const int maxSessionLength = 60; // minutes
  static const int sessionCooldown = 120; // minutes
  
  // Authentication
  static const String supabaseUrl = 'https://your-prod-supabase-url.supabase.co';
  static const String supabaseAnonKey = 'your-prod-supabase-anon-key';
  
  // AI Configuration
  static const String openAiApiKey = 'your-prod-openai-api-key';
  static const String defaultModel = 'gpt-4o';
  
  // Payment Configuration
  static const String lemonSqueezyApiKey = 'your-prod-lemonsqueezy-api-key';
  static const String lemonSqueezyStoreId = 'your-prod-lemonsqueezy-store-id';
}
