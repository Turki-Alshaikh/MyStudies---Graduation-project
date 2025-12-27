import 'dart:async';
import 'dart:io';

import 'package:bloc/bloc.dart';
import 'package:dartz/dartz.dart';

import '../../../../core/errors/failure.dart';
import '../../data/period_mapping.dart';
import '../../../calendar/data/models/event.dart';
import '../../../resources/data/models/resource.dart';
import '../../data/models/course.dart';
import '../../data/models/course_meeting.dart';
import '../../data/models/schedule_data.dart';
import '../../data/repos/schedule_repository.dart';
import 'schedule_state.dart';

/// Manages all schedule-related state (courses, events, schedule imports)
///
/// This cubit handles:
/// - Importing schedules from PDF files
/// - Managing courses and their meeting times
/// - Managing events and deadlines
/// - Checking for time conflicts between courses
/// - Finding the next upcoming class
class ScheduleCubit extends Cubit<ScheduleState> {
  /// Repository for importing PDF schedules
  final ScheduleRepository repo;

  // Internal state (not exposed directly to prevent external modification)
  List<Course> _courses = [];
  List<Event> _events = [];
  bool _isLoading = false;
  String? _lastError;

  ScheduleCubit({required this.repo})
    : super(const ScheduleSuccess(courses: [], events: []));

  // Getters expose read-only access to internal state
  List<Course> get courses => List.unmodifiable(_courses);
  List<Event> get events => List.unmodifiable(_events);
  bool get isLoading => _isLoading;
  String? get lastError => _lastError;

  /// Imports a schedule from a PDF file
  ///
  /// This method:
  /// 1. Sends the PDF to the Python server for parsing
  /// 2. Receives the parsed courses and events
  /// 3. Saves them to the database
  /// 4. Updates the app state
  ///
  /// [file] - The PDF file to import
  Future<void> importFromPdf(File file) async {
    _setLoading(true);
    emit(ScheduleLoading());

    // Send PDF to Python server and get parsed data
    final Either<Failure, ScheduleData> result = await repo.importFromPdf(file);

    // Handle the result (either success or failure)
    result.fold(
      (failure) {
        // If import failed, show error message
        _lastError = failure.message;
        _setLoading(false);
        emit(ScheduleFailure(failure.message));
        _emitSuccess();
      },
      (data) {
        // If import succeeded, apply the data to the app
        _applyScheduleData(data);
        _setLoading(false);
        _emitSuccess();
      },
    );
  }

  /// Previews a PDF import without applying it
  ///
  /// Used for showing the user what will be imported before confirming
  /// Returns the parsed data without saving it
  ///
  /// [file] - The PDF file to preview
  Future<Either<Failure, ScheduleData>> previewFromPdf(File file) async {
    _setLoading(true);
    final Either<Failure, ScheduleData> result = await repo.importFromPdf(file);
    _setLoading(false);
    return result;
  }

  ImportSummary summarizeImport(ScheduleData data) {
    final Map<String, _CourseSummaryBuilder> builders = {};

    for (final course in data.courses) {
      final key = course.code.trim().toUpperCase();
      final builder = builders.putIfAbsent(
        key,
        () => _CourseSummaryBuilder(
          code: course.code.trim(),
          name: course.name.trim(),
        ),
      );
      builder.addMeetings(course.meetings);
    }

    final courseSummaries =
        builders.values.map((builder) => builder.build()).toList()
          ..sort((a, b) => a.code.compareTo(b.code));

    final totalMeetings = courseSummaries.fold<int>(
      0,
      (sum, course) => sum + course.meetingCount,
    );

    return ImportSummary(
      uniqueCourseCount: courseSummaries.length,
      totalMeetings: totalMeetings,
      courses: courseSummaries,
    );
  }

  void setSchedule(ScheduleData data) {
    _applyScheduleData(data);
    _emitSuccess();
  }

  void clearSchedule() {
    _courses = [];
    _events = [];
    _lastError = null;
    _emitSuccess();
  }

  /// Tries to add a course, checking for conflicts first
  ///
  /// Validates:
  /// 1. Course code is not duplicate
  /// 2. No time conflicts with existing courses
  ///
  /// Returns true if course was added, false if there was a conflict
  /// If false, check [lastError] for the reason
  bool tryAddCourse(Course course) {
    // Check if a course with the same code already exists
    final isDuplicate = _courses.any(
      (c) => c.code.toLowerCase().trim() == course.code.toLowerCase().trim(),
    );
    if (isDuplicate) {
      _lastError = 'Course with code ${course.code} is already added.';
      return false;
    }

    // Check for time conflicts with existing courses
    const dayNames = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];

