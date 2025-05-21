// test/models/detected_object_test.dart
import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:mine_detection_app_2/models/detected_object.dart';

void main() {
  group('DetectedObject Model', () {
    final Map<String, dynamic> objectJson = {
      'id': 'obj123',
      'scan_id': 'scan456',
      'latitude': 49.8397,
      'longitude': 24.0297,
      'depth': 0.5,
      'object_type': 'mine',
      'confidence': 0.95,
      'danger_level': 3,
      'verification_status': 'confirmed'
    };

    test('should parse DetectedObject from JSON correctly', () {
      final detectedObject = DetectedObject.fromJson(objectJson);
      
      expect(detectedObject.id, 'obj123');
      expect(detectedObject.scanId, 'scan456');
      expect(detectedObject.latitude, 49.8397);
      expect(detectedObject.longitude, 24.0297);
      expect(detectedObject.depth, 0.5);
      expect(detectedObject.objectType, 'mine');
      expect(detectedObject.confidence, 0.95);
      expect(detectedObject.dangerLevel, 3);
      expect(detectedObject.verificationStatus, 'confirmed');
    });

    test('should convert DetectedObject to JSON correctly', () {
      final detectedObject = DetectedObject(
        id: 'obj123',
        scanId: 'scan456',
        latitude: 49.8397,
        longitude: 24.0297,
        depth: 0.5,
        objectType: 'mine',
        confidence: 0.95,
        dangerLevel: 3,
        verificationStatus: 'confirmed',
      );
      
      final objectToJson = detectedObject.toJson();
      
      expect(objectToJson['id'], 'obj123');
      expect(objectToJson['scan_id'], 'scan456');
      expect(objectToJson['latitude'], 49.8397);
      expect(objectToJson['longitude'], 24.0297);
    });
  });
}