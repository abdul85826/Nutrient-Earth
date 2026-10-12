import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum AppLanguage {
  english('en', 'English', 'English'),
  tamil('ta', 'Tamil', 'தமிழ்'),
  hindi('hi', 'Hindi', 'हिन्दी'),
  telugu('te', 'Telugu', 'తెలుగు'),
  spanish('es', 'Spanish', 'Español');

  final String code;
  final String englishName;
  final String nativeName;

  const AppLanguage(this.code, this.englishName, this.nativeName);

  static AppLanguage fromCode(String code) {
    return AppLanguage.values.firstWhere(
      (lang) => lang.code == code,
      orElse: () => AppLanguage.english,
    );
  }
}

class LanguageNotifier extends StateNotifier<AppLanguage> {
  static const String _prefKey = 'ne_app_language_code';

  LanguageNotifier() : super(AppLanguage.english) {
    _loadLanguage();
  }

  Future<void> _loadLanguage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedCode = prefs.getString(_prefKey);
      if (savedCode != null) {
        state = AppLanguage.fromCode(savedCode);
      }
    } catch (e) {
      debugPrint('[LanguageNotifier] Error loading language: $e');
    }
  }

  Future<void> setLanguage(AppLanguage language) async {
    state = language;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_prefKey, language.code);
    } catch (e) {
      debugPrint('[LanguageNotifier] Error saving language: $e');
    }
  }
}

final languageProvider = StateNotifierProvider<LanguageNotifier, AppLanguage>((ref) {
  return LanguageNotifier();
});

class NeStrings {
  NeStrings._();

  static String get(String key, AppLanguage lang) {
    final translations = _localizedStrings[lang] ?? _localizedStrings[AppLanguage.english]!;
    return translations[key] ?? _localizedStrings[AppLanguage.english]![key] ?? key;
  }

  static const Map<AppLanguage, Map<String, String>> _localizedStrings = {
    AppLanguage.english: {
      'app_title': 'Nutrient Earth',
      'tagline': 'Health Memory & Decision Intelligence',
      'ask_earth': 'Ask Earth anything about food, nutrients, or body...',
      'today': 'Today',
      'body': 'Body',
      'growth': 'Growth',
      'explore': 'Explore',
      'store': 'Store',
      'research_workspace': 'Research Workspace',
      'environmental_context': 'Ambient Environmental Context',
      'verified_evidence': 'Verified Clinical Evidence',
      'domain_breakdown': '5-Domain Intelligence Breakdown',
      'continue_with_google': 'Continue with Google',
      'guest_mode': 'Explore as Sovereign Guest',
      'switch_language': 'Language / மொழி / भाषा',
    },
    AppLanguage.tamil: {
      'app_title': 'நியூட்ரியன்ட் எர்த்',
      'tagline': 'உடல்நல நினைவகம் மற்றும் முடிவெடுக்கும் நுண்ணறிவு',
      'ask_earth': 'உணவு, சத்துக்கள், அல்லது உடல் பற்றி கேளுங்கள்...',
      'today': 'இன்று',
      'body': 'உடல்',
      'growth': 'வளர்ச்சி',
      'explore': 'ஆராய்க',
      'store': 'கடை',
      'research_workspace': 'ஆராய்ச்சி அரங்கம்',
      'environmental_context': 'சுற்றுச்சூழல் நிலை',
      'verified_evidence': 'சரிபார்க்கப்பட்ட சான்றுகள்',
      'domain_breakdown': '5-டொமைன் நுண்ணறிவு பகுப்பாய்வு',
      'continue_with_google': 'கூகிள் மூலம் தொடரவும்',
      'guest_mode': 'விருந்தினராக தொடரவும்',
      'switch_language': 'மொழி / Language',
    },
    AppLanguage.hindi: {
      'app_title': 'न्यूट्रिएंट अर्थ',
      'tagline': 'स्वास्थ्य स्मृति और निर्णय बुद्धिमत्ता',
      'ask_earth': 'भोजन, पोषक तत्वों या शरीर के बारे में कुछ भी पूछें...',
      'today': 'आज',
      'body': 'शरीर',
      'growth': 'विकास',
      'explore': 'अन्वेषण',
      'store': 'स्टोर',
      'research_workspace': 'शोध कार्यक्षेत्र',
      'environmental_context': 'पर्यावरणीय संदर्भ',
      'verified_evidence': 'सत्यापित नैदानिक साक्ष्य',
      'domain_breakdown': '5-डोमेन बुद्धिमत्ता विश्लेषण',
      'continue_with_google': 'Google के साथ जारी रखें',
      'guest_mode': 'अतिथि के रूप में अन्वेषण करें',
      'switch_language': 'भाषा / Language',
    },
    AppLanguage.telugu: {
      'app_title': 'న్యూట్రియెంట్ ఎర్త్',
      'tagline': 'ఆరోగ్య జ్ఞాపకశక్తి మరియు నిర్ణయ మేధస్సు',
      'ask_earth': 'ఆహారం, పోషకాలు లేదా శరీరం గురించి ఏదైనా అడగండి...',
      'today': 'ఈరోజు',
      'body': 'శరీరం',
      'growth': 'వృద్ధి',
      'explore': 'అన్వేషించండి',
      'store': 'స్టోర్',
      'research_workspace': 'పరిశోధనా కార్యక్షేత్రం',
      'environmental_context': 'పర్యావరణ సందర్భం',
      'verified_evidence': 'ధృవీకరించబడిన క్లినికల్ సాక్ష్యం',
      'domain_breakdown': '5-డొమైన్ ఇంటెలిజెన్స్ విశ్లేషణ',
      'continue_with_google': 'Google తో కొనసాగించండి',
      'guest_mode': 'అతిథిగా అన్వేషించండి',
      'switch_language': 'భాష / Language',
    },
    AppLanguage.spanish: {
      'app_title': 'Nutrient Earth',
      'tagline': 'Memoria de Salud e Inteligencia de Decisiones',
      'ask_earth': 'Pregunta a Earth sobre alimentos, nutrientes o el cuerpo...',
      'today': 'Hoy',
      'body': 'Cuerpo',
      'growth': 'Crecimiento',
      'explore': 'Explorar',
      'store': 'Tienda',
      'research_workspace': 'Espacio de Investigación',
      'environmental_context': 'Contexto Ambiental',
      'verified_evidence': 'Evidencia Clínica Verificada',
      'domain_breakdown': 'Desglose de Inteligencia de 5 Dominios',
      'continue_with_google': 'Continuar con Google',
      'guest_mode': 'Explorar como Invitado Soberano',
      'switch_language': 'Idioma / Language',
    },
  };
}
