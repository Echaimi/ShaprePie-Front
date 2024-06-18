import 'dart:convert';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class WebSocketService {
  final WebSocketChannel _channel;
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();

  WebSocketService(String url)
      : _channel = WebSocketChannel.connect(Uri.parse(url));

  Stream<dynamic> get stream => _channel.stream;

  Future<void> send(dynamic message) async {
    final token = await _secureStorage.read(key: 'auth_token');
    final messageWithToken = {
      'headers': {'Authorization': 'Bearer $token'},
      'body': message,
    };
    _channel.sink.add(jsonEncode(messageWithToken));
  }

  void dispose() {
    _channel.sink.close();
  }
}
