/// Observability Framework for Nutrient Earth BIOS.
///
/// Purpose: Centralize all structured logging, metrics collection, and
/// distributed tracing infrastructure for production observability.
///
/// Responsibilities:
/// - Structured logging with severity levels
/// - Metric counters, gauges, and histograms
/// - Trace context propagation across async boundaries
/// - Engine performance monitoring
///
/// Future expansion:
/// - Sentry integration for error reporting
/// - OpenTelemetry trace export
/// - Prometheus metrics endpoint
/// - DataDog/Grafana adapter
library;

import 'dart:developer' as developer;

// ─── Logging ─────────────────────────────────────────────────────────────────

enum LogLevel { debug, info, warning, error, critical }

class LogEntry {
  final LogLevel level;
  final String component;
  final String message;
  final DateTime timestamp;
  final Map<String, dynamic>? context;
  final Object? error;
  final StackTrace? stackTrace;

  const LogEntry({
    required this.level,
    required this.component,
    required this.message,
    required this.timestamp,
    this.context,
    this.error,
    this.stackTrace,
  });

  String toStructuredString() {
    final parts = [
      '[${level.name.toUpperCase()}]',
      '[$component]',
      message,
      if (context != null) context.toString(),
    ];
    return parts.join(' ');
  }
}

/// Central structured logger. All components should use this instead of print().
class BIOSLogger {
  static final BIOSLogger _instance = BIOSLogger._internal();
  factory BIOSLogger() => _instance;
  BIOSLogger._internal();

  static BIOSLogger get instance => _instance;

  final List<LogEntry> _recentLogs = [];
  static const int _maxRecentLogs = 200;

  LogLevel _minimumLevel = LogLevel.debug;

  void setMinimumLevel(LogLevel level) => _minimumLevel = level;

  void _log(LogLevel level, String component, String message,
      {Map<String, dynamic>? context, Object? error, StackTrace? stackTrace}) {
    if (level.index < _minimumLevel.index) return;

    final entry = LogEntry(
      level: level,
      component: component,
      message: message,
      timestamp: DateTime.now(),
      context: context,
      error: error,
      stackTrace: stackTrace,
    );

    _recentLogs.add(entry);
    if (_recentLogs.length > _maxRecentLogs) _recentLogs.removeAt(0);

    developer.log(
      entry.toStructuredString(),
      name: component,
      level: _dartLogLevel(level),
      error: error,
      stackTrace: stackTrace,
    );
  }

  int _dartLogLevel(LogLevel level) {
    switch (level) {
      case LogLevel.debug: return 500;
      case LogLevel.info: return 800;
      case LogLevel.warning: return 900;
      case LogLevel.error: return 1000;
      case LogLevel.critical: return 1200;
    }
  }

  void debug(String component, String message, {Map<String, dynamic>? context}) =>
      _log(LogLevel.debug, component, message, context: context);

  void info(String component, String message, {Map<String, dynamic>? context}) =>
      _log(LogLevel.info, component, message, context: context);

  void warning(String component, String message, {Map<String, dynamic>? context}) =>
      _log(LogLevel.warning, component, message, context: context);

  void error(String component, String message,
      {Map<String, dynamic>? context, Object? error, StackTrace? stackTrace}) =>
      _log(LogLevel.error, component, message,
          context: context, error: error, stackTrace: stackTrace);

  void critical(String component, String message,
      {Map<String, dynamic>? context, Object? error, StackTrace? stackTrace}) =>
      _log(LogLevel.critical, component, message,
          context: context, error: error, stackTrace: stackTrace);

  List<LogEntry> getRecentLogs({LogLevel? minLevel}) {
    if (minLevel == null) return List.unmodifiable(_recentLogs);
    return _recentLogs.where((l) => l.level.index >= minLevel.index).toList();
  }
}

// ─── Metrics ─────────────────────────────────────────────────────────────────

/// Simple in-memory metric registry for engine and pipeline monitoring.
class MetricsRegistry {
  static final MetricsRegistry _instance = MetricsRegistry._internal();
  factory MetricsRegistry() => _instance;
  MetricsRegistry._internal();

  final Map<String, int> _counters = {};
  final Map<String, double> _gauges = {};
  final Map<String, List<double>> _histograms = {};

  void increment(String metric, {int by = 1}) {
    _counters[metric] = (_counters[metric] ?? 0) + by;
  }

  void gauge(String metric, double value) {
    _gauges[metric] = value;
  }

  void record(String metric, double value) {
    _histograms.putIfAbsent(metric, () => []).add(value);
    if ((_histograms[metric]?.length ?? 0) > 1000) {
      _histograms[metric]?.removeAt(0);
    }
  }

  int counter(String metric) => _counters[metric] ?? 0;
  double? gaugeValue(String metric) => _gauges[metric];

  double? histogramP95(String metric) {
    final values = _histograms[metric];
    if (values == null || values.isEmpty) return null;
    final sorted = List<double>.from(values)..sort();
    final index = (sorted.length * 0.95).floor().clamp(0, sorted.length - 1);
    return sorted[index];
  }

  Map<String, dynamic> snapshot() => {
    'counters': Map<String, int>.from(_counters),
    'gauges': Map<String, double>.from(_gauges),
    'histogram_p95': {
      for (final key in _histograms.keys) key: histogramP95(key),
    },
  };
}

// ─── Audit Logger ─────────────────────────────────────────────────────────────

/// Immutable audit entry for HIPAA-aligned event recording.
class AuditEntry {
  final String actorId;
  final String action;
  final String resourceType;
  final String resourceId;
  final DateTime performedAt;
  final Map<String, dynamic>? metadata;

  const AuditEntry({
    required this.actorId,
    required this.action,
    required this.resourceType,
    required this.resourceId,
    required this.performedAt,
    this.metadata,
  });
}

/// Audit logger for sensitive data access tracking.
class AuditLogger {
  static final AuditLogger _instance = AuditLogger._internal();
  factory AuditLogger() => _instance;
  AuditLogger._internal();

  final List<AuditEntry> _buffer = [];

  void record(AuditEntry entry) {
    _buffer.add(entry);
    BIOSLogger.instance.info('AuditLogger', '${entry.actorId} performed ${entry.action} on ${entry.resourceType}:${entry.resourceId}');
    // TODO: Flush buffer to Supabase audit_log table on batched intervals
  }

  List<AuditEntry> getBuffer() => List.unmodifiable(_buffer);
}
