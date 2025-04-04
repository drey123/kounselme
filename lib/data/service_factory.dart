// lib/data/service_factory.dart
import 'package:kounselme/config/env.dart';
import 'package:kounselme/data/services/websocket_service.dart';
import 'package:kounselme/data/services/consolidated_websocket_service.dart';

/// Factory class for creating services
/// This provides a centralized way to get service instances
class ServiceFactory {
  // Private constructor to prevent instantiation
  ServiceFactory._();

  /// Create a WebSocket service
  /// Returns the consolidated implementation that handles both real and mock scenarios
  /// based on environment settings
  static WebSocketService createWebSocketService() {
    return ConsolidatedWebSocketService();
  }
}
