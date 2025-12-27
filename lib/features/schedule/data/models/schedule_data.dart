import '../../../calendar/data/models/event.dart';
import 'course.dart';

class ScheduleData {
  final List<Course> courses;
  final List<Event> events;

  const ScheduleData({required this.courses, required this.events});

  const ScheduleData.empty() : courses = const [], events = const [];

  ScheduleData copyWith({List<Course>? courses, List<Event>? events}) {
    return ScheduleData(
      courses: courses ?? this.courses,
      events: events ?? this.events,
    );
  }
}
