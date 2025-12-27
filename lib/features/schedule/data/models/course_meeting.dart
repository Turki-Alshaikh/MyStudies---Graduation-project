class CourseMeeting {
  final int weekday; // 0 = Sun, 1 = Mon ... 6 = Sat
  final int startMinutes; // minutes from midnight
  final int endMinutes; // minutes from midnight

  const CourseMeeting({
    required this.weekday,
    required this.startMinutes,
    required this.endMinutes,
  });

  Map<String, dynamic> toJson() => {
        'weekday': weekday,
        'startMinutes': startMinutes,
        'endMinutes': endMinutes,
      };

  factory CourseMeeting.fromJson(Map<String, dynamic> json) => CourseMeeting(
        weekday: json['weekday'] as int,
        startMinutes: json['startMinutes'] as int,
        endMinutes: json['endMinutes'] as int,
      );
}

