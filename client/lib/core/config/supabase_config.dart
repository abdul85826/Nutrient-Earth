class SupabaseConfig {
  static const String url = String.fromEnvironment(
    'SUPABASE_URL',
    defaultValue: 'https://esdhhbdzjmbdqstdsjro.supabase.co',
  );

  static const String anonKey = String.fromEnvironment(
    'SUPABASE_ANON_KEY',
    defaultValue:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImVzZGhoYmR6am1iZHFzdGRzanJvIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzY1MTA5NjIsImV4cCI6MjA5MjA4Njk2Mn0.dU-l3IqaVyRx8VD4rndgHnX6uN3TguOTStlCjKsb8pw',
  );

  static const String supabaseUrl = url;
  static const String supabaseAnonKey = anonKey;
  static const String publishableKey = anonKey;

  static bool get isConfigured => url.isNotEmpty && anonKey.isNotEmpty;
}
