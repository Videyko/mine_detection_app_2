// test/build_runner_test.dart
import 'dart:io';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Build Runner Configuration Test', () {
    test('build.yaml should be created correctly', () async {
      // Створюємо файл build.yaml, якщо його немає
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
      
      // Перевіряємо, що файл створено
      expect(await buildYaml.exists(), true);
      
      // Перевіряємо вміст файлу
      String content = await buildYaml.readAsString();
      expect(content.contains('generate_for:'), true);
      expect(content.contains('lib/models/**.dart'), true);
    });
    
    test('All model files should have correct structure', () async {
      // Перелік файлів моделей
      List<String> modelFiles = [
        'lib/models/device.dart',
        'lib/models/detected_object.dart',
        'lib/models/scan.dart'
      ];
      
      for (String filePath in modelFiles) {
        File file = File(filePath);
        
        // Перевіряємо існування файлу
        expect(await file.exists(), true, reason: 'Файл $filePath має існувати');
        
        // Читаємо вміст файлу
        String content = await file.readAsString();
        
        // Перевіряємо наявність необхідних елементів
        expect(content.contains('import \'package:json_annotation/json_annotation.dart\';'), 
          true, reason: 'Файл $filePath має імпортувати json_annotation');
          
        expect(content.contains('part \''), 
          true, reason: 'Файл $filePath має містити директиву part');
          
        expect(content.contains('@JsonSerializable()'), 
          true, reason: 'Файл $filePath має містити анотацію @JsonSerializable()');
          
        expect(content.contains('factory') && content.contains('fromJson'), 
          true, reason: 'Файл $filePath має містити фабричний метод fromJson');
          
        expect(content.contains('toJson'), 
          true, reason: 'Файл $filePath має містити метод toJson');
      }
    });
    
    test('Non-model files should not have JSON serialization directives', () async {
      // Перелік файлів, які не повинні мати директиви серіалізації
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
          
          // Перевіряємо відсутність директив серіалізації
          expect(content.contains('part \'') && content.contains('.g.dart\''), 
            false, reason: 'Файл $filePath не повинен містити директиву part для .g.dart');
            
          expect(content.contains('@JsonSerializable()'), 
            false, reason: 'Файл $filePath не повинен містити анотацію @JsonSerializable()');
        }
      }
    });
  });
}