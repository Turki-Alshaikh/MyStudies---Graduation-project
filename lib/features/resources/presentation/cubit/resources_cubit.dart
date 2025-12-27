import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../../schedule/data/models/course.dart';
import '../../data/models/resource.dart';
import '../../data/static_resources.dart';

part 'resources_state.dart';

class ResourcesCubit extends Cubit<ResourcesState> {
  ResourcesCubit() : super(const ResourcesInitial());

  /// Load resources for courses
  void loadResources(List<Course> allCourses) {
    // Filter out practical parts (courses with 0 or null credits)
    final courses = allCourses
        .where((course) => course.creditHours > 0)
        .toList();

    if (courses.isEmpty) {
      emit(const ResourcesEmpty());
      return;
    }

    // Build map of course ID to merged resources
    final Map<String, List<Resource>> courseResources = {};
    for (final course in courses) {
      final merged = [
        ...course.resources,
        ..._getStaticResourcesForCourse(course),
      ];
      courseResources[course.id] = merged;
    }

    emit(ResourcesLoaded(courses: courses, courseResources: courseResources));
  }

  /// Get static resources for a specific course
  List<Resource> _getStaticResourcesForCourse(Course course) {
    final codeNorm = normalizeCode(course.code);
    MapEntry<String, Map<String, dynamic>>? match;

    for (final entry in kCourseStaticResources.entries) {
      if (normalizeCode(entry.key) == codeNorm) {
        match = entry;
        break;
      }
    }

    if (match == null) return const [];

    final data = match.value;
    final List<Resource> list = [];

    for (final tg in (data['telegram_groups'] as List? ?? const [])) {
      list.add(
        Resource(
          id: 'static:${course.id}:tg:$tg',
          courseId: course.id,
          url: tg as String,
          type: ResourceType.telegram.name,
          description: 'Telegram Group',
        ),
      );
    }

    for (final book in (data['books'] as List? ?? const [])) {
      list.add(
        Resource(
          id: 'static:${course.id}:book:$book',
          courseId: course.id,
          url: book as String,
          type: ResourceType.document.name,
          description: 'Course Book',
        ),
      );
    }

    return list;
  }
}
