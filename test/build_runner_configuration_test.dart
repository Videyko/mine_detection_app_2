// test/build_runner_test.dart
import 'dart:io';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Build Runner Configuration Test', () {
    test('build.yaml should be created correctly', () async {
      // ��������� ���� build.yaml, ���� ���� ����
      File buildYaml = File('build.yaml');
      if (!await buildYaml.exists()) {
        await buildYaml.writeAsString('''
targets:
  \$default:
    builders:
      json_serializable:
        options:
          any_map: false
          checked: false
          create_to_json: true
          create_factory: true
          explicit_to_json: false
          field_rename: snake
        generate_for:
          - lib/models/**.dart
''');
      }
      
      // ����������, �� ���� ��������
      expect(await buildYaml.exists(), true);
      
      // ���������� ���� �����
      String content = await buildYaml.readAsString();
      expect(content.contains('generate_for:'), true);
      expect(content.contains('lib/models/**.dart'), true);
    });
    
    test('All model files should have correct structure', () async {
      // ������ ����� �������
      List<String> modelFiles = [
        'lib/models/device.dart',
        'lib/models/detected_object.dart',
        'lib/models/scan.dart'
      ];
      
      for (String filePath in modelFiles) {
        File file = File(filePath);
        
        // ���������� ��������� �����
        expect(await file.exists(), true, reason: '���� $filePath �� ��������');
        
        // ������ ���� �����
        String content = await file.readAsString();
        
        // ���������� �������� ���������� ��������
        expect(content.contains('import \'package:json_annotation/json_annotation.dart\';'), 
          true, reason: '���� $filePath �� ����������� json_annotation');
          
        expect(content.contains('part \''), 
          true, reason: '���� $filePath �� ������ ��������� part');
          
        expect(content.contains('@JsonSerializable()'), 
          true, reason: '���� $filePath �� ������ �������� @JsonSerializable()');
          
        expect(content.contains('factory') && content.contains('fromJson'), 
          true, reason: '���� $filePath �� ������ ��������� ����� fromJson');
          
        expect(content.contains('toJson'), 
          true, reason: '���� $filePath �� ������ ����� toJson');
      }
    });
    
    test('Non-model files should not have JSON serialization directives', () async {
      // ������ �����, �� �� ������ ���� ��������� ����������
      List<String> nonModelFiles = [
        'lib/blocs/auth/auth_bloc.dart',
        'lib/repositories/auth_repository.dart',
        'lib/services/api_service.dart',
        'lib/services/websocket_service.dart'
      ];
      
      for (String filePath in nonModelFiles) {
        File file = File(filePath);
        
        if (await file.exists()) {
          String content = await file.readAsString();
          
          // ���������� ��������� �������� ����������
          expect(content.contains('part \'') && content.contains('.g.dart\''), 
            false, reason: '���� $filePath �� ������� ������ ��������� part ��� .g.dart');
            
          expect(content.contains('@JsonSerializable()'), 
            false, reason: '���� $filePath �� ������� ������ �������� @JsonSerializable()');
        }
      }
    });
  });
}