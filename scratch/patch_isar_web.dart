import 'dart:io';

void fixFile(String path) {
  final file = File(path);
  if (!file.existsSync()) {
    print('Not found: \$path');
    return;
  }
  var content = file.readAsStringSync();
  
  // Remove const modifiers that would conflict with runtime int.parse
  content = content.replaceAll('const CollectionSchema(', 'CollectionSchema(');
  content = content.replaceAll('const PropertySchema(', 'PropertySchema(');
  
  // Replace large integer literals assigned to 'id:' with int.parse()
  // We match 'id:' followed by optional whitespace, optional minus sign, and at least 15 digits.
  final regex = RegExp(r'id:\s*(-?\d{15,}),');
  content = content.replaceAllMapped(regex, (match) {
    return "id: int.parse('${match.group(1)}'),";
  });
  
  file.writeAsStringSync(content);
  print('Fixed \$path');
}

void main() {
  fixFile('lib/infrastructure/local/isar_schemas.g.dart');
  fixFile('lib/domain/models/biological_twin/biological_models.g.dart');
}
