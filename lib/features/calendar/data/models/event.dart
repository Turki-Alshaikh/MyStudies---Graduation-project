import 'package:flutter/material.dart';
import 'reminder.dart';

enum EventType { exam, assignment, course }

class Event {
  final String id;
  final String courseId;
  final String title;
  final DateTime dateTime;
  final EventType type;
  final String course;
  final String? description;
  final List<Reminder> reminders;
  final Color color;

  Event({
    required this.id,
    required this.courseId,
    required this.title,
    required this.dateTime,
    required this.type,
    required this.course,
    this.description,
    this.reminders = const [],
  }) : color = _getEventColor(type);

  static Color _getEventColor(EventType type) {
    switch (type) {
      case EventType.exam:
        return const Color(0xFFF28B82); // Soft Red
      case EventType.assignment:
        return const Color(0xFFFFCC80); // Soft Orange
      case EventType.course:
        return const Color(0xFF03DAC6); // Modern Cyan
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'courseId': courseId,
      'title': title,
      'dateTime': dateTime.toIso8601String(),
      'type': type.name,
      'course': course,
      'description': description,
      'reminders': reminders.map((r) => r.toJson()).toList(),
    };
  }

  factory Event.fromJson(Map<String, dynamic> json) {
    return Event(
      id: json['id'],
      courseId: json['courseId'] ?? '',
      title: json['title'],
      dateTime: DateTime.parse(json['dateTime']),
      type: EventType.values.firstWhere((e) => e.name == json['type']),
      course: json['course'],
      description: json['description'],
      reminders:
          (json['reminders'] as List?)
              ?.map((r) => Reminder.fromJson(r))
              .toList() ??
          [],
    );
  }

  bool isOverdue() {
    return dateTime.isBefore(DateTime.now());
  }

  bool create() {
    // Implementation would save to database
    return true;
  }

  bool update(Map<String, dynamic> data) {
    // Implementation would update in database
    return true;
  }

  bool delete() {
    // Implementation would delete from database
    return true;
  }
}
