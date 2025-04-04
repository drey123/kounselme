import 'dart:async';
import 'dart:convert';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:web_socket_channel/io.dart';
import 'websocket_service.dart';

class RealWebSocketService implements WebSocketService {
  WebSocketChannel? _channel;
  final _connectionStreamController =
      StreamController<ConnectionStatus>.broadcast();
  final _typingStreamController =
      StreamController<Map<String, bool>>.broadcast();
  final _participantStreamController =
      StreamController<List<dynamic>>.broadcast();
  final _errorStreamController = StreamController<String>.broadcast();

  @override
  Stream<ConnectionStatus> get connectionStream =>
      _connectionStreamController.stream;

  @override
  Stream<Map<String, bool>> get typingStream => _typingStreamController.stream;

  @override
  Stream<List<dynamic>> get participantStream => _participantStreamController.stream;

  @override
  Stream<String> get errorStream => _errorStreamController.stream;

  @override
  ConnectionStatus get connectionStatus {
    if (_channel == null) {
      return ConnectionStatus.disconnected;
    }
    return ConnectionStatus.connected;
  }

  @override
  Future<void> connect() async {
    try {
      _channel = IOWebSocketChannel.connect('ws://example.com');
      _connectionStreamController.add(ConnectionStatus.connected);
    } catch (e) {
      _errorStreamController.add('Failed to connect: $e');
      _connectionStreamController.add(ConnectionStatus.error);
    }
  }

  @override
  Future<void> disconnect() async {
    try {
      await _channel?.sink.close();
      _connectionStreamController.add(ConnectionStatus.disconnected);
    } catch (e) {
      _errorStreamController.add('Failed to disconnect: $e');
    }
  }

  @override
  void inviteUser(String email, {String? message}) {
    _channel?.sink.add(jsonEncode(
        {'type': 'invite_user', 'email': email, 'message': message}));
  }

  @override
  void removeUser(String userId) {
    _channel?.sink.add(jsonEncode({'type': 'remove_user', 'userId': userId}));
  }

  void dispose() {
    _connectionStreamController.close();
    _typingStreamController.close();
    _participantStreamController.close();
    _errorStreamController.close();
  }
}
