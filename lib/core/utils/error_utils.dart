
/// Translates technical runtime exceptions (networks, timeouts, database caches)
/// into user-friendly messages for SnackBars and Splash views.
String getFriendlyErrorMessage(dynamic error) {
  if (error == null) return 'An unknown error occurred.';
  final str = error.toString().toLowerCase();
  
  if (str.contains('socketexception') || 
      str.contains('failed host lookup') || 
      str.contains('network') || 
      str.contains('connection failed') || 
      str.contains('errno 110') || 
      str.contains('errno 111')) {
    return 'No Internet Connection. Please check your network and try again.';
  }
  
  if (str.contains('database_schema_mismatch') || 
      str.contains('schema cache') || 
      str.contains('pg_types') || 
      str.contains('relation') ||
      (str.contains('400') && str.contains('users'))) {
    return 'Database is undergoing maintenance. Please try again in a few minutes.';
  }
  
  if (str.contains('auth') || 
      str.contains('invalid login') || 
      str.contains('credentials') || 
      str.contains('sign-in') || 
      str.contains('login failed') || 
      str.contains('jwt')) {
    return 'Sign-in failed. Please check your credentials and try again.';
  }
  
  if (str.contains('permission_denied') || 
      str.contains('permission denied') || 
      str.contains('access denied')) {
    return 'Permission Denied. Please grant permissions in your device settings.';
  }
  
  if (str.contains('timeout') || str.contains('timed out')) {
    return 'Connection timed out. Please try again.';
  }
  
  if (str.contains('profile incomplete') || str.contains('incomplete profile')) {
    return 'Profile Incomplete. Please complete onboarding to access the dashboard.';
  }
  
  if (str.contains('sync') || str.contains('synchronization')) {
    return 'Sync failed. Your data is safely stored locally and will sync when online.';
  }
  
  return 'An unexpected error occurred. Please try again.';
}
