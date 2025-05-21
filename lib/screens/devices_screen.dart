// TODO Implement this library.import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:mine_detection_app_2/blocs/device/device_bloc.dart';
import 'package:mine_detection_app_2/models/device.dart';
import 'package:mine_detection_app_2/widgets/device_form_dialog.dart';

class DevicesScreen extends StatefulWidget {
  const DevicesScreen({Key? key}) : super(key: key);

  @override
  State<DevicesScreen> createState() => _DevicesScreenState();
}

class _DevicesScreenState extends State<DevicesScreen> {
  @override
  void initState() {
    super.initState();
    context.read<DeviceBloc>().add(const DevicesFetched());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  '�������',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: () => _showCreateDeviceDialog(context),
                  icon: const Icon(Icons.add),
                  label: const Text('����� �������'),
                ),
              ],
            ),
          ),
          Expanded(
            child: BlocConsumer<DeviceBloc, DeviceState>(
              listener: (context, state) {
                if (state is DeviceOperationSuccess) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(state.message)),
                  );
                } else if (state is DeviceFailure) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(state.message)),
                  );
                }
              },
              builder: (context, state) {
                if (state is DeviceLoading) {
                  return const Center(child: CircularProgressIndicator());
                } else if (state is DeviceLoaded) {
                  return _buildDevicesList(state.devices);
                } else if (state is DeviceFailure) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text('�������: ${state.message}'),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () => context.read<DeviceBloc>().add(const DevicesFetched()),
                          child: const Text('���������� �����'),
                        ),
                      ],
                    ),
                  );
                }
                return const SizedBox();
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDevicesList(List<Device> devices) {
    if (devices.isEmpty) {
      return const Center(
        child: Text('���� ������������� ��������'),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Card(
        child: DataTable(
          columns: const [
            DataColumn(label: Text('���')),
            DataColumn(label: Text('������� �����')),
            DataColumn(label: Text('������')),
            DataColumn(label: Text('������ �\'�������')),
            DataColumn(label: Text('ĳ�')),
          ],
          rows: devices.map((device) {
            return DataRow(
              cells: [
                DataCell(Text(device.deviceType)),
                DataCell(Text(device.serialNumber)),
                DataCell(
                  Chip(
                    label: Text(_getStatusLabel(device.status)),
                    backgroundColor: _getStatusColor(device.status),
                  ),
                ),
                DataCell(Text(
                  DateFormat('dd.MM.yyyy HH:mm').format(device.lastConnectionAt),
                )),
                DataCell(
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit),
                        onPressed: () => _showEditDeviceDialog(context, device),
                        tooltip: '����������',
                      ),
                      IconButton(
                        icon: const Icon(Icons.power_settings_new),
                        onPressed: () => _showChangeStatusDialog(context, device),
                        tooltip: '������ ������',
                      ),
                    ],
                  ),
                ),
              ],
            );
          }).toList(),
        ),
      ),
    );
  }

  void _showCreateDeviceDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => const DeviceFormDialog(),
    );
  }

  void _showEditDeviceDialog(BuildContext context, Device device) {
    showDialog(
      context: context,
      builder: (context) => DeviceFormDialog(device: device),
    );
  }

  void _showChangeStatusDialog(BuildContext context, Device device) {
    final availableStatuses = [
      'active',
      'inactive',
      'maintenance',
    ];

    showDialog(
        context: context,
        builder: (context) => AlertDialog(
        title: const Text('������ ������'),
        content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
        Text('�������� ������: ${_getStatusLabel(device.status)}'),
    const SizedBox(height: 16),
    DropdownButtonFormField<String>(
    decoration: const InputDecoration(
    labelText: '����� ������',
    border: OutlineInputB
      decoration: const InputDecoration(
      labelText: '����� ������',
      border: OutlineInputBorder(),
    ),
      value: device.status,
      items: availableStatuses.map((status) {
        return DropdownMenuItem<String>(
          value: status,
          child: Text(_getStatusLabel(status)),
        );
      }).toList(),
      onChanged: (value) {
        if (value != null) {
          context.read<DeviceBloc>().add(
            DeviceStatusUpdated(
              id: device.id,
              status: value,
            ),
          );
          Navigator.of(context).pop();
        }
      },
    ),
            ],
        ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('���������'),
            ),
          ],
        ),
    );
  }

  String _getStatusLabel(String status) {
    switch (status) {
      case 'active':
        return '��������';
      case 'inactive':
        return '����������';
      case 'maintenance':
        return '��������������';
      default:
        return status;
    }
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'active':
        return Colors.green.shade100;
      case 'inactive':
        return Colors.grey.shade300;
      case 'maintenance':
        return Colors.orange.shade100;
      default:
        return Colors.grey.shade100;
    }
  }
}