    // Compare each meeting of the new course with each meeting of existing courses
    for (final existingCourse in _courses) {
      for (final existingMeeting in existingCourse.meetings) {
        for (final newMeeting in course.meetings) {
          // Only check conflicts if meetings are on the same day
          if (existingMeeting.weekday != newMeeting.weekday) continue;

          // Calculate the overlap time range
          // Latest start = the later of the two start times
          final latestStart =
              existingMeeting.startMinutes > newMeeting.startMinutes
              ? existingMeeting.startMinutes
              : newMeeting.startMinutes;

          // Earliest end = the earlier of the two end times
          final earliestEnd = existingMeeting.endMinutes < newMeeting.endMinutes
              ? existingMeeting.endMinutes
              : newMeeting.endMinutes;

          // If latest start < earliest end, there's an overlap (conflict)
          // Example: Course A: 8:00-10:00, Course B: 9:00-11:00
          //          latestStart = 9:00, earliestEnd = 10:00
          //          9:00 < 10:00 = conflict!
          if (latestStart < earliestEnd) {
            // Format the day name for the error message
            final day =
                (existingMeeting.weekday >= 0 &&
                    existingMeeting.weekday < dayNames.length)
                ? dayNames[existingMeeting.weekday]
                : existingMeeting.weekday.toString();

            // Helper function to format minutes as time (e.g., 540 → "9:00 AM")
            String formatTime(int minutes) {
              final hour = minutes ~/ 60;
              final minute = minutes % 60;
              final displayHour = hour % 12 == 0 ? 12 : hour % 12;
              final ampm = hour >= 12 ? 'PM' : 'AM';
              final displayMinute = minute.toString().padLeft(2, '0');
              return '$displayHour:$displayMinute $ampm';
            }

            // Create error message with conflict details
            _lastError =
                'Time conflict with ${existingCourse.code} on $day between ${formatTime(latestStart)} and ${formatTime(earliestEnd)}';
            return false;
          }
        }
      }
    }

