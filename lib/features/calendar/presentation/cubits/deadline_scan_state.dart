part of 'deadline_scan_cubit.dart';

abstract class DeadlineScanState extends Equatable {
  const DeadlineScanState();
  @override
  List<Object?> get props => [];
}

class DeadlineScanIdle extends DeadlineScanState {
  const DeadlineScanIdle();
}

class DeadlineScanLoading extends DeadlineScanState {
  const DeadlineScanLoading();
}

class DeadlineScanSuccess extends DeadlineScanState {
  final String text;
  final String title;
  final String courseCode;
  final DateTime? date;
  final String type; // 'exam' | 'assignment'

  const DeadlineScanSuccess({
    required this.text,
    required this.title,
    required this.courseCode,
    required this.date,
    required this.type,
  });

  @override
  List<Object?> get props => [text, title, courseCode, date, type];
}

class DeadlineScanError extends DeadlineScanState {
  final String message;
  const DeadlineScanError(this.message);
  @override
  List<Object?> get props => [message];
}
