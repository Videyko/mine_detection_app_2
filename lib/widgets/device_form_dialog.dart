import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mine_detection_client/blocs/device/device_bloc.dart';
import 'package:mine_detection_client/models/device.dart';

class DeviceFormDialog extends StatefulWidget {
  final Device? device;

  const DeviceFormDialog({
    Key? key,
    this.device,
  }) : super(key: key);

  @override
  State<DeviceFormDialog> createState() => _DeviceFormDialogState();
}

class _DeviceFormDialogState extends State<DeviceFormDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _deviceTypeController;
  late TextEditingController _serialNumberController;
  late TextEditingController _configurationController;

  @override
  void initState() {
    super.initState();
    _deviceTypeController = TextEditingController(text: widget.device?.deviceType ?? '');
    _serialNumberController = TextEditingController(text: widget.device?.serialNumber ?? '');
    _configurationController = TextEditingController(
      text: widget.device != null
          ? _prettyJson(widget.device!.configuration)
          : '{\n  "sample_config_key": "sample_value"\n}',
    );
  }

  @override
  void dispose() {
    _deviceTypeController.dispose();
    _serialNumberController.dispose();
    _configurationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.device == null ? 'Новий пристрій' : 'Редагувати пристрій'),
      content: SizedBox(
        width: 500,
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _deviceTypeController,
                decoration: const InputDecoration(
                  labelText: 'Тип пристрою',
                  hintText: 'Наприклад: lidar_scanner',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Введіть тип пристрою';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _serialNumberController,
                decoration: const InputDecoration(
                  labelText: 'Серійний номер',
                  hintText: 'Наприклад: SN-12345',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Введіть серійний номер';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _configurationController,
                decoration: const InputDecoration(
                  labelText: 'Конфігурація (JSON)',
                  border: OutlineInputBorder(),
                ),
                maxLines: 10,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Введіть конфігурацію';
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
          onPressed: _saveDevice,
          child: const Text('Зберегти'),
        ),
      ],
    );
  }

  void _saveDevice() {
    if (_formKey.currentState!.validate()) {
      try {
        final Map<String, dynamic> config = {}; // В реальності тут має бути парсинг JSON

        if (widget.device == null) {
          // Створення нового пристрою
          context.read<DeviceBloc>().add(
            DeviceCreated(
              deviceType: _deviceTypeController.text,
              serialNumber: _serialNumberController.text,
              configuration: config,
            ),
          );
        } else {
          // Оновлення існуючого пристрою
          // Тут має бути додана логіка, якщо потрібно оновлювати пристрої
        }

        Navigator.of(context).pop();
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Помилка: $e')),
        );
      }
    }
  }

  String _prettyJson(dynamic json) {
    // В реальності тут має бути красиве форматування JSON
    return json.toString();
  }
}