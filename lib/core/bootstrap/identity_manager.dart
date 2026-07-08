import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../services/local_storage_service.dart';

enum AuthMode {
  guest,
  cloud,
}

class IdentityManager {
  static final IdentityManager _instance = IdentityManager._internal();
  factory IdentityManager() => _instance;
  IdentityManager._internal();

  static const String _uuidKey = 'ne_device_uuid';
  static const String _modeKey = 'ne_auth_mode';
  
  String _currentUuid = '';
  AuthMode _currentMode = AuthMode.guest;

  String get currentUuid => _currentUuid;
  AuthMode get currentMode => _currentMode;
  bool get isGuest => _currentMode == AuthMode.guest;

  /// STEP 2 of Bootstrap: Initialize device identity
  Future<void> initialize() async {
    final prefs = await SharedPreferences.getInstance();
    
    // Check if cloud session exists (including anonymous Supabase sessions)
    final session = Supabase.instance.client.auth.currentSession;
    final hasSupabaseSession = session != null;
    
    if (hasSupabaseSession) {
      final user = session.user;
      final isAnonymous = user.isAnonymous;
      
      _currentMode = isAnonymous ? AuthMode.guest : AuthMode.cloud;
      _currentUuid = user.id;
      
      await prefs.setString(_uuidKey, user.id);
      await prefs.setString(_modeKey, isAnonymous ? 'guest' : 'cloud');
      debugPrint('[IDENTITY] Session active. UUID: $_currentUuid, Mode: ${_currentMode.name}');
    } else {
      final savedMode = prefs.getString(_modeKey);
      if (savedMode == 'guest') {
        _currentMode = AuthMode.guest;
        _currentUuid = prefs.getString(_uuidKey) ?? const Uuid().v4();
        await prefs.setString(_uuidKey, _currentUuid);
        debugPrint('[IDENTITY] Restored Guest UUID: $_currentUuid');
      } else {
        // First launch or cleared prefs: unauthenticated!
        // We do NOT save _modeKey or _uuidKey to SharedPreferences yet.
        _currentMode = AuthMode.guest; // Internal default
        _currentUuid = prefs.getString(_uuidKey) ?? '';
        if (_currentUuid.isEmpty) {
          _currentUuid = const Uuid().v4();
        }
        debugPrint('[IDENTITY] Unauthenticated boot. Internal UUID: $_currentUuid (Not saved as preference yet)');
      }
    }

    // Persist to Isar only if a mode was chosen (not during initial unauthenticated state)
    final savedMode = prefs.getString(_modeKey);
    if (savedMode != null) {
      await _persistIdentityToIsar();
    }
  }

  /// Guest -> Cloud Migration Pipeline Entry Point
  Future<void> upgradeToCloudIdentity(String newCloudUuid) async {
    debugPrint('[IDENTITY MIGRATION] Starting migration from Guest $_currentUuid to Cloud $newCloudUuid');
    
    _currentUuid = newCloudUuid;
    _currentMode = AuthMode.cloud;
    
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_uuidKey, newCloudUuid);
    await prefs.setString(_modeKey, 'cloud');
    
    // Persist to Isar
    await _persistIdentityToIsar();
  }

  Future<void> _persistIdentityToIsar() async {
    await LocalStorageService().saveIdentity(uuid: _currentUuid, isGuest: isGuest);
  }
}