    // No conflicts found, add the course
    _courses.add(course);
    _lastError = null;
    _emitSuccess();
    return true;
  }

  /// Alias for tryAddCourse (same functionality)
  bool addCourse(Course course) => tryAddCourse(course);

  /// Updates an existing course
  ///
  /// Validates that the course code is not already used by another course
  /// Returns true if update succeeded, false if there was an error
  bool updateCourse(Course updated) {
    // Check if another course (not this one) already uses this code
    final isCodeDuplicate = _courses.any(
      (c) =>
          c.id != updated.id &&
          c.code.toLowerCase().trim() == updated.code.toLowerCase().trim(),
    );
    if (isCodeDuplicate) {
      _lastError = 'Another course already uses code ${updated.code}.';
      return false;
    }

    // Find the course to update
    final courseIndex = _courses.indexWhere((c) => c.id == updated.id);
    if (courseIndex == -1) {
      _lastError = 'Course not found.';
      return false;
    }

    // Update the course
    _courses[courseIndex] = updated;
    _lastError = null;
    _emitSuccess();
    return true;
  }

  bool deleteCourse(String id, {bool removeRelatedEvents = true}) {
    final before = _courses.length;
    _courses.removeWhere((course) => course.id == id);
    final removed = _courses.length != before;
    if (removed && removeRelatedEvents) {
      _events.removeWhere((event) => event.courseId == id);
    }
    if (removed) {
      _lastError = null;
      _emitSuccess();
    }
    return removed;
  }

  bool addEvent(Event event) {
    _events.add(event);
    _events.sort((a, b) => a.dateTime.compareTo(b.dateTime));
    _lastError = null;
    _emitSuccess();
    return true;
  }

  bool updateEvent(Event updated) {
    final index = _events.indexWhere((event) => event.id == updated.id);
    if (index == -1) {
      _lastError = 'Event not found.';
      return false;
    }
    _events[index] = updated;
    _events.sort((a, b) => a.dateTime.compareTo(b.dateTime));
    _lastError = null;
    _emitSuccess();
    return true;
  }

  bool deleteEvent(String id) {
    final before = _events.length;
    _events.removeWhere((event) => event.id == id);
    final removed = _events.length != before;
    if (removed) {
      _lastError = null;
      _emitSuccess();
    }
    return removed;
  }

  void addResource(String courseId, Resource resource) {
    final index = _courses.indexWhere((course) => course.id == courseId);
    if (index == -1) return;

    final course = _courses[index];
    final updatedCourse = course.copyWith(
      resources: [...course.resources, resource],
    );
    _courses[index] = updatedCourse;
    _lastError = null;
    _emitSuccess();
  }

  /// Finds the next upcoming class/meeting
  ///
  /// This method:
  /// 1. Looks at all course meetings and finds the next occurrence of each
  /// 2. Looks at all course-type events
  /// 3. Returns the one that's happening soonest
  ///
  /// [from] - The reference time (defaults to now)
  /// Returns the next class event, or null if none found
  Event? getNextClass({DateTime? from}) {
    final referenceTime = from ?? DateTime.now();

    /// Helper function: Finds the next date when a meeting occurs
    ///
    /// [weekdayZeroSun] - Day of week (0=Sunday, 1=Monday, etc.)
    /// [startMinutes] - Start time in minutes from midnight
    /// Returns the next DateTime when this meeting occurs (within 14 days)
    DateTime? nextDateForMeeting(int weekdayZeroSun, int startMinutes) {
      // Convert our weekday (0=Sun) to DateTime weekday (7=Sun, 1=Mon, etc.)
      final weekdayMapping = [
        DateTime.sunday, // 0 → 7
        DateTime.monday, // 1 → 1
        DateTime.tuesday, // 2 → 2
        DateTime.wednesday, // 3 → 3
        DateTime.thursday, // 4 → 4
        DateTime.friday, // 5 → 5
        DateTime.saturday, // 6 → 6
      ];
      final targetWeekday = weekdayMapping[weekdayZeroSun];

      // Start from midnight of the reference day
      final todayMidnight = DateTime(
        referenceTime.year,
        referenceTime.month,
        referenceTime.day,
      );

      // Look ahead up to 14 days to find the next occurrence
      for (int daysToAdd = 0; daysToAdd < 14; daysToAdd++) {
        final candidateDate = todayMidnight.add(Duration(days: daysToAdd));

        // If this date matches the target weekday
        if (candidateDate.weekday == targetWeekday) {
          // Add the start time to get the full DateTime
          final meetingDateTime = candidateDate.add(
            Duration(minutes: startMinutes),
          );

          // Return it if it's in the future
          if (meetingDateTime.isAfter(referenceTime)) return meetingDateTime;
        }
      }
      return null;
    }

    // Find the next meeting from all courses
    Event? nextMeetingFromCourses;
    for (final course in _courses) {
      for (final meeting in course.meetings) {
        // Find when this meeting next occurs
        final meetingDateTime = nextDateForMeeting(
          meeting.weekday,
          meeting.startMinutes,
        );
        if (meetingDateTime == null) continue;

        // Build location string (building + room)
        final locationParts = [
          course.building,
          course.room,
        ].whereType<String>().where((value) => value.isNotEmpty).toList();

        // Create a temporary event for this meeting
        final meetingEvent = Event(
          id: 'course:${course.id}:${meeting.weekday}:${meeting.startMinutes}',
          courseId: course.id,
          title: course.name,
          dateTime: meetingDateTime,
          type: EventType.course,
          course: course.code,
          description: locationParts.join(' '),
        );

        // Keep track of the earliest meeting
        if (nextMeetingFromCourses == null ||
            meetingEvent.dateTime.isBefore(nextMeetingFromCourses.dateTime)) {
          nextMeetingFromCourses = meetingEvent;
        }
      }
    }

    // Find the next course-type event from the events list
    final nextCourseEvent = _events
        .where(
          (event) =>
              event.type == EventType.course &&
              event.dateTime.isAfter(referenceTime),
        )
        .fold<Event?>(
          null,
          (closest, event) =>
              closest == null || event.dateTime.isBefore(closest.dateTime)
              ? event
              : closest,
        );

    // Return whichever is sooner (meeting from courses or event from list)
    if (nextMeetingFromCourses == null) return nextCourseEvent;
    if (nextCourseEvent == null) return nextMeetingFromCourses;

    return nextMeetingFromCourses.dateTime.isBefore(nextCourseEvent.dateTime)
        ? nextMeetingFromCourses
        : nextCourseEvent;
  }

  /// Gets the next upcoming events (deadlines, exams, etc.)
  ///
  /// Filters out past events and returns only future events,
  /// sorted by date (soonest first)
  ///
  /// [limit] - Maximum number of events to return (default: 4)
  /// Returns a list of upcoming events
  List<Event> upcomingEvents({int limit = 4}) {
    if (_events.isEmpty) return <Event>[];

    final now = DateTime.now();

    // Filter to only future events (past events should not appear)
    final upcoming = _events
        .where((event) => event.dateTime.isAfter(now))
        .toList();

    // Sort by date (soonest first)
    upcoming.sort((a, b) => a.dateTime.compareTo(b.dateTime));

    // Return only the specified number of events
    return upcoming.take(limit).toList();
  }

  List<Event> eventsForDay(DateTime day) {
    final key = DateTime(day.year, day.month, day.day);
    return _events.where((event) {
      final eventKey = DateTime(
        event.dateTime.year,
        event.dateTime.month,
        event.dateTime.day,
      );
      return eventKey == key;
    }).toList();
  }

  List<Event> eventsForWeekday(int weekday) {
    return _events.where((event) => event.dateTime.weekday == weekday).toList();
  }

  List<Resource> resourcesForCourse(String courseId) {
    for (final course in _courses) {
      if (course.id == courseId) {
        return List<Resource>.from(course.resources);
      }
    }
    return const <Resource>[];
  }

  void _applyScheduleData(ScheduleData data) {
    _courses = List<Course>.from(data.courses);
    _events = List<Event>.from(data.events)
      ..sort((a, b) => a.dateTime.compareTo(b.dateTime));
    _lastError = null;
  }

  void _emitSuccess() {
    emit(
      ScheduleSuccess(
        courses: List.unmodifiable(_courses),
        events: List.unmodifiable(_events),
      ),
    );
  }

  void _setLoading(bool value) {
    if (_isLoading == value) return;
    _isLoading = value;
  }
}

