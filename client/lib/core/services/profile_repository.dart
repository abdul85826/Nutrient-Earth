// ==============================================================================
// Nutrient Earth — Profile Repository
// Retrieves and persists authorized user profile data from public.profiles in Supabase.
// Never fabricates mock profiles or returns fictional health data.
// ==============================================================================

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../config/supabase_config.dart';
import '../domain/personalization/user_profile_context.dart';

abstract class ProfileRepository {
  Future<UserProfileContext?> getCurrentUserProfile();
  Future<bool> saveUserProfile(UserProfileContext profile);
}

class SupabaseProfileRepository implements ProfileRepository {
  const SupabaseProfileRepository();

  @override
  Future<UserProfileContext?> getCurrentUserProfile() async {
    final client = SupabaseConfig.client;
    if (client == null) return null;

    final user = client.auth.currentUser;
    if (user == null) return null;

    try {
      final data = await client
          .from('profiles')
          .select()
          .eq('user_id', user.id)
          .maybeSingle();

      if (data == null) return null;
      return UserProfileContext.fromJson(Map<String, dynamic>.from(data));
    } catch (_) {
      // Graceful error recovery: Return null to signal unauthenticated or missing profile
      return null;
    }
  }

  @override
  Future<bool> saveUserProfile(UserProfileContext profile) async {
    final client = SupabaseConfig.client;
    if (client == null) return false;

    final user = client.auth.currentUser;
    if (user == null) return false;

    try {
      // Enforce tenant isolation: User ID must match authenticated caller
      final payload = Map<String, dynamic>.from(profile.toJson());
      payload['user_id'] = user.id;

      await client.from('profiles').upsert(payload);
      return true;
    } catch (_) {
      return false;
    }
  }
}

final profileRepositoryProvider = Provider<ProfileRepository>((ref) {
  return const SupabaseProfileRepository();
});

/// Asynchronous state provider reflecting the authentic user's profile context.
/// Emits null when signed-out or when the profile is not yet created.
final currentProfileProvider = FutureProvider<UserProfileContext?>((ref) async {
  final repository = ref.watch(profileRepositoryProvider);
  return repository.getCurrentUserProfile();
});
