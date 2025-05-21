// test/models/device_test.dart
import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:mine_detection_app_2/models/device.dart';

void main() {
  group('Device Model', () {
    // Тестові дані
    final Map<String, dynamic> deviceJson = {
      'id': '123456',
      'device_type': 'detector',
      'serial_number': 'SN12345',
      'configuration': {'sensitivity': 0.8, 'mode': 'standard'},
      'status': 'active',
      'created_at': '2023-01-01T12:00:00Z',
      'last_connection_at': '2023-02-01T14:30:00Z',
    };

    test('should parse Device from JSON correctly', () {
      // Конвертуємо рядкові дати у DateTime для очікуваного результату
      final device = Device.fromJson(deviceJson);
      
      expect(device.id, '123456');
      expect(device.deviceType, 'detector');
      expect(device.serialNumber, 'SN12345');
      expect(device.configuration['sensitivity'], 0.8);
      expect(device.configuration['mode'], 'standard');
      expect(device.status, 'active');
      expect(device.createdAt, isA<DateTime>());
      expect(device.lastConnectionAt, isA<DateTime>());
    });

    test('should convert Device to JSON correctly', () {
      // Створюємо об'єкт пристрою
      final device = Device(
        id: '123456',
        deviceType: 'detector',
        serialNumber: 'SN12345',
        configuration: {'sensitivity': 0.8, 'mode': 'standard'},
        status: 'active',
        createdAt: DateTime.parse('2023-01-01T12:00:00Z'),
        lastConnectionAt: DateTime.parse('2023-02-01T14:30:00Z'),
      );
      
      // Конвертуємо об'єкт до JSON
      final deviceToJson = device.toJson();
      
      // Перевіряємо ключові поля
      expect(deviceToJson['id'], '123456');
      expect(deviceToJson['device_type'], 'detector');
      expect(deviceToJson['configuration']['sensitivity'], 0.8);
    });
  });
}