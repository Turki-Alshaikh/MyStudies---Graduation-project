class TimetableEntry {
  final String id;
  final String courseId;
  final int weekDayId;
  final String periodId;
  final String roomId;

  TimetableEntry({
    required this.id,
    required this.courseId,
    required this.weekDayId,
    required this.periodId,
    required this.roomId,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'courseId': courseId,
      'weekDayId': weekDayId,
      'periodId': periodId,
      'roomId': roomId,
    };
  }

  factory TimetableEntry.fromJson(Map<String, dynamic> json) {
    return TimetableEntry(
      id: json['id'],
      courseId: json['courseId'],
      weekDayId: json['weekDayId'],
      periodId: json['periodId'],
      roomId: json['roomId'],
    );
  }

  DateTime calculateNextOccurrence() {
    final now = DateTime.now();
    final currentWeekday = now.weekday;
    final daysUntilTarget = (weekDayId - currentWeekday) % 7;
    return now.add(Duration(days: daysUntilTarget));
  }
}
