import 'package:json_annotation/json_annotation.dart';
import 'package:uuid/uuid.dart';

part 'device.g.dart';

@JsonSerializable()
class Device {
  final String id;
  final String deviceType;
  final String serialNumber;
  final Map<String, dynamic> configuration;
  final String status;
  final DateTime createdAt;
  final DateTime lastConnectionAt;

  Device({
    required this.id,
    required this.deviceType,
    required this.serialNumber,
    required this.configuration,
    required this.status,
    required this.createdAt,
    required this.lastConnectionAt,
  });

  factory Device.fromJson(Map<String, dynamic> json) => _$DeviceFromJson(json);
  Map<String, dynamic> toJson() => _$DeviceToJson(this);
}