import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:mine_detection_app_2/blocs/auth/auth_bloc.dart';
import 'package:mine_detection_app_2/blocs/scan/scan_bloc.dart';
import 'package:mine_detection_app_2/models/detected_object.dart';
import 'package:mine_detection_app_2/models/scan.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:mine_detection_app_2/widgets/object_info_card.dart';

class ScanDetailsScreen extends StatefulWidget {
  final Scan scan;

  const ScanDetailsScreen({
    Key? key,
    required this.scan,
  }) : super(key: key);

  @override
  State<ScanDetailsScreen> createState() => _ScanDetailsScreenState();
}

class _ScanDetailsScreenState extends State<ScanDetailsScreen> {
  final MapController _mapController = MapController();
  DetectedObject? _selectedObject;
  bool _isRealTimeMode = false;

  @override
  void initState() {
    super.initState();
    // ��������� ��������� ��'����
    context.read<ScanBloc>().add(
      DetectedObjectsFetched(scanId: widget.scan.id),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('����� ���������� #${widget.scan.id.substring(0, 8)}'),
        actions: [
          if (widget.scan.status == 'in_progress')
            Switch(
              value: _isRealTimeMode,
              onChanged: (value) => _toggleRealTimeMode(context, value),
              activeColor: Theme.of(context).colorScheme.primary,
              activeTrackColor: Theme.of(context).colorScheme.primaryContainer,
              inactiveThumbColor: Colors.grey,
              inactiveTrackColor: Colors.grey.shade300,
            ),
          if (widget.scan.status == 'in_progress')
            const Padding(
              padding: EdgeInsets.only(right: 16.0),
              child: Text('����� ��������� ����'),
            ),
        ],
      ),
      body: Column(
        children: [
          // ������������ ������
          Container(
            padding: const EdgeInsets.all(16.0),
            color: Theme.of(context).colorScheme.surfaceVariant,
            child: Row(
              children: [
                Expanded(
                  child: _buildInfoItem(
                    '̳��',
                    widget.scan.missionId,
                  ),
                ),
                Expanded(
                  child: _buildInfoItem(
                    '�������',
                    widget.scan.deviceId,
                  ),
                ),
                Expanded(
                  child: _buildInfoItem(
                    '�������',
                    DateFormat('dd.MM.yyyy HH:mm').format(widget.scan.startTime),
                  ),
                ),
                Expanded(
                  child: _buildInfoItem(
                    '����������',
                    widget.scan.endTime != null
                        ? DateFormat('dd.MM.yyyy HH:mm').format(widget.scan.endTime!)
                        : '-',
                  ),
                ),
                Expanded(
                  child: _buildInfoItem(
                    '������',
                    _getScanStatusLabel(widget.scan.status),
                    _getScanStatusColor(widget.scan.status),
                  ),
                ),
              ],
            ),
          ),

          // �������� �������
          Expanded(
            child: BlocBuilder<ScanBloc, ScanState>(
              builder: (context, state) {
                if (state is ScanLoading) {
                  return const Center(child: CircularProgressIndicator());
                }

                // ³���������� ��������� ��'����
                List<DetectedObject> detectedObjects = [];

                if (state is DetectedObjectsLoaded) {
                  detectedObjects = state.detectedObjects;
                } else if (state is ScanLiveUpdating) {
                  detectedObjects = state.detectedObjects;
                }

                return Row(
                  children: [
                    // �����
                    Expanded(
                      flex: 3,
                      child: _buildMap(detectedObjects),
                    ),

                    // ����� ������
                    Expanded(
                      flex: 1,
                      child: Container(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '������� ��\'����: ${detectedObjects.length}',
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 16),

                            // ���������� �� ������ ��'����
                            _buildStatisticsCard(detectedObjects),

                            const SizedBox(height: 16),

                            // ���������� ��� �������� ��'���
                            if (_selectedObject != null)
                              Expanded(
                                child: SingleChildScrollView(
                                  child: ObjectInfoCard(object: _selectedObject!),
                                ),
                              )
                            else
                              const Expanded(
                                child: Center(
                                  child: Text('������� ��\'��� �� ���� ��� ��������� �������'),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoItem(String label, String value, [Color? chipColor]) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        chipColor != null
            ? Chip(
          label: Text(value),
          backgroundColor: chipColor,
        )
            : Text(value),
      ],
    );
  }

  Widget _buildMap(List<DetectedObject> objects) {
    // ���������� ������ �����
    LatLng center;
    if (objects.isNotEmpty) {
      double sumLat = 0;
      double sumLon = 0;
      for (final obj in objects) {
        sumLat += obj.latitude;
        sumLon += obj.longitude;
      }
      center = LatLng(sumLat / objects.length, sumLon / objects.length);
    } else {
      center = const LatLng(49.0, 31.0); // �� ������������� - ������
    }

    return FlutterMap(
      mapController: _mapController,
      options: MapOptions(
        center: center,
        zoom: 15.0,
        onTap: (_, __) => setState(() => _selectedObject = null),
      ),
      children: [
        TileLayer(
          urlTemplate: 'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
          subdomains: const ['a', 'b', 'c'],
        ),
        MarkerLayer(
          markers: objects.map((object) {
            final isSelected = _selectedObject?.id == object.id;

            // ���� ������� ������� �� ����� ���� ���������
            Color markerColor;
            switch (object.dangerLevel) {
              case 1:
                markerColor = Colors.blue;
                break;
              case 2:
                markerColor = Colors.green;
                break;
              case 3:
                markerColor = Colors.yellow;
                break;
              case 4:
                markerColor = Colors.orange;
                break;
              case 5:
                markerColor = Colors.red;
                break;
              default:
                markerColor = Colors.grey;
            }

            return Marker(
              point: LatLng(object.latitude, object.longitude),
              width: isSelected ? 40 : 30,
              height: isSelected ? 40 : 30,
              builder: (context) => GestureDetector(
                onTap: () => setState(() => _selectedObject = object),
                child: Icon(
                  Icons.location_on,
                  color: markerColor,
                  size: isSelected ? 40 : 30,
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildStatisticsCard(List<DetectedObject> objects) {
    // ϳ�������� ������� ��'���� �� ������
    final Map<String, int> objectTypeCounts = {};
    for (final object in objects) {
      objectTypeCounts[object.objectType] = (objectTypeCounts[object.objectType] ?? 0) + 1;
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '����������',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 8),
            ...objectTypeCounts.entries.map((entry) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 4.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(_getObjectTypeName(entry.key)),
                    Text(
                      '${entry.value}',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  void _toggleRealTimeMode(BuildContext context, bool value) {
    setState(() {
      _isRealTimeMode = value;
    });

    if (value) {
      // ��������� ������ � AuthBloc
      final authState = context.read<AuthBloc>().state;
      if (authState is AuthAuthenticated) {
        // ϳ������ �� ��������� � ��������� ���
        context.read<ScanBloc>().add(
          ScanUpdatesSubscribed(
            scanId: widget.scan.id,
            token: authState.token,
          ),
        );
      }
    } else {
      // ³������ �� ��������
      context.read<ScanBloc>().add(
        ScanUpdatesUnsubscribed(
          scanId: widget.scan.id,
        ),
      );
    }
  }

  String _getScanStatusLabel(String status) {
    switch (status) {
      case 'in_progress':
        return '� ������';
      case 'completed':
        return '���������';
      case 'failed':
        return '�������';
      default:
        return status;
    }
  }

  Color _getScanStatusColor(String status) {
    switch (status) {
      case 'in_progress':
        return Colors.blue.shade100;
      case 'completed':
        return Colors.green.shade100;
      case 'failed':
        return Colors.red.shade100;
      default:
        return Colors.grey.shade100;
    }
  }

  String _getObjectTypeName(String type) {
    switch (type) {
      case 'anti_personnel_mine':
        return '����������� ���';
      case 'anti_tank_mine':
        return '������������ ���';
      case 'unknown':
        return '�������� ���';
      default:
        return type;
    }
  }

  @override
  void dispose() {
    // ³������ �� �������� ��� ������� ������
    if (_isRealTimeMode) {
      context.read<ScanBloc>().add(
        ScanUpdatesUnsubscribed(
          scanId: widget.scan.id,
        ),
      );
    }
    super.dispose();
  }
}