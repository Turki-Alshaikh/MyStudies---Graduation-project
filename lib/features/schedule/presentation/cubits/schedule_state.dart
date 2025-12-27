import 'package:equatable/equatable.dart';
import '../../data/models/course.dart';
import '../../../calendar/data/models/event.dart';

abstract class ScheduleState extends Equatable {
  const ScheduleState();
  @override
  List<Object?> get props => [];
}

class ScheduleInitial extends ScheduleState {}

class ScheduleLoading extends ScheduleState {}

class ScheduleFailure extends ScheduleState {
  final String message;
  const ScheduleFailure(this.message);
  @override
  List<Object?> get props => [message];
}

class ScheduleSuccess extends ScheduleState {
  final List<Course> courses;
  final List<Event> events;
  const ScheduleSuccess({required this.courses, required this.events});

  ScheduleSuccess copyWith({List<Course>? courses, List<Event>? events}) =>
      ScheduleSuccess(
        courses: courses ?? this.courses,
        events: events ?? this.events,
      );

  @override
  List<Object?> get props => [courses, events];
}
