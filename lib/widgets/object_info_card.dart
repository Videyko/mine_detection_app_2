import 'package:flutter/material.dart';
import 'package:mine_detection_client/models/detected_object.dart';

class ObjectInfoCard extends StatelessWidget {
  final DetectedObject object;

  const ObjectInfoCard({
    Key? key,
    required this.object,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '��\'��� #${object.id.substring(0, 8)}',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const Divider(),
            _buildInfoRow('��� ��\'����', _getObjectTypeName(object.objectType)),
            _buildInfoRow('������', object.latitude.toStringAsFixed(6)),
            _buildInfoRow('�������', object.longitude.toStringAsFixed(6)),
            _buildInfoRow('�������', '${object.depth.toStringAsFixed(2)} �'),
            _buildInfoRow('�����������', '${(object.confidence * 100).toStringAsFixed(1)}%'),
            _buildDangerLevelRow(object.dangerLevel),
            _buildInfoRow('�����������', _getVerificationStatusName(object.verificationStatus)),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                ElevatedButton(
                  onPressed: () {
                    // ��� �� ���� ����� ��� ������������ ��'����
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('ϳ���������'),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: () {
                    // ��� �� ���� ����� ��� ��������� ��'����
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('³�������'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.grey,
              ),
            ),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  Widget _buildDangerLevelRow(int dangerLevel) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          const SizedBox(
            width: 120,
            child: Text(
              'г���� ���������',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.grey,
              ),
            ),
          ),
          Expanded(
            child: Row(
              children: [
                for (int i = 0; i < 5; i++)
                  Icon(
                    Icons.warning_amber_rounded,
                    color: i < dangerLevel ? Colors.red : Colors.grey.shade300,
                    size: 20,
                  ),
                const SizedBox(width: 8),
                Text('$dangerLevel/5'),
              ],
            ),
          ),
        ],
      ),
    );
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

  String _getVerificationStatusName(String status) {
    switch (status) {
      case 'unverified':
        return '�����������';
      case 'confirmed':
        return 'ϳ����������';
      case 'dismissed':
        return '³�������';
      default:
        return status;
    }
  }
}