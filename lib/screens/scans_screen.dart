import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:mine_detection_app_2/blocs/scan/scan_bloc.dart';
import 'package:mine_detection_app_2/models/scan.dart';
import 'package:mine_detection_app_2/screens/scan_details_screen.dart';
import 'package:mine_detection_app_2/widgets/scan_form_dialog.dart';

class ScansScreen extends StatefulWidget {
  const ScansScreen({Key? key}) : super(key: key);

  @override
  State<ScansScreen> createState() => _ScansScreenState();
}

class _ScansScreenState extends State<ScansScreen> {
  @override
  void initState() {
    super.initState();
    context.read<ScanBloc>().add(const ScansFetched());
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
                  '����������',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: () => _showStartScanDialog(context),
                  icon: const Icon(Icons.play_arrow),
                  label: const Text('��������� ����������'),
                ),
              ],
            ),
          ),
          Expanded(
            child: BlocConsumer<ScanBloc, ScanState>(
              listener: (context, state) {
                if (state is ScanOperationSuccess) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(state.message)),
                  );

                  // ���� ��������� ���� ����������, ���������� �� ���� �������
                  if (state.scan != null) {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => ScanDetailsScreen(scan: state.scan!),
                      ),
                    );
                  }
                } else if (state is ScanFailure) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(state.message)),
                  );
                }
              },
              builder: (context, state) {
                if (state is ScanLoading) {
                  return const Center(child: CircularProgressIndicator());
                } else if (state is ScansLoaded) {
                  return _buildScansList(state.scans);
                } else if (state is ScanFailure) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text('�������: ${state.message}'),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () => context.read<ScanBloc>().add(const ScansFetched()),
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

  Widget _buildScansList(List<Scan> scans) {
    if (scans.isEmpty) {
      return const Center(
        child: Text('���� ������� ���������'),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Card(
        child: DataTable(
          columns: const [
            DataColumn(label: Text('̳��')),
            DataColumn(label: Text('�������')),
            DataColumn(label: Text('�������')),
            DataColumn(label: Text('����������')),
            DataColumn(label: Text('������')),
            DataColumn(label: Text('ĳ�')),
          ],
          rows: scans.map((scan) {
            return DataRow(
              cells: [
                DataCell(Text(scan.missionId)),
                DataCell(Text(scan.deviceId)),
                DataCell(Text(
                  DateFormat('dd.MM.yyyy HH:mm').format(scan.startTime),
                )),
                DataCell(scan.endTime != null
                    ? Text(DateFormat('dd.MM.yyyy HH:mm').format(scan.endTime!))
                    : const Text('-')),
                DataCell(
                  Chip(
                    label: Text(_getScanStatusLabel(scan.status)),
                    backgroundColor: _getScanStatusColor(scan.status),
                  ),
                ),
                DataCell(
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.visibility),
                        onPressed: () => _navigateToScanDetails(context, scan),
                        tooltip: '�����������',
                      ),
                      if (scan.status == 'in_progress')
                        IconButton(
                          icon: const Icon(Icons.stop),
                          onPressed: () => _showEndScanDialog(context, scan),
                          tooltip: '���������',
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

  void _showStartScanDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => const ScanFormDialog(),
    );
  }

  void _showEndScanDialog(BuildContext context, Scan scan) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('��������� ����������'),
        content: const Text('�� �������, �� ������ ��������� �� ����������?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('���������'),
          ),
          TextButton(
            onPressed: () {
              context.read<ScanBloc>().add(ScanEnded(scanId: scan.id));
              Navigator.of(context).pop();
            },
            child: const Text('���������'),
          ),
        ],
      ),
    );
  }

  void _navigateToScanDetails(BuildContext context, Scan scan) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => ScanDetailsScreen(scan: scan),
      ),
    );
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
}