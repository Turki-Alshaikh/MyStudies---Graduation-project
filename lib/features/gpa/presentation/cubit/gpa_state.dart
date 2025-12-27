import 'package:equatable/equatable.dart';
import '../../../schedule/data/models/course.dart';

class GpaState extends Equatable {
  final List<Course> completedCourses;
  final Map<String, String> expectedGrades;
  final double targetGpa;
  final int remainingHours;
  final double? overrideCgpa;
  final int? overrideEarnedHours;
  final String creditMode;

  const GpaState({
    required this.completedCourses,
    required this.expectedGrades,
    required this.targetGpa,
    required this.remainingHours,
    required this.creditMode,
    this.overrideCgpa,
    this.overrideEarnedHours,
  });

  factory GpaState.initial() => const GpaState(
        completedCourses: [],
        expectedGrades: {},
        targetGpa: 0,
        remainingHours: 0,
        overrideCgpa: null,
        overrideEarnedHours: null,
        creditMode: 'mix',
      );

  GpaState copyWith({
    List<Course>? completedCourses,
    Map<String, String>? expectedGrades,
    double? targetGpa,
    int? remainingHours,
    double? overrideCgpa,
    int? overrideEarnedHours,
    String? creditMode,
  }) {
    return GpaState(
      completedCourses: completedCourses ?? this.completedCourses,
      expectedGrades: expectedGrades ?? this.expectedGrades,
      targetGpa: targetGpa ?? this.targetGpa,
      remainingHours: remainingHours ?? this.remainingHours,
      overrideCgpa: overrideCgpa,
      overrideEarnedHours: overrideEarnedHours,
      creditMode: creditMode ?? this.creditMode,
    );
  }

  @override
  List<Object?> get props => [
        completedCourses,
        expectedGrades,
        targetGpa,
        remainingHours,
        overrideCgpa,
        overrideEarnedHours,
        creditMode,
      ];
}
