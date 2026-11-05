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

    final hasName = preferredName != null && preferredName.trim().isNotEmpty;
    final name = hasName ? preferredName.trim() : null;

    DiurnalPeriod period;
    String greeting;
    String solarCondition;

    if (hour >= 5 && hour < 12) {
      period = DiurnalPeriod.morning;
      greeting = name != null ? 'Good morning,\n$name.' : 'Good morning.';
      solarCondition = 'Radiant';
    } else if (hour >= 12 && hour < 17) {
      period = DiurnalPeriod.afternoon;
      greeting = name != null ? 'Good afternoon,\n$name.' : 'Good afternoon.';
      solarCondition = 'Golden hour';
    } else if (hour >= 17 && hour < 22) {
      period = DiurnalPeriod.evening;
      greeting = name != null ? 'Good evening,\n$name.' : 'Good evening.';
      solarCondition = 'Dusk';
    } else {
      period = DiurnalPeriod.night;
      greeting = name != null ? 'Rest well,\n$name.' : 'Rest well.';
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
