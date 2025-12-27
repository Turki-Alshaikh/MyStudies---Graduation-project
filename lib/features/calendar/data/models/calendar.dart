import 'event.dart';
import '../../../schedule/data/models/timetable_entry.dart';

class Calendar {
  final String id;
  final List<Event> events;
  final List<TimetableEntry> scheduleEntries;

  Calendar({
    required this.id,
    this.events = const [],
    this.scheduleEntries = const [],
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'events': events.map((e) => e.toJson()).toList(),
      'scheduleEntries': scheduleEntries.map((e) => e.toJson()).toList(),
    };
  }

  factory Calendar.fromJson(Map<String, dynamic> json) {
    return Calendar(
      id: json['id'],
      events:
          (json['events'] as List?)?.map((e) => Event.fromJson(e)).toList() ??
          [],
      scheduleEntries:
          (json['scheduleEntries'] as List?)
              ?.map((e) => TimetableEntry.fromJson(e))
              .toList() ??
          [],
    );
  }

  Calendar copyWith({
    String? id,
    List<Event>? events,
    List<TimetableEntry>? scheduleEntries,
  }) {
    return Calendar(
      id: id ?? this.id,
      events: events ?? this.events,
      scheduleEntries: scheduleEntries ?? this.scheduleEntries,
    );
  }
}
