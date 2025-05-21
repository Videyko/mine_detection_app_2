import 'package:json_annotation/json_annotation.dart';

part 'scan.g.dart';

@JsonSerializable()
class Scan {
  final String id;
  final String missionId;
  final String deviceId;
  final DateTime startTime;
  final DateTime? endTime;
  final String scanType;
  final String status;
  final Map<String, dynamic> metadata;

  Scan({
    required this.id,
    required this.missionId,
    required this.deviceId,
    required this.startTime,
    this.endTime,
    required this.scanType,
    required this.status,
    required this.metadata,
  });

  factory Scan.fromJson(Map<String, dynamic> json) => _$ScanFromJson(json);
  Map<String, dynamic> toJson() => _$ScanToJson(this);
}