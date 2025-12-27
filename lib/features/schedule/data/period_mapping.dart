final Map<int, String> periodTimes = {
  1: "07:00-07:50",
  2: "08:00-08:50",
  3: "09:00-09:50",
  4: "10:00-10:50",
  5: "11:00-11:50",
  // 30 min break before period 6
  6: "12:20-13:10",
  7: "13:20-14:10",
  8: "14:20-15:10",
  // 20 min break before period 9
  9: "15:30-16:20",
  10: "16:30-17:20",
  11: "17:30-18:20",
  12: "18:30-19:20",
};

/// Returns [startMinutes, endMinutes] from midnight for a given period number.
List<int>? periodToMinutes(int period) {
  final range = periodTimes[period];
  if (range == null) return null;
  final parts = range.split('-');
  if (parts.length != 2) return null;
  final start = _parseHhMm(parts[0]);
  final end = _parseHhMm(parts[1]);
  if (start == null || end == null) return null;
  return [start, end];
}

int? _parseHhMm(String hhmm) {
  final p = hhmm.split(':');
  if (p.length != 2) return null;
  final h = int.tryParse(p[0]);
  final m = int.tryParse(p[1]);
  if (h == null || m == null) return null;
  return h * 60 + m;
}

/// Convert a list of periods into a combined [startMinutes, endMinutes].
/// If periods are non-contiguous, returns the min start and max end.
List<int>? periodsToSpanMinutes(Iterable<int> periods) {
  final minutes = periods.map(periodToMinutes).whereType<List<int>>().toList();
  if (minutes.isEmpty) return null;
  final start = minutes.map((e) => e[0]).reduce((a, b) => a < b ? a : b);
  final end = minutes.map((e) => e[1]).reduce((a, b) => a > b ? a : b);
  return [start, end];
}
