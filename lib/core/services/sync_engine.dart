import 'dart:async';
import 'dart:math';

enum ConflictStrategy {
  lastWriteWins,
  timelineMerge,
  serverWins
}

class SyncEngine {
  final _offlineQueue = <SyncJob>[];
  bool _isSyncing = false;

  /// Kicks off the background sync process with exponential backoff
  Future<void> startSyncLoop() async {
    if (_isSyncing) return;
    _isSyncing = true;

    int retryCount = 0;
    while (_offlineQueue.isNotEmpty) {
      final job = _offlineQueue.first;
      try {
        await _processJob(job);
        _offlineQueue.removeAt(0);
        retryCount = 0; // Reset on success
      } catch (e) {
        retryCount++;
        final backoffMs = min(1000 * pow(2, retryCount), 60000).toInt(); // Max 60s
        await Future.delayed(Duration(milliseconds: backoffMs));
      }
    }
    _isSyncing = false;
  }

  void enqueue(SyncJob job) {
    _offlineQueue.add(job);
    startSyncLoop();
  }

  Future<void> _processJob(SyncJob job) async {
    // Attempt to push to Supabase
    // If conflict detected (e.g., HTTP 409 or version mismatch):
    // _resolveConflict(job);
  }

  // void _resolveConflict(SyncJob localJob) {
  //   const strategy = ConflictStrategy.lastWriteWins; // Default
  //   
  //   switch (strategy) {
  //     case ConflictStrategy.lastWriteWins:
  //       // Compare timestamps, keep newest
  //       break;
  //     case ConflictStrategy.timelineMerge:
  //       // Merge arrays (e.g., events) chronologically
  //       break;
  //     case ConflictStrategy.serverWins:
  //       // Discard local, keep server
  //       break;
  //   }
  // }

  Future<void> migrateGuestToCloud(String oldGuestId, String newCloudUserId) async {
    // 1. Scan all local tables (Isar)
    // 2. Remap 'guestId' records to have 'userId' = newCloudUserId
    // 3. Add all remapped records to the offlineQueue as SyncJobs
    // 4. Trigger startSyncLoop()
  }

  void normalizeTimestamps() {
    // Ensure all queued jobs use UTC before sending to cloud
  }
}

class SyncJob {
  final String collection;
  final String recordId;
  final String operation; // insert, update, delete
  final Map<String, dynamic> payload;

  SyncJob(this.collection, this.recordId, this.operation, this.payload);
}
