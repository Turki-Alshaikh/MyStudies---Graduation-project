import 'dart:io';
import 'package:dartz/dartz.dart';
import '../../../../core/errors/failure.dart';
import '../../../calendar/data/models/event.dart';
import '../models/course.dart';
import '../models/schedule_data.dart';

/// Repository interface for schedule operations
/// This is used by ScheduleRepositoryImpl and ScheduleCubit
abstract class ScheduleRepository {
  Future<Either<Failure, ScheduleData>> importFromPdf(File file);
  Future<Either<Failure, void>> addCourse(Course course);
  Future<Either<Failure, void>> updateCourse(Course course);
  Future<Either<Failure, void>> deleteCourse(String id);
  Future<Either<Failure, void>> addEvent(Event event);
  Future<Either<Failure, void>> updateEvent(Event event);
  Future<Either<Failure, void>> deleteEvent(String id);
}
