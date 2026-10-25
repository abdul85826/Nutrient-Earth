import 'package:intl/intl.dart';

enum DiurnalPeriod {
  morning,
  afternoon,
  evening,
  night,
}

class DiurnalContext {
  final DateTime now;
  final DiurnalPeriod period;
  final String formattedDate;
  final String greeting;
  final String solarCondition;
  final String illustrationAsset;

  const DiurnalContext({
    required this.now,
    required this.period,
    required this.formattedDate,
    required this.greeting,
    required this.solarCondition,
    required this.illustrationAsset,
  });
}

class DiurnalService {
  DiurnalService._();

  static DiurnalContext getContext({
    DateTime? currentTime,
    String? preferredName,
  }) {
    final now = currentTime ?? DateTime.now();
    final hour = now.hour;

    // Date formatted as 'WEEKDAY, D MMM YYYY' in uppercase (e.g. 'MONDAY, 14 OCT 2026')
    final datePattern = DateFormat('EEEE, d MMM yyyy');
    final formattedDate = datePattern.format(now).toUpperCase();

    final name = (preferredName != null && preferredName.trim().isNotEmpty)
        ? preferredName.trim()
        : 'Sarah';

    DiurnalPeriod period;
    String greeting;
    String solarCondition;

    if (hour >= 5 && hour < 12) {
      period = DiurnalPeriod.morning;
      greeting = 'Good morning,\n$name.';
      solarCondition = 'Radiant';
    } else if (hour >= 12 && hour < 17) {
      period = DiurnalPeriod.afternoon;
      greeting = 'Good afternoon,\n$name.';
      solarCondition = 'Golden hour';
    } else if (hour >= 17 && hour < 22) {
      period = DiurnalPeriod.evening;
      greeting = 'Good evening,\n$name.';
      solarCondition = 'Dusk';
    } else {
      period = DiurnalPeriod.night;
      greeting = 'Rest well,\n$name.';
      solarCondition = 'Nocturnal';
    }

    return DiurnalContext(
      now: now,
      period: period,
      formattedDate: formattedDate,
      greeting: greeting,
      solarCondition: solarCondition,
      illustrationAsset: 'assets/images/greeting_botanical.png',
    );
  }
}
