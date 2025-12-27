import '../../../resources/data/models/resource.dart';
import 'course_meeting.dart';

class Course {
  final String id;
  final String name;
  final String code;
  final int creditHours;
  final String? grade;
  final List<Resource> resources;
  final String? room;
  final String? building;
  final List<CourseMeeting> meetings;

  Course({
    required this.id,
    required this.name,
    required this.code,
    required this.creditHours,
    this.grade,
    this.resources = const [],
    this.room,
    this.building,
    this.meetings = const [],
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'code': code,
      'creditHours': creditHours,
      'grade': grade,
      'resources': resources.map((r) => r.toJson()).toList(),
      'room': room,
      'building': building,
      'meetings': meetings.map((m) => m.toJson()).toList(),
    };
  }

  factory Course.fromJson(Map<String, dynamic> json) {
    return Course(
      id: (json['id'] ?? '').toString(),
      name: (json['name'] ?? '').toString(),
      code: (json['code'] ?? '').toString(),
      creditHours: json['creditHours'] is int
          ? json['creditHours'] as int
          : (int.tryParse(json['creditHours']?.toString() ?? '0') ?? 0),
      grade: json['grade']?.toString(),
      resources:
          (json['resources'] as List?)
              ?.map((r) => Resource.fromJson(r))
              .toList() ??
          [],
      room: json['room']?.toString(),
      building: json['building']?.toString(),
      meetings:
          (json['meetings'] as List?)
              ?.map((m) => CourseMeeting.fromJson(m))
              .toList() ??
          const [],
    );
  }

  Course copyWith({
    String? id,
    String? name,
    String? code,
    int? creditHours,
    String? grade,
    List<Resource>? resources,
    String? room,
    String? building,
    List<CourseMeeting>? meetings,
  }) {
    return Course(
      id: id ?? this.id,
      name: name ?? this.name,
      code: code ?? this.code,
      creditHours: creditHours ?? this.creditHours,
      grade: grade ?? this.grade,
      resources: resources ?? this.resources,
      room: room ?? this.room,
      building: building ?? this.building,
      meetings: meetings ?? this.meetings,
    );
  }

  int getCredits() {
    return creditHours;
  }

  bool create() {
    // Implementation would save to database
    return true;
  }

  bool update() {
    // Implementation would update in database
    return true;
  }

  bool delete() {
    // Implementation would delete from database
    return true;
  }
}
