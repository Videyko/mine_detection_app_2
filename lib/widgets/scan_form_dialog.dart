import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mine_detection_client/blocs/device/device_bloc.dart';
import 'package:mine_detection_client/blocs/scan/scan_bloc.dart';
import 'package:mine_detection_client/models/device.dart';

class ScanFormDialog extends StatefulWidget {
  const ScanFormDialog({Key? key}) : super(key: key);

  @override
  State<ScanFormDialog> createState() => _ScanFormDialogState();
}

class _ScanFormDialogState extends State<ScanFormDialog> {
  final _formKey = GlobalKey<FormState>();
  final _missionIdController = TextEditingController();
  String? _selectedDeviceId;
  String _scanType = 'standard';
  final _metadataController = TextEditingController(
    text: '{\n  "description": "Стандартне сканування",\n  "area_size": 100\n}',
  );

  @override
  void initState() {
    super.initState();
    // Завантаження списку пристроїв
    context.read<DeviceBloc>().add(const DevicesFetched());
  }

  @override
  void dispose() {
    _missionIdController.dispose();
    _metadataController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Розпочати нове сканування'),
      content: SizedBox(
        width: 500,
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _missionIdController,
                decoration: const InputDecoration(
                  labelText: 'ID місії',
                  hintText: 'Введіть ID місії або створіть нову',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Введіть ID місії';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              BlocBuilder<DeviceBloc, DeviceState>(
                builder: (context, state) {
                  if (state is DeviceLoading) {
                    return const CircularProgressIndicator();
                  }

                  List<Device> devices = [];
                  if (state is DeviceLoaded) {
                    devices = state.devices;
                  }

                  return DropdownButtonFormField<String>(
                    decoration: const InputDecoration(
                      labelText: 'Пристрій',
                      border: OutlineInputBorder(),
                    ),
                    value: _selectedDeviceId,
                    items: devices.map((device) {
                      return DropdownMenuItem<String>(
                        value: device.id,
                        child: Text('${device.deviceType} (${device.serialNumber})'),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedDeviceId = value;
                      });
                    },
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Виберіть пристрій';
                      }
                      return null;
                    },
                  );
                },
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(
                  labelText: 'Тип сканування',
                  border: OutlineInputBorder(),
                ),
                value: _scanType,
                items: const [
                  DropdownMenuItem<String>(
                    value: 'standard',
                    child: Text('Стандартне'),
                  ),
                  DropdownMenuItem<String>(
                    value: 'detailed',
                    child: Text('Детальне'),
                  ),
                  DropdownMenuItem<String>(
                    value: 'quick',
                    child: Text('Швидке'),
                  ),
                ],
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      _scanType = value;
                    });
                  }
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _metadataController,
                decoration: const InputDecoration(
                  labelText: 'Метадані (JSON)',
                  border: OutlineInputBorder(),
                ),
                maxLines: 5,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Введіть метадані';
                  }
                  try {
                    // Перевірка валідності JSON
                    return null;
                  } catch (e) {
                    return 'Невалідний JSON: $e';
                  }
                },
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Скасувати'),
        ),
        ElevatedButton(
          onPressed: _startScan,
          child: const Text('Розпочати'),
        ),
      ],
    );
  }

  void _startScan() {
    if (_formKey.currentState!.validate()) {
      try {
        final Map<String, dynamic> metadata = {}; // В реальності тут має бути парсинг JSON

        context.read<ScanBloc>().add(
          ScanStarted(
            missionId: _missionIdController.text,
            deviceId: _selectedDeviceId!,
            scanType: _scanType,
            metadata: metadata,
          ),
        );

        Navigator.of(context).pop();
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Помилка: $e')),
        );
      }
    }
  }
}