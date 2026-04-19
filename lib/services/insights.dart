// insights.dart
// Author: Dhwani
// Migraine pattern detection for doctor dashboard

class MigraineFlag {
  final String level;
  final String label;
  final String detail;

  MigraineFlag({
    required this.level,
    required this.label,
    required this.detail,
  });
}

class MigraineInsights {
  final double avgPain;
  final double avgNausea;
  final double avgPhotosensitivity;
  final double avgTimeElapsed;
  final int auraCount;
  final int tinnitusCount;
  final int totalLogged;
  final int painTrend;
  final double avgHealthScore;
  final List<MigraineFlag> flags;
  final List<String> recentNotes;

  MigraineInsights({
    required this.avgPain,
    required this.avgNausea,
    required this.avgPhotosensitivity,
    required this.avgTimeElapsed,
    required this.auraCount,
    required this.tinnitusCount,
    required this.totalLogged,
    required this.painTrend,
    required this.avgHealthScore,
    required this.flags,
    required this.recentNotes,
  });
}

MigraineInsights analyzeMigraineLogs(
    List<Map<String, dynamic>> rawLogs) {

  if (rawLogs.isEmpty) {
    return MigraineInsights(
      avgPain: 0, avgNausea: 0,
      avgPhotosensitivity: 0, avgTimeElapsed: 0,
      auraCount: 0, tinnitusCount: 0,
      totalLogged: 0, painTrend: 0,
      avgHealthScore: 0,
      flags: [], recentNotes: [],
    );
  }

  final logs = List<Map<String, dynamic>>.from(rawLogs)
    ..sort((a, b) =>
        (a['date'] as String).compareTo(b['date'] as String));

  final recent = logs.length >= 4
      ? logs.sublist(logs.length - 4)
      : logs;

  final last  = logs.last;
  final first = recent.first;

  int safeInt(Map<String, dynamic> row, String key) =>
      (row[key] as num?)?.toInt() ?? 0;

  double safeDouble(Map<String, dynamic> row, String key) =>
      (row[key] as num?)?.toDouble() ?? 0.0;

  bool safeBool(Map<String, dynamic> row, String key) =>
      (row[key] as bool?) ?? false;

  double avgOf(String key) => logs
      .map((l) => safeInt(l, key).toDouble())
      .reduce((a, b) => a + b) / logs.length;

  final avgPain             = avgOf('pain');
  final avgNausea           = avgOf('nausea');
  final avgPhotosensitivity = avgOf('photosensitivity');
  final avgTimeElapsed      = logs
      .map((l) => safeDouble(l, 'time_elapsed'))
      .reduce((a, b) => a + b) / logs.length;
  final avgHealthScore      = logs
      .map((l) => safeInt(l, 'health_score').toDouble())
      .reduce((a, b) => a + b) / logs.length;

  final auraCount     = logs.where((l) => safeBool(l, 'aura')).length;
  final tinnitusCount = logs.where((l) => safeBool(l, 'tinnitus')).length;
  final painTrend     = safeInt(last, 'pain') - safeInt(first, 'pain');

  final flags = <MigraineFlag>[];

  final highPainDays = recent
      .where((l) => safeInt(l, 'pain') >= 7)
      .length;
  if (highPainDays >= 3) {
    flags.add(MigraineFlag(
      level: 'red',
      label: 'Severe pain streak',
      detail: 'Pain rated 7+ for $highPainDays consecutive days. Appointment recommended.',
    ));
  }

  if (painTrend >= 3) {
    flags.add(MigraineFlag(
      level: 'red',
      label: 'Pain escalating',
      detail: 'Pain rose from ${safeInt(first, 'pain')} to ${safeInt(last, 'pain')} over ${recent.length} days.',
    ));
  }

  final recentAura = recent
      .where((l) => safeBool(l, 'aura'))
      .length;
  if (recentAura >= 3) {
    flags.add(MigraineFlag(
      level: 'yellow',
      label: 'Frequent aura',
      detail: 'Aura reported in $recentAura of the last ${recent.length} logs.',
    ));
  }

  final highNauseaDays = recent
      .where((l) => safeInt(l, 'nausea') >= 7)
      .length;
  if (highNauseaDays >= 3) {
    flags.add(MigraineFlag(
      level: 'yellow',
      label: 'Persistent nausea',
      detail: 'High nausea for $highNauseaDays of the last ${recent.length} days.',
    ));
  }

  final longMigraines = recent
      .where((l) => safeDouble(l, 'time_elapsed') >= 24)
      .length;
  if (longMigraines >= 2) {
    flags.add(MigraineFlag(
      level: 'yellow',
      label: 'Extended duration',
      detail: '$longMigraines migraines lasting 24+ hours recently.',
    ));
  }

  final recentNotes = logs.reversed
      .where((l) => (l['notes'] as String? ?? '').isNotEmpty)
      .take(5)
      .map((l) {
        final date = l['date'] as String;
        final note = l['notes'] as String;
        return '$date  "$note"';
      })
      .toList();

  return MigraineInsights(
    avgPain: avgPain,
    avgNausea: avgNausea,
    avgPhotosensitivity: avgPhotosensitivity,
    avgTimeElapsed: avgTimeElapsed,
    auraCount: auraCount,
    tinnitusCount: tinnitusCount,
    totalLogged: logs.length,
    painTrend: painTrend,
    avgHealthScore: avgHealthScore,
    flags: flags,
    recentNotes: recentNotes,
  );
}

Map<String, String> trendArrow(int val) {
  if (val >= 3)  return {'arrow': '↑↑', 'label': 'Worsening'};
  if (val > 0)   return {'arrow': '↑',  'label': 'Rising'};
  if (val <= -3) return {'arrow': '↓↓', 'label': 'Improving'};
  if (val < 0)   return {'arrow': '↓',  'label': 'Improving'};
  return           {'arrow': '→',  'label': 'Stable'};
}