class ImportSummary {
  final int uniqueCourseCount;
  final int totalMeetings;
  final List<CourseImportSummary> courses;

  ImportSummary({
    required this.uniqueCourseCount,
    required this.totalMeetings,
    required this.courses,
  });
}

class CourseImportSummary {
  final String code;
  final String name;
  final int meetingCount;
  final List<String> meetingDetails;

  CourseImportSummary({
    required this.code,
    required this.name,
    required this.meetingCount,
    required this.meetingDetails,
  });
}

class _CourseSummaryBuilder {
  _CourseSummaryBuilder({required this.code, required this.name});

  final String code;
  final String name;
  final Set<String> _meetingLabels = <String>{};
  int _meetingCount = 0;

  void addMeetings(List<CourseMeeting> meetings) {
    for (final meeting in meetings) {
      _meetingCount += 1;
      _meetingLabels.add(_formatMeetingLabel(meeting));
    }
  }

  CourseImportSummary build() => CourseImportSummary(
    code: code,
    name: name,
    meetingCount: _meetingCount,
    meetingDetails: _meetingLabels.toList()..sort(),
  );

  static const List<String> _weekdayNames = [
    'Sun',
    'Mon',
    'Tue',
    'Wed',
    'Thu',
    'Fri',
    'Sat',
  ];

  String _formatMeetingLabel(CourseMeeting meeting) {
    final dayIndex = meeting.weekday.clamp(0, _weekdayNames.length - 1);
    final dayLabel = _weekdayNames[dayIndex];
    final periods = _periodsForMeeting(meeting);
    if (periods.isNotEmpty) {
      if (periods.length == 1) {
        return '$dayLabel · Period ${periods.first}';
      }
      return '$dayLabel · Periods ${periods.first}-${periods.last}';
    }
    final start = _formatMinutes(meeting.startMinutes);
    final end = _formatMinutes(meeting.endMinutes);
    return '$dayLabel · $start-$end';
  }

  List<int> _periodsForMeeting(CourseMeeting meeting) {
    final List<int> matches = [];
    for (final entry in periodTimes.entries) {
      final range = periodToMinutes(entry.key);
      if (range == null) continue;
      if (range[0] >= meeting.startMinutes && range[1] <= meeting.endMinutes) {
        matches.add(entry.key);
      }
    }
    matches.sort();
    return matches;
  }

  String _formatMinutes(int minutesFromMidnight) {
    final hours = minutesFromMidnight ~/ 60;
    final minutes = minutesFromMidnight % 60;
    final period = hours >= 12 ? 'PM' : 'AM';
    final hour12 = hours % 12 == 0 ? 12 : hours % 12;
    final minuteStr = minutes.toString().padLeft(2, '0');
    return '$hour12:$minuteStr $period';
  }
}
