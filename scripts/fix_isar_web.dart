import 'dart:io';

void main() {
  print('Running Isar JS Integer Fixer...');

  final dir = Directory('lib');
  final generatedFiles = dir.listSync(recursive: true)
      .where((file) => file.path.endsWith('.g.dart'));

  int totalFixes = 0;

  for (final file in generatedFiles) {
    if (file is File) {
      String content = file.readAsStringSync();
      
      // Match negative and positive integer literals after "id: "
      final regex = RegExp(r'id:\s*(-?\d+),');
      
      bool fileModified = false;
      
      content = content.replaceAllMapped(regex, (match) {
        final intStr = match.group(1)!;
        
        try {
          // Parse as BigInt
          final bigInt = BigInt.parse(intStr);
          
          // Max safe JS integer is 2^53 - 1 (9007199254740991)
          final maxSafe = BigInt.parse('9007199254740991');
          final minSafe = BigInt.parse('-9007199254740991');
          
          if (bigInt > maxSafe || bigInt < minSafe) {
            // Convert to double to get JS precision, then back to int literal
            final jsSafeDouble = bigInt.toDouble();
            
            // Format without exponential notation
            final jsSafeStr = jsSafeDouble.toStringAsFixed(0);
            
            print('Fixed in ${file.path}: $intStr -> $jsSafeStr');
            totalFixes++;
            fileModified = true;
            return 'id: $jsSafeStr,';
          }
        } catch (e) {
          print('Error parsing $intStr: $e');
        }
        
        return match.group(0)!; // No change
      });

      if (fileModified) {
        file.writeAsStringSync(content);
      }
    }
  }

  print('Done! Total fixes applied: $totalFixes');
}
