import 'dart:io';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';

part 'deadline_scan_state.dart';

class DeadlineScanCubit extends Cubit<DeadlineScanState> {
  DeadlineScanCubit() : super(const DeadlineScanIdle());

  Future<void> scanImage(File image) async {
    emit(const DeadlineScanLoading());
    try {
      // Original OCR implementation removed - will be restored when ML Kit is connected
      // final inputImage = InputImage.fromFile(image);
      // final recognizer = TextRecognizer(script: TextRecognitionScript.latin);
      // final recognized = await recognizer.processImage(inputImage);
      // await recognizer.close();
      // final fullText = recognized.text;
      // final parsed = _parseAnnouncement(fullText);
      
      // Mock response for UI demonstration
      throw UnimplementedError('OCR service not yet connected');
    } catch (e) {
      emit(DeadlineScanError(e.toString()));
    }
  }

  _Parsed _parseAnnouncement(String text) {
    final normalized = text
        .replaceAll('\n', ' ')
        .replaceAll(RegExp(r'\s+'), ' ');

    // Type
    String type = 'assignment';
    if (RegExp(
      r'\b(midterm|final|exam)\b',
      caseSensitive: false,
    ).hasMatch(normalized)) {
      type = 'exam';
    } else if (RegExp(r'\bquiz\b', caseSensitive: false).hasMatch(normalized)) {
      type = 'assignment';
    } else if (RegExp(
      r'\b(project|assignment|submission)\b',
      caseSensitive: false,
    ).hasMatch(normalized)) {
      type = 'assignment';
    }

    // Course code like CS 360 or CS360 or CYS-210
    final courseMatch = RegExp(
      r'\b([A-Z]{2,4})[- ]?(\d{3})\b',
    ).firstMatch(normalized);
    final course = courseMatch != null
        ? '${courseMatch.group(1)} ${courseMatch.group(2)}'
        : '';

    // Dates: 10/9/2025 or 21/09/2025 or November 5 or 19/10/2025
    DateTime? date;
    // dd/MM/yyyy or d/M/yyyy
    final dmY = RegExp(r'\b(\d{1,2})[\-/](\d{1,2})[\-/](\d{4})\b');
    final m1 = dmY.firstMatch(normalized);
    if (m1 != null) {
      final d = int.tryParse(m1.group(1)!);
      final m = int.tryParse(m1.group(2)!);
      final y = int.tryParse(m1.group(3)!);
      if (d != null && m != null && y != null) {
        date = DateTime(y, m, d);
      }
    }
    // Month name day (no year) e.g., November 5th
    if (date == null) {
      final months = {
        'january': 1,
        'february': 2,
        'march': 3,
        'april': 4,
        'may': 5,
        'june': 6,
        'july': 7,
        'august': 8,
        'september': 9,
        'october': 10,
        'november': 11,
        'december': 12,
      };
      final nameDay = RegExp(
        r'\b(January|February|March|April|May|June|July|August|September|October|November|December)\s+(\d{1,2})(?:st|nd|rd|th)?\b',
        caseSensitive: false,
      );
      final m2 = nameDay.firstMatch(normalized);
      if (m2 != null) {
        final month = months[m2.group(1)!.toLowerCase()]!;
        final day = int.parse(m2.group(2)!);
        final now = DateTime.now();
        int year = now.year;
        final tentative = DateTime(year, month, day);
        if (tentative.isBefore(now)) {
          year++;
        }
        date = DateTime(year, month, day);
      }
    }

    // Title heuristic
    String title = '';
    if (type == 'exam') {
      title =
          RegExp(
            r'\b(midterm|final)\b',
            caseSensitive: false,
          ).stringMatch(normalized) ??
          'Exam';
    } else if (RegExp(r'\bquiz\b', caseSensitive: false).hasMatch(normalized)) {
      title = 'Quiz';
    } else if (RegExp(
      r'\bassignment\b',
      caseSensitive: false,
    ).hasMatch(normalized)) {
      title = 'Assignment';
    } else {
      title = 'Deadline';
    }

    return _Parsed(title: title, type: type, courseCode: course, date: date);
  }
}

class _Parsed {
  final String title;
  final String type; // 'exam' | 'assignment'
  final String courseCode; // e.g., CS 360
  final DateTime? date;

  _Parsed({
    required this.title,
    required this.type,
    required this.courseCode,
    required this.date,
  });
}
