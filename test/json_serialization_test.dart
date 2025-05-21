// test/serialization_test.dart
import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:mine_detection_app_2/models/device.dart';
import 'package:mine_detection_app_2/models/detected_object.dart';
import 'package:mine_detection_app_2/models/scan.dart';

void main() {
  group('JSON Serialization Tests', () {
    test('All models should serialize and deserialize properly', () {
      // Створюємо тестові дані
      final device = Device(
        id: 'device123',
        deviceType: 'detector',
        serialNumber: 'SN-123',
        configuration: {'mode': 'standard'},
        status: 'active',
        createdAt: DateTime.now(),
        lastConnectionAt: DateTime.now(),
      );
      
      final detectedObject = DetectedObject(
        id: 'obj123',
        scanId: 'scan456',
        latitude: 50.4501,
        longitude: 30.5234,
        depth: 0.3,
        objectType: 'mine',
        confidence: 0.85,
        dangerLevel: 2,
        verificationStatus: 'pending',
      );
      
      final scan = Scan(
        id: 'scan123',
        missionId: 'mission456',
        deviceId: 'device123',
        scanType: 'linear',
        startTime: DateTime.now(),
        endTime: DateTime.now().add(Duration(hours: 1)),
        status: 'in_progress',
        metadata: {'speed': 1.5},
      );
      
      // Тест на серіалізацію-десеріалізацію для Device
      final deviceJson = device.toJson();
      final deviceFromJson = Device.fromJson(deviceJson);
      expect(deviceFromJson.id, device.id);
      
      // Тест на серіалізацію-десеріалізацію для DetectedObject
      final objectJson = detectedObject.toJson();
      final objectFromJson = DetectedObject.fromJson(objectJson);
      expect(objectFromJson.id, detectedObject.id);
      
      // Тест на серіалізацію-десеріалізацію для Scan
      final scanJson = scan.toJson();
      final scanFromJson = Scan.fromJson(scanJson);
      expect(scanFromJson.id, scan.id);
    });
    
    test('Models should handle special characters correctly', () {
      // Тест з особливими символами, які можуть викликати проблеми кодування
      final device = Device(
        id: 'dev-123',
        deviceType: 'detector-спеціальний',  // кирилиця
        serialNumber: 'SN-123-???',         // спеціальні символи
        configuration: {'mode': 'тестовий'}, // кирилиця в значенні
        status: 'active & "testing"',       // лапки та спецсимволи
        createdAt: DateTime.now(),
        lastConnectionAt: DateTime.now(),
      );
      
      // Серіалізуємо та десеріалізуємо
      final deviceJson = device.toJson();
      final deviceFromJson = Device.fromJson(deviceJson);
      
      // Перевіряємо збереження особливих символів
      expect(deviceFromJson.deviceType, 'detector-спеціальний');
      expect(deviceFromJson.serialNumber, 'SN-123-???');
      expect(deviceFromJson.configuration['mode'], 'тестовий');
      expect(deviceFromJson.status, 'active & "testing"');
    });
  });
}