import 'package:sqflite/sqflite.dart';

import '../../features/resources/data/models/resource.dart';
import '../../features/schedule/data/models/course.dart';
import '../../features/schedule/data/models/course_meeting.dart';
import 'app_database.dart';

class CoursesDbRepository {
  final AppDatabase _db = AppDatabase.instance;

  // Save a course with its meetings
  Future<void> saveCourse(Course course) async {
    final db = await _db.database;

    await db.insert('courses', {
      'id': course.id,
      'name': course.name,
      'code': course.code,
      'creditHours': course.creditHours,
      'grade': course.grade,
      'room': course.room,
      'building': course.building,
    }, conflictAlgorithm: ConflictAlgorithm.replace);

    await _saveMeetings(db, course);
    await _saveResources(db, course);
  }

  // Get all courses with their meetings
  Future<List<Course>> getAllCourses() async {
    final db = await _db.database;

    final coursesData = await db.query('courses');
    final courses = <Course>[];

    for (final courseData in coursesData) {
      final meetings = await _getMeetings(db, courseData['id'] as String);
      final resources = await _getResources(db, courseData['id'] as String);

      courses.add(
        Course(
          id: courseData['id'] as String,
          name: courseData['name'] as String,
          code: courseData['code'] as String,
          creditHours: courseData['creditHours'] as int,
          grade: courseData['grade'] as String?,
          room: courseData['room'] as String?,
          building: courseData['building'] as String?,
          meetings: meetings,
          resources: resources,
        ),
      );
    }

    return courses;
  }

  // Delete a course
  Future<void> deleteCourse(String courseId) async {
    final db = await _db.database;
    await db.delete('course_meetings', where: 'courseId = ?', whereArgs: [courseId]);
    await db.delete('resources', where: 'courseId = ?', whereArgs: [courseId]);
    await db.delete('courses', where: 'id = ?', whereArgs: [courseId]);
  }

  // Save multiple courses
  Future<void> saveCourses(List<Course> courses) async {
    for (final course in courses) {
      await saveCourse(course);
    }
  }

  Future<void> replaceCourses(List<Course> courses) async {
    final db = await _db.database;
    await db.transaction((txn) async {
      await txn.delete('course_meetings');
      await txn.delete('resources');
      await txn.delete('courses');
      for (final course in courses) {
        await txn.insert('courses', {
          'id': course.id,
          'name': course.name,
          'code': course.code,
          'creditHours': course.creditHours,
          'grade': course.grade,
          'room': course.room,
          'building': course.building,
        }, conflictAlgorithm: ConflictAlgorithm.replace);
        await _saveMeetings(txn, course);
        await _saveResources(txn, course);
      }
    });
  }

  Future<void> addResource(Resource resource) async {
    final db = await _db.database;
    await db.insert(
      'resources',
      {
        'id': resource.id,
        'courseId': resource.courseId,
        'type': resource.type,
        'description': resource.description,
        'url': resource.url,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> deleteResource(String resourceId) async {
    final db = await _db.database;
    await db.delete('resources', where: 'id = ?', whereArgs: [resourceId]);
  }

  Future<List<Resource>> resourcesForCourse(String courseId) async {
    final db = await _db.database;
    return _getResources(db, courseId);
  }

  Future<void> _saveMeetings(DatabaseExecutor db, Course course) async {
    await db.delete(
      'course_meetings',
      where: 'courseId = ?',
      whereArgs: [course.id],
    );
    for (final meeting in course.meetings) {
      await db.insert('course_meetings', {
        'courseId': course.id,
        'weekday': meeting.weekday,
        'startMinutes': meeting.startMinutes,
        'endMinutes': meeting.endMinutes,
      });
    }
  }

  Future<void> _saveResources(DatabaseExecutor db, Course course) async {
    await db.delete('resources', where: 'courseId = ?', whereArgs: [course.id]);
    for (final resource in course.resources) {
      await db.insert(
        'resources',
        {
          'id': resource.id,
          'courseId': resource.courseId,
          'type': resource.type,
          'description': resource.description,
          'url': resource.url,
        },
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }
  }

  Future<List<CourseMeeting>> _getMeetings(DatabaseExecutor db, String courseId) async {
    final meetingsData = await db.query(
      'course_meetings',
      where: 'courseId = ?',
      whereArgs: [courseId],
    );
    return meetingsData
        .map(
          (m) => CourseMeeting(
            weekday: m['weekday'] as int,
            startMinutes: m['startMinutes'] as int,
            endMinutes: m['endMinutes'] as int,
          ),
        )
        .toList();
  }

  Future<List<Resource>> _getResources(DatabaseExecutor db, String courseId) async {
    final data = await db.query(
      'resources',
      where: 'courseId = ?',
      whereArgs: [courseId],
    );
    return data
        .map(
          (row) => Resource(
            id: (row['id'] ?? '').toString(),
            courseId: (row['courseId'] ?? '').toString(),
            url: (row['url'] ?? '').toString(),
            type: (row['type'] ?? 'website').toString(),
            description: (row['description'] ?? '').toString(),
          ),
        )
        .toList();
  }
}
