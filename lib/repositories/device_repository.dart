// TODO Implement this library.import 'package:mine_detection_app_2/models/device.dart';
import 'package:mine_detection_app_2/services/api_service.dart';

class DeviceRepository {
  final ApiService _apiService;

  DeviceRepository({required ApiService apiService}) : _apiService = apiService;

  // Отримання списку пристроїв
  Future<List<Device>> getDevices({Map<String, dynamic>? filters}) async {
    final response = await _apiService.get('/devices', queryParameters: filters);
    return (response as List).map((json) => Device.fromJson(json)).toList();
  }

  // Отримання пристрою за ID
  Future<Device> getDeviceById(String id) async {
    final response = await _apiService.get('/devices/$id');
    return Device.fromJson(response);
  }

  // Створення нового пристрою
  Future<Device> createDevice({
    required String deviceType,
    required String serialNumber,
    required Map<String, dynamic> configuration,
  }) async {
    final response = await _apiService.post('/devices', data: {
      'device_type': deviceType,
      'serial_number': serialNumber,
      'configuration': configuration,
    });
    return Device.fromJson(response);
  }

  // Оновлення статусу пристрою
  Future<void> updateDeviceStatus(String id, String status) async {
    await _apiService.put('/devices/$id/status', data: {
      'status': status,
    });
  }

  // Оновлення конфігурації пристрою
  Future<void> updateDeviceConfig(String id, Map<String, dynamic> config) async {
    await _apiService.put('/devices/$id/config', data: config);
  }
}