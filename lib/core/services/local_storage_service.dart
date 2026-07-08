import 'local_storage_service_resolver.dart';

abstract class LocalStorageService {
  static final LocalStorageService _instance = getLocalStorageService();
  factory LocalStorageService() => _instance;

  Future<void> initialize();
  Future<void> saveIdentity({required String uuid, required bool isGuest});
  Future<void> saveUserProfile(String userId, Map<String, dynamic> userProfileMap);
  Future<Map<String, dynamic>?> readUserProfile(String userId);
  Future<void> saveBiologicalProfile(String userId, Map<String, dynamic> biologicalProfileMap);
  Future<Map<String, dynamic>?> readBiologicalProfile(String userId);
  Future<void> saveBiologicalEvent(String userId, Map<String, dynamic> eventMap);
  Future<List<Map<String, dynamic>>> readBiologicalEvents(String userId);
  Future<void> saveObservation(String userId, Map<String, dynamic> observationMap);
  Future<List<Map<String, dynamic>>> readObservations(String userId);
  Future<void> saveHealthIdentity(String userId, Map<String, dynamic> healthIdentityMap);
  Future<Map<String, dynamic>?> readHealthIdentity(String userId);
  Future<void> saveUserUnderstanding(String userId, Map<String, dynamic> data);
  Future<Map<String, dynamic>?> readUserUnderstanding(String userId);
  Future<void> saveRecommendation(String userId, Map<String, dynamic> recMap);
  Future<List<Map<String, dynamic>>> readRecommendations(String userId);
  Future<void> queueSyncJob(String collectionName, String recordId, String operation);
  Future<List<Map<String, dynamic>>> getPendingSyncJobs();
  Future<void> deleteSyncJob(String collectionName, String recordId);
  Future<void> saveGraphNodes(List<Map<String, dynamic>> nodes);
  Future<List<Map<String, dynamic>>> readGraphNodes();
  Future<void> saveGraphEdges(List<Map<String, dynamic>> edges);
  Future<List<Map<String, dynamic>>> readGraphEdges();
  Future<void> migrateGuestData(String guestUserId, String cloudUserId);
}
