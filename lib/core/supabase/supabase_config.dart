class SupabaseConfig {
  static const String url = 'https://esdhhbdzjmbdqstdsjro.supabase.co';

  static const String anonKey =
      'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImVzZGhoYmR6am1iZHFzdGRzanJvIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzY1MTA5NjIsImV4cCI6MjA5MjA4Njk2Mn0.dU-l3IqaVyRx8VD4rndgHnX6uN3TguOTStlCjKsb8pw';

  static bool get isConfigured => url.isNotEmpty && anonKey.isNotEmpty;
}
