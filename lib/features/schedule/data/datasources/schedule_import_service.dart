import 'dart:convert';
import 'dart:io';

import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';

import '../../../calendar/data/models/event.dart';
import '../models/course.dart';
import '../models/course_meeting.dart';
import '../models/schedule_data.dart';
import '../period_mapping.dart';

class ScheduleImportService {
  static final Uuid _uuid = Uuid();
  static Future<ScheduleData> importFromJson(String jsonString) async {
    try {
      final Map<String, dynamic> data = json.decode(jsonString);
      final List<Course> courses = [];
      final List<Event> events = [];

      // Parse courses
      if (data['courses'] != null) {
        for (var courseData in data['courses']) {
          // Normalize Python parser format to Course model format
          final normalizedData = _normalizeCourseData(courseData);
          Course course = Course.fromJson(normalizedData);

          // If meetings are not provided but a schedule is, build meetings from schedule
          if (course.meetings.isEmpty && courseData['schedule'] != null) {
            final meetings = <CourseMeeting>[];
            for (final scheduleData in (courseData['schedule'] as List)) {
              final meeting = _meetingFromSchedule(scheduleData);
              if (meeting != null) meetings.add(meeting);
            }
            course = course.copyWith(meetings: meetings);
          }

          courses.add(course);

          // Do not create calendar events for classes; meetings are stored on the course only
        }
      }

      return ScheduleData(courses: courses, events: events);
    } catch (e) {
      throw Exception('Failed to parse JSON: $e');
    }
  }

  // Intentionally not creating calendar events for class meetings

  static int? _getDayId(String? dayName) {
    if (dayName == null) return null;

    final dayMap = {
      'monday': 1,
      'tuesday': 2,
      'wednesday': 3,
      'thursday': 4,
      'friday': 5,
      'saturday': 6,
      'sunday': 7,
      'mon': 1,
      'tue': 2,
      'wed': 3,
      'thu': 4,
      'fri': 5,
      'sat': 6,
      'sun': 7,
    };

    return dayMap[dayName.toLowerCase()];
  }

  static int? _extractDayId(dynamic day) {
    if (day == null) return null;
    if (day is int) {
      // Accept 0-6 (Sun-Sat) or 1-7 (Mon-Sun)
      if (day >= 0 && day <= 6) {
        // Convert 0=Sun..6=Sat to DateTime (1=Mon..7=Sun)
        return [7, 1, 2, 3, 4, 5, 6][day];
      }
      if (day >= 1 && day <= 7) return day;
    }
    return _getDayId(day.toString());
  }

  static DateTime? _parseTime(String timeStr) {
    try {
      // Handle formats like "10:00 AM", "14:30", "2:00 PM"
      final cleanTime = timeStr.trim();
      final isPM = cleanTime.toUpperCase().contains('PM');
      final isAM = cleanTime.toUpperCase().contains('AM');

      // Remove AM/PM and extract time
      final timeOnly = cleanTime
          .replaceAll(RegExp(r'[AP]M', caseSensitive: false), '')
          .trim();
      final parts = timeOnly.split(':');

      if (parts.length != 2) return null;

      int hour = int.parse(parts[0]);
      final minute = int.parse(parts[1]);

      // Convert to 24-hour format
      if (isPM && hour != 12) hour += 12;
      if (isAM && hour == 12) hour = 0;

      return DateTime(2024, 1, 1, hour, minute);
    } catch (e) {
      return null;
    }
  }

  // _getNextOccurrence removed; no event creation for classes

  static CourseMeeting? _meetingFromSchedule(
    Map<String, dynamic> scheduleData,
  ) {
    try {
      final int? dayId = _extractDayId(scheduleData['day']);
      if (dayId == null) return null;

      // Convert DateTime weekday (1=Mon..7=Sun) to our 0=Sun..6=Sat
      final weekdayZeroSun = [0, 1, 2, 3, 4, 5, 6][dayId % 7];

      // Time range or periods
      String? timeStr = scheduleData['time']?.toString();
      if (timeStr != null) {
        final parts = timeStr.split('-');
        if (parts.length == 2) {
          final start = _parseTime(parts[0].trim());
          final end = _parseTime(parts[1].trim());
          if (start != null && end != null) {
            return CourseMeeting(
              weekday: weekdayZeroSun,
              startMinutes: start.hour * 60 + start.minute,
              endMinutes: end.hour * 60 + end.minute,
            );
          }
        }
      }

      // Handle period(s)
      List<int> periods = [];
      if (scheduleData['period'] != null) {
        final p = int.tryParse(scheduleData['period'].toString());
        if (p != null) periods = [p];
      } else if (scheduleData['periods'] is List) {
        periods = (scheduleData['periods'] as List)
            .map((e) => int.tryParse(e.toString()))
            .whereType<int>()
            .toList();
      }
      if (periods.isEmpty) return null;
      final span = periodsToSpanMinutes(periods);
      if (span == null) return null;
      return CourseMeeting(
        weekday: weekdayZeroSun,
        startMinutes: span[0],
        endMinutes: span[1],
      );
    } catch (_) {
      return null;
    }
  }

  /// Normalize Python parser format to Course model format
  static Map<String, dynamic> _normalizeCourseData(Map<String, dynamic> data) {
    // Handle Python parser format (course_code, course_name, credits)
    // or already normalized format (code, name, creditHours)
    final normalized = <String, dynamic>{};

    // Generate ID if missing
    normalized['id'] = data['id'] ?? _uuid.v4();

    // Map course_code -> code, or use code if already present
    normalized['code'] = (data['code'] ?? data['course_code'] ?? '').toString();
    if (normalized['code'].isEmpty) {
      throw Exception('Course code is required but missing');
    }

    // Map course_name -> name, or use name if already present
    normalized['name'] = (data['name'] ?? data['course_name'] ?? '').toString();
    if (normalized['name'].isEmpty) {
      throw Exception('Course name is required but missing');
    }

    // Map credits -> creditHours, convert string to int
    final creditsRaw = data['creditHours'] ?? data['credits'] ?? '0';
    if (creditsRaw is int) {
      normalized['creditHours'] = creditsRaw;
    } else {
      normalized['creditHours'] = int.tryParse(creditsRaw.toString()) ?? 0;
    }

    // Handle optional fields (can be null)
    normalized['grade'] = data['grade'];
    normalized['building'] = data['building']?.toString();
    normalized['room'] = data['room']?.toString();

    // Keep schedule as-is for event creation
    if (data['schedule'] != null) {
      normalized['schedule'] = data['schedule'];
    }

    // Resources if present
    if (data['resources'] != null) {
      normalized['resources'] = data['resources'];
    }

    // Meetings if present (might be empty initially)
    if (data['meetings'] != null) {
      normalized['meetings'] = data['meetings'];
    }

    return normalized;
  }

  // Load sample JSON from assets
  static Future<String> loadSampleJson() async {
    return await rootBundle.loadString('assets/sample_schedule.json');
  }

  // Save JSON to app documents directory
  static Future<void> saveJsonToFile(String jsonString) async {
    final directory = await getApplicationDocumentsDirectory();
    final file = File('${directory.path}/schedule.json');
    await file.writeAsString(jsonString);
  }

  // Load JSON from app documents directory
  static Future<String> loadJsonFromFile() async {
    final directory = await getApplicationDocumentsDirectory();
    final file = File('${directory.path}/schedule.json');
    return await file.readAsString();
  }
}
