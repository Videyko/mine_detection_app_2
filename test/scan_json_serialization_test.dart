// test/models/scan_test.dart
import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:mine_detection_app_2/models/scan.dart';

void main() {
  group('Scan Model', () {
    final Map<String, dynamic> scanJson = {
      'id': 'scan123',
      'mission_id': 'mission456',
      'device_id': 'device789',
      'scan_type': 'area',
      'start_time': '2023-03-15T10:00:00Z',
      'end_time': '2023-03-15T11:30:00Z',
      'status': 'completed',
      'metadata': {'area_size': 100, 'weather': 'clear'}
    };

    test('should parse Scan from JSON correctly', () {
      final scan = Scan.fromJson(scanJson);
      
      expect(scan.id, 'scan123');
      expect(scan.missionId, 'mission456');
      expect(scan.deviceId, 'device789');
      expect(scan.scanType, 'area');
      expect(scan.startTime, isA<DateTime>());
      expect(scan.endTime, isA<DateTime>());
      expect(scan.status, 'completed');
      expect(scan.metadata['area_size'], 100);
    });

    test('should convert Scan to JSON correctly', () {
      final scan = Scan(
        id: 'scan123',
        missionId: 'mission456',
        deviceId: 'device789',
        scanType: 'area',
        startTime: DateTime.parse('2023-03-15T10:00:00Z'),
        endTime: DateTime.parse('2023-03-15T11:30:00Z'),
        status: 'completed',
        metadata: {'area_size': 100, 'weather': 'clear'},
      );
      
      final scanToJson = scan.toJson();
      
      expect(scanToJson['id'], 'scan123');
      expect(scanToJson['mission_id'], 'mission456');
      expect(scanToJson['scan_type'], 'area');
    });
  });
}