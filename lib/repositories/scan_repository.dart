// TODO Implement this library.import 'package:mine_detection_app_2/models/detected_object.dart';
import 'package:mine_detection_app_2/models/scan.dart';
import 'package:mine_detection_app_2/services/api_service.dart';
import 'package:mine_detection_app_2/services/websocket_service.dart';

class ScanRepository {
  final ApiService _apiService;
  final WebSocketService _wsService;

  ScanRepository({
    required ApiService apiService,
    required WebSocketService wsService,
  })  : _apiService = apiService,
        _wsService = wsService;

  // ��������� ������ ���������
  Future<List<Scan>> getScans({Map<String, dynamic>? filters}) async {
    final response = await _apiService.get('/scans', queryParameters: filters);
    return (response as List).map((json) => Scan.fromJson(json)).toList();
  }

  // ��������� ���������� �� ID
  Future<Scan> getScanById(String id) async {
    final response = await _apiService.get('/scans/$id');
    return Scan.fromJson(response);
  }

  // ������� ������ ����������
  Future<Scan> startScan({
    required String missionId,
    required String deviceId,
    required String scanType,
    Map<String, dynamic>? metadata,
  }) async {
    final response = await _apiService.post('/scans', data: {
      'mission_id': missionId,
      'device_id': deviceId,
      'scan_type': scanType,
      'metadata': metadata ?? {},
    });
    return Scan.fromJson(response);
  }

  // ���������� ����������
  Future<void> endScan(String id) async {
    await _apiService.put('/scans/$id/end');
  }

  // ��������� ��������� ��'���� ��� ����������
  Future<List<DetectedObject>> getDetectedObjects(String scanId) async {
    final response = await _apiService.get('/scans/$scanId/objects');
    return (response as List).map((json) => DetectedObject.fromJson(json)).toList();
  }

  // ϳ������ �� ��������� ���������� � ��������� ���
  Stream<dynamic> subscribeScanUpdates(String scanId, String token) {
    if (!_wsService.isConnected) {
      _wsService.connect('sensors', token: token);
    }

    _wsService.send({
      'type': 'subscribe',
      'scan_id': scanId,
    });

    return _wsService.messages;
  }

  // ³������ �� �������� ����������
  void unsubscribeScanUpdates(String scanId) {
    if (_wsService.isConnected) {
      _wsService.send({
        'type': 'unsubscribe',
        'scan_id': scanId,
      });
    }
  }
}