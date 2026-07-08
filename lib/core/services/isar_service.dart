import 'package:isar/isar.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final isarServiceProvider = Provider<IsarService>((ref) {
  return IsarService();
});

class IsarService {
  late Future<Isar> db;

  IsarService() {
    db = openDB();
  }

  Future<Isar> openDB() async {
    final instance = Isar.getInstance();
    if (instance != null) {
      return instance;
    }
    throw UnsupportedError('Isar is not initialized or not supported on this platform.');
  }
}
