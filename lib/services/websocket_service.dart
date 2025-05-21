// TODO Implement this library.import 'dart:convert';
import 'package:web_socket_channel/web_socket_channel.dart';

class WebSocketService {
  final String baseUrl;
  WebSocketChannel? _channel;
  Stream<dynamic>? _broadcastStream;
  bool _isConnected = false;

  WebSocketService({required this.baseUrl});

  // ϳ��������� �� WebSocket
  Future<void> connect(String path, {String? token}) async {
    final uri = Uri.parse('$baseUrl/$path${token != null ? '?token=$token' : ''}');

    _channel = WebSocketChannel.connect(uri);
    _broadcastStream = _channel!.stream.asBroadcastStream();
    _isConnected = true;

    // ������������ heartbeat
    _setupHeartbeat();
  }

  // ϳ������ �� �����������
  Stream<dynamic> get messages {
    if (!_isConnected || _broadcastStream == null) {
      throw Exception('WebSocket is not connected');
    }
    return _broadcastStream!;
  }

  // ³������� �����������
  void send(dynamic data) {
    if (!_isConnected || _channel == null) {
      throw Exception('WebSocket is not connected');
    }

    if (data is Map || data is List) {
      _channel!.sink.add(jsonEncode(data));
    } else {
      _channel!.sink.add(data);
    }
  }

  // �������� �'�������
  void disconnect() {
    if (_channel != null) {
      _channel!.sink.close();
      _channel = null;
      _broadcastStream = null;
      _isConnected = false;
    }
  }

  // ������������ ����������� heartbeat
  void _setupHeartbeat() {
    Future.delayed(const Duration(seconds: 30), () {
      if (_isConnected) {
        send({
          'type': 'heartbeat',
          'time': DateTime.now().millisecondsSinceEpoch,
        });
        _setupHeartbeat();
      }
    });
  }

  bool get isConnected => _isConnected;
}