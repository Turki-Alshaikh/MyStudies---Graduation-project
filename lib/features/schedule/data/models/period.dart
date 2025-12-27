class Period {
  final String id;
  final DateTime startTime;
  final DateTime endTime;

  Period({required this.id, required this.startTime, required this.endTime});

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'startTime': startTime.toIso8601String(),
      'endTime': endTime.toIso8601String(),
    };
  }

  factory Period.fromJson(Map<String, dynamic> json) {
    return Period(
      id: json['id'],
      startTime: DateTime.parse(json['startTime']),
      endTime: DateTime.parse(json['endTime']),
    );
  }

  String getDisplayName() {
    final start =
        '${startTime.hour.toString().padLeft(2, '0')}:${startTime.minute.toString().padLeft(2, '0')}';
    final end =
        '${endTime.hour.toString().padLeft(2, '0')}:${endTime.minute.toString().padLeft(2, '0')}';
    return '$start - $end';
  }

  Duration get duration => endTime.difference(startTime);
}
