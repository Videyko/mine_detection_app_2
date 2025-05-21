import 'package:json_annotation/json_annotation.dart';
part 'detected_object.g.dart';

@JsonSerializable()
class DetectedObject {
  final String id;
  final String scanId;
  final double latitude;
  final double longitude;
  final double depth;
  final String objectType;
  final double confidence;
  final int dangerLevel;
  final String verificationStatus;

  DetectedObject({
    required this.id,
    required this.scanId,
    required this.latitude,
    required this.longitude,
    required this.depth,
    required this.objectType,
    required this.confidence,
    required this.dangerLevel,
    required this.verificationStatus,
  });

  factory DetectedObject.fromJson(Map<String, dynamic> json) => _$DetectedObjectFromJson(json);
  Map<String, dynamic> toJson() => _$DetectedObjectToJson(this);
}