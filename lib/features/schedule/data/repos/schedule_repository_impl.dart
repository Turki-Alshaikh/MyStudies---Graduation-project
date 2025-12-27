import 'dart:io';

import 'package:dartz/dartz.dart';

import '../../../../core/errors/custom_exception.dart';
import '../../../../core/errors/failure.dart';
import '../../../calendar/data/models/event.dart';
import 'schedule_repository.dart';
import '../datasources/pdf_processing_service.dart';
import '../models/course.dart';
import '../models/schedule_data.dart';

class ScheduleRepositoryImpl implements ScheduleRepository {
  ScheduleRepositoryImpl(PdfProcessingService pdfService);

  @override
  Future<Either<Failure, ScheduleData>> importFromPdf(File file) async {
    try {
      final data = await PdfProcessingService.processSchedulePdf(file);
      return Right(data);
    } on CustomException catch (e) {
      return Left(Failure(e.message, code: e.code));
    } catch (e) {
      return Left(Failure(e.toString()));
    }
  }

  // For now these are no-ops: actual storage handled in the ScheduleCubit
  @override
  Future<Either<Failure, void>> addCourse(Course course) async =>
      const Right(null);

  @override
  Future<Either<Failure, void>> updateCourse(Course course) async =>
      const Right(null);

  @override
  Future<Either<Failure, void>> deleteCourse(String id) async =>
      const Right(null);

  @override
  Future<Either<Failure, void>> addEvent(Event event) async =>
      const Right(null);

  @override
  Future<Either<Failure, void>> updateEvent(Event event) async =>
      const Right(null);

  @override
  Future<Either<Failure, void>> deleteEvent(String id) async =>
      const Right(null);
}
