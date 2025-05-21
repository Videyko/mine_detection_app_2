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
              'Об\'єкт #${object.id.substring(0, 8)}',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const Divider(),
            _buildInfoRow('Тип об\'єкта', _getObjectTypeName(object.objectType)),
            _buildInfoRow('Широта', object.latitude.toStringAsFixed(6)),
            _buildInfoRow('Довгота', object.longitude.toStringAsFixed(6)),
            _buildInfoRow('Глибина', '${object.depth.toStringAsFixed(2)} м'),
            _buildInfoRow('Достовірність', '${(object.confidence * 100).toStringAsFixed(1)}%'),
            _buildDangerLevelRow(object.dangerLevel),
            _buildInfoRow('Верифікація', _getVerificationStatusName(object.verificationStatus)),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                ElevatedButton(
                  onPressed: () {
                    // Тут має бути логіка для підтвердження об'єкта
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Підтвердити'),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: () {
                    // Тут має бути логіка для відхилення об'єкта
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Відхилити'),
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
              'Рівень небезпеки',
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
        return 'Протипіхотна міна';
      case 'anti_tank_mine':
        return 'Протитанкова міна';
      case 'unknown':
        return 'Невідомий тип';
      default:
        return type;
    }
  }

  String _getVerificationStatusName(String status) {
    switch (status) {
      case 'unverified':
        return 'Неперевірено';
      case 'confirmed':
        return 'Підтверджено';
      case 'dismissed':
        return 'Відхилено';
      default:
        return status;
    }
  }
}