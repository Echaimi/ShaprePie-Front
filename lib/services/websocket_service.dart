import 'dart:convert';
import 'package:web_socket_channel/web_socket_channel.dart';

class WebSocketService {
  final WebSocketChannel _channel;

  WebSocketService(String url)
      : _channel = WebSocketChannel.connect(Uri.parse(url));

  Stream<dynamic> get stream => _channel.stream;

  void send(dynamic message) {
    _channel.sink.add(jsonEncode(message));
  }

  void dispose() {
    _channel.sink.close();
  }
}
