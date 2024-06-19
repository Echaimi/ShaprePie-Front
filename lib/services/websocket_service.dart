import 'dart:convert';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class WebSocketService {
  WebSocketChannel? _channel;
  final String url;
  final FlutterSecureStorage secureStorage = const FlutterSecureStorage();

  WebSocketService._(this.url);

  // Utilisation d'un constructeur factory pour initialiser de manière asynchrone
  factory WebSocketService(String url) {
    final service = WebSocketService._(url);
    service._initialize();
    return service;
  }

  Future<void> _initialize() async {
    try {
      final token = await secureStorage.read(key: 'auth_token');
      if (token == null) {
        throw Exception('Token not found');
      }
      final wsURL = Uri.parse('$url?authorization=Bearer $token');
      _channel = WebSocketChannel.connect(wsURL);
    } catch (e) {
      print('Error initializing WebSocket: $e');
    }
  }

  Stream<dynamic>? get stream => _channel?.stream;

  Future<void> send(dynamic message) async {
    try {
      _channel?.sink.add(jsonEncode(message));
    } catch (e) {
      print('Error sending message: $e');
    }
  }

  void dispose() {
    _channel?.sink.close();
  }
}
