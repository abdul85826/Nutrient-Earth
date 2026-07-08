import 'dart:io';

void fixFile(String path) {
  final file = File(path);
  if (!file.existsSync()) return;
  var content = file.readAsStringSync();
  
  // Remove const modifiers from the variable declarations for Schemas
  final schemaRegex = RegExp(r'const (\w+Schema)\s*=');
  content = content.replaceAllMapped(schemaRegex, (match) {
    return 'final ${match.group(1)} =';
  });

  file.writeAsStringSync(content);
  print('Removed const from variables in $path');
}

void main() {
  fixFile('lib/infrastructure/local/isar_schemas.g.dart');
  fixFile('lib/domain/models/biological_twin/biological_models.g.dart');
}
