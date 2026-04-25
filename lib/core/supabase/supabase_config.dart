class SupabaseConfig {
  static const String url = 'http://127.0.0.1:54321';
  static const String anonKey = 
      'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImRlZmF1bHQiLCJyb2xlIjoiYW5vbiIsImlhdCI6MTY3ODYyNjc2NiwiZXhwIjoxOTk0MjAyNzY2fQ.hR-c2qD2x3E7mZlW3PjQzVzXJm5-k2cZ5b4-xH3o3N0';

  static bool get isConfigured => url.isNotEmpty && anonKey.isNotEmpty;
}
