import 'local_storage_service.dart';
import '../bootstrap/identity_manager.dart';

class BaselineState {
  final int daysObserved;
  final int totalSignals;
  final String phaseTitle;
  final String phaseDescription;
  final double progressPercentage;
  final List<Map<String, dynamic>> latestObservations;

  BaselineState({
    required this.daysObserved,
    required this.totalSignals,
    required this.phaseTitle,
    required this.phaseDescription,
    required this.progressPercentage,
    required this.latestObservations,
  });
}

class BaselineEngine {
  static final BaselineEngine _instance = BaselineEngine._internal();
  factory BaselineEngine() => _instance;
  BaselineEngine._internal();

  String get engineName => 'baseline_engine';
  String get version => '1.0.0';

  Future<BaselineState> calculateBaseline(List<Map<String, dynamic>>? input) async {
    final userId = IdentityManager().currentUuid;
    if (userId.isEmpty) {
      return BaselineState(
        daysObserved: 0,
        totalSignals: 0,
        phaseTitle: 'Unknown',
        phaseDescription: 'No user identity found.',
        progressPercentage: 0.0,
        latestObservations: [],
      );
    }

    try {
      List<Map<String, dynamic>> timeline = [];
      if (input != null) {
        timeline = List<Map<String, dynamic>>.from(input);
      } else {
        timeline = await LocalStorageService().readBiologicalEvents(userId);
      }
      
      final checkIns = timeline.where((e) => e['event_type'] == 'daily_check_in').toList();
      
      final uniqueDays = <String>{};
      for (var event in checkIns) {
        if (event['occurred_at'] != null) {
          try {
            final dt = DateTime.parse(event['occurred_at'].toString());
            uniqueDays.add('${dt.year}-${dt.month}-${dt.day}');
          } catch (_) {}
          }
      }
      
      final daysObserved = uniqueDays.length;
      
      String phaseTitle;
      String phaseDescription;
      double progress;
      
      if (daysObserved == 0) {
        phaseTitle = 'Day 1: Collect';
        phaseDescription = 'Awaiting your first check-in to begin learning.';
        progress = 0.0;
      } else if (daysObserved == 1) {
        phaseTitle = 'Day 2: Compare';
        phaseDescription = 'We have one day of data. Need another to compare.';
        progress = 0.15;
      } else if (daysObserved == 2) {
        phaseTitle = 'Day 3: Detect Trends';
        phaseDescription = 'Looking for early patterns in your daily data.';
        progress = 0.3;
      } else if (daysObserved < 7) {
        phaseTitle = 'Week 1: Pattern Recognition';
        phaseDescription = 'Building a reliable statistical picture of your habits.';
        progress = 0.3 + ((daysObserved - 2) * 0.1); 
      } else if (daysObserved < 30) {
        phaseTitle = 'Week 2+: Establishing Baseline';
        phaseDescription = 'Your baseline is stabilizing. Precision is increasing.';
        progress = 0.8 + ((daysObserved - 7) * 0.008); 
      } else {
        phaseTitle = 'Month 1+: Personalization Active';
        phaseDescription = 'We now have a strong understanding of your baseline health.';
        progress = 1.0;
      }
      
      return BaselineState(
        daysObserved: daysObserved,
        totalSignals: timeline.length,
        phaseTitle: phaseTitle,
        phaseDescription: phaseDescription,
        progressPercentage: progress.clamp(0.0, 1.0),
        latestObservations: timeline.take(5).toList(),
      );
    } catch (e) {
      return BaselineState(
        daysObserved: 0,
        totalSignals: 0,
        phaseTitle: 'Unknown',
        phaseDescription: 'Failed to calculate baseline: $e',
        progressPercentage: 0.0,
        latestObservations: [],
      );
    }
  }
}
