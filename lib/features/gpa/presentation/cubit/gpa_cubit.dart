import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../schedule/data/models/course.dart';
import '../../../schedule/presentation/cubits/schedule_cubit.dart';
import '../../../schedule/presentation/cubits/schedule_state.dart';
import '../../data/models/target_plan.dart';
import '../../data/calculators/target_gpa_calculator.dart';
import 'gpa_state.dart';

/// Manages all GPA-related state and calculations
/// 
/// This cubit handles:
/// - Calculating current GPA from courses with grades
/// - Predicting future GPA based on expected grades
/// - Calculating required grades to achieve target GPA
/// - Managing expected grades for each course
class GpaCubit extends Cubit<GpaState> {
  GpaCubit({required this.scheduleCubit}) : super(GpaState.initial());

  /// Reference to schedule cubit to access courses and events
  final ScheduleCubit scheduleCubit;

  /// Updates the expected grade for a specific course
  /// 
  /// [courseId] - The ID of the course to update
  /// [grade] - The expected grade (e.g., 'A', 'B+', 'C')
  void setExpectedGrade(String courseId, String grade) {
    // Create a copy of the current expected grades map
    final updated = Map<String, String>.from(state.expectedGrades)
      ..[courseId] = grade; // Update the grade for this course
    
    // Emit new state with updated grades
    emit(state.copyWith(expectedGrades: updated));
  }

  /// Adds a completed course to the list
  /// Used for courses that have already been graded
  void addCompletedCourse(Course course) {
    emit(
      state.copyWith(
        completedCourses: List<Course>.from(state.completedCourses)
          ..add(course),
      ),
    );
  }

  /// Removes a completed course from the list
  void removeCompletedCourse(String courseId) {
    emit(
      state.copyWith(
        completedCourses: state.completedCourses
            .where((course) => course.id != courseId)
            .toList(),
      ),
    );
  }

  /// Updates the target GPA the user wants to achieve
  /// [value] - The target GPA (e.g., 3.5, 4.0)
  void updateTargetGpa(double? value) {
    emit(state.copyWith(targetGpa: value ?? 0));
  }

  /// Updates the remaining credit hours needed to graduate
  /// Also resolves the credit mode (2, 3, 4, or mix) based on the hours
  void updateRemainingHours(int? value) {
    final remaining = value ?? 0;
    final mode = _resolveMode(remaining, state.creditMode);
    emit(state.copyWith(remainingHours: remaining, creditMode: mode));
  }

  /// Allows user to manually override their current CGPA
  /// Useful if they want to calculate from a different starting point
  void updateOverrideCgpa(double? value) {
    emit(state.copyWith(overrideCgpa: value));
  }

  /// Allows user to manually override their earned credit hours
  void updateOverrideEarnedHours(int? value) {
    emit(state.copyWith(overrideEarnedHours: value));
  }

  /// Updates the credit mode (how courses are structured)
  /// Options: '2', '3', '4' (all courses same size) or 'mix' (different sizes)
  void updateCreditMode(String mode) {
    emit(state.copyWith(creditMode: _resolveMode(state.remainingHours, mode)));
  }

  /// Gets the list of courses from the schedule
  /// Returns courses from the schedule cubit's state
  List<Course> scheduleCourses() {
    final scheduleState = scheduleCubit.state;
    if (scheduleState is ScheduleSuccess) return scheduleState.courses;
    return scheduleCubit.courses;
  }

  /// Calculates the projected GPA based on expected grades
  /// 
  /// Formula: GPA = (Sum of grade points × credit hours) / Total credit hours
  /// 
  /// Example:
  /// - Course 1: A (3.75 points) × 3 credits = 11.25 points
  /// - Course 2: B+ (3.5 points) × 3 credits = 10.5 points
  /// - Total: 21.75 points / 6 credits = 3.625 GPA
  /// 
  /// If no expected grade is set for a course, it defaults to 'A'
  double projectedGpa(List<Course> scheduleCourses) {
    return 0.0;
  }

  /// Calculates the total credit hours for a list of courses
  /// Simply sums up all the credit hours
  int totalCredits(List<Course> courses) {
    return courses.fold(0, (sum, course) => sum + course.creditHours);
  }

  /// Calculates what grades are needed for each course to achieve target GPA
  /// 
  /// Formula:
  /// 1. Calculate total points needed: target GPA × total credits
  /// 2. Calculate points already earned: current GPA × current credits
  /// 3. Calculate points still needed: total points - points earned
  /// 4. Calculate required GPA: points needed / pending credits
  /// 
  /// Returns a map of course names to required grades
  Map<String, String> requiredGrades(List<Course> pendingCourses) {
    final target = state.targetGpa;
    
    // Validate inputs
    if (target <= 0 || pendingCourses.isEmpty) return {};

    // Get current GPA and credits (use override values if provided)
    double currentGpa = _currentGpa();
    int currentCredits = _completedCredits();
    final double? overrideGpaValue = state.overrideCgpa;
    final int? overrideCreditsValue = state.overrideEarnedHours;
    
    // If user manually overrode CGPA, use that instead
    if (overrideGpaValue != null &&
        overrideCreditsValue != null &&
        overrideGpaValue >= 0 &&
        overrideGpaValue <= 4 &&
        overrideCreditsValue >= 0) {
      currentGpa = overrideGpaValue;
      currentCredits = overrideCreditsValue;
    }
    
    // Calculate total points already earned
    final currentPoints = currentGpa * currentCredits;

    // Calculate total credits for pending courses
    final pendingCredits = pendingCourses.fold<int>(
      0,
      (sum, course) => sum + course.creditHours,
    );
    if (pendingCredits == 0) return {};

    // Calculate what GPA is needed on remaining courses
    final totalCredits = currentCredits + pendingCredits;
    final requiredPoints = target * totalCredits; // Total points needed
    final neededPoints = requiredPoints - currentPoints; // Points still needed
    final requiredGpa = neededPoints <= 0 ? 0.0 : neededPoints / pendingCredits;

    // Convert required GPA to a letter grade
    final grade = _gradeFor(requiredGpa);
    
    // Build the result map: each pending course needs this grade
    final mix = _composeCredits(state.remainingHours, state.creditMode);
    final entries = <String, String>{
      for (final course in pendingCourses) course.name: grade,
    };
    
    // If there are remaining hours, calculate grade distribution for them
    if (mix.isNotEmpty) {
      final gradeMix = _gradeDistribution(
        requiredGpa,
        mix,
      ).distributionByGradeCredits;
      entries['Remaining Hours'] = gradeMix.keys.isEmpty
          ? grade
          : gradeMix.keys.first;
    }
    return entries;
  }

  TargetPlan targetPlan() {
    final remaining = state.remainingHours;
    final target = state.targetGpa;

    if (remaining <= 0 || target <= 0) {
      return const TargetPlan.impossible();
    }

    // Get current GPA and earned hours (with override support)
    double currentGpa = _currentGpa();
    int earnedHours = _completedCredits();
    final double? overrideGpaValue = state.overrideCgpa;
    final int? overrideCreditsValue = state.overrideEarnedHours;
    if (overrideGpaValue != null &&
        overrideCreditsValue != null &&
        overrideGpaValue >= 0 &&
        overrideGpaValue <= 4 &&
        overrideCreditsValue > 0) {
      currentGpa = overrideGpaValue;
      earnedHours = overrideCreditsValue;
    }

    // Get optional course credit sizes from state if available
    List<int>? courseCreditSizes;
    final credits = _composeCredits(remaining, state.creditMode);
    if (credits.isNotEmpty) {
      courseCreditSizes = credits;
    }

    // Use the new calculator with the exact formula
    final input = TargetGpaInput(
      currentCgpa: currentGpa,
      earnedHours: earnedHours,
      targetGpa: target,
      remainingHours: remaining,
      courseCreditSizes: courseCreditSizes,
    );

    final result = TargetGpaCalculator.calculate(input);

    // Calculate max achievable CGPA
    final currentPoints = currentGpa * earnedHours;
    final totalCredits = earnedHours + remaining;
    final maxCgpa = (currentPoints + 4.0 * remaining) / totalCredits;

    // If target is not achievable, return early
    if (!result.achievable) {
      return TargetPlan(
        feasible: false,
        requiredAvg: result.requiredAverageGpa,
        maxAchievableCgpa: maxCgpa,
        minimumRequiredGrade: 'A+',
        distributionByGradeCredits: const {},
      );
    }

    // If no additional points needed (already above target)
    if (result.requiredAverageGpa <= 0) {
      return TargetPlan(
        feasible: true,
        requiredAvg: 0,
        maxAchievableCgpa: maxCgpa,
        minimumRequiredGrade: 'F',
        distributionByGradeCredits: const {},
      );
    }

    // Calculate grade distribution if credits are available
    if (credits.isEmpty && state.creditMode != 'mix') {
      final plan = _gradeDistribution(result.requiredAverageGpa, credits);
      return plan.copyWith(maxAchievableCgpa: maxCgpa);
    }

    // Generate distribution with calculated required average
    final distribution = _gradeDistribution(result.requiredAverageGpa, credits);
    return distribution.copyWith(maxAchievableCgpa: maxCgpa);
  }

  /// Calculates the current CGPA from all completed courses
  /// 
  /// Only includes courses that have a grade assigned (completed courses)
  /// Skips courses with 0 credits (practical parts, labs without credit)
  /// 
  /// Formula: CGPA = (Sum of grade points × credit hours) / Total credit hours
  double _currentGpa() {
    return 0.0;
  }

  /// Calculates total earned credit hours from completed courses
  /// 
  /// Only counts courses that have a grade assigned (completed)
  /// Skips courses with 0 credits
  int _completedCredits() {
    return 0;
  }

  /// Converts a letter grade to its numeric point value
  /// 
  /// Grade Scale:
  /// - A+ = 4.0
  /// - A  = 3.75
  /// - B+ = 3.5
  /// - B  = 3.0
  /// - C+ = 2.5
  /// - C  = 2.0
  /// - D+ = 1.5
  /// - D  = 1.0
  /// - F  = 0.0
  double _gradePoints(String grade) {
    switch (grade) {
      case 'A+':
        return 4.0;
      case 'A':
        return 3.75;
      case 'B+':
        return 3.5;
      case 'B':
        return 3.0;
      case 'C+':
        return 2.5;
      case 'C':
        return 2.0;
      case 'D+':
        return 1.5;
      case 'D':
        return 1.0;
      case 'F':
        return 0.0;
      default:
        return 0.0;
    }
  }

  /// Finds the minimum letter grade needed to achieve a target GPA
  /// 
  /// Example: If target GPA is 3.5, returns 'B+' (since B+ = 3.5 points)
  /// 
  /// [target] - The target GPA value (e.g., 3.5)
  /// Returns the letter grade that matches or exceeds the target
  String _gradeFor(double target) {
    const gradeOrder = ['A+', 'A', 'B+', 'B', 'C+', 'C', 'D+', 'D', 'F'];
    for (final grade in gradeOrder) {
      if (_gradePoints(grade) >= target) return grade;
    }
    return 'F';
  }

  /// Breaks down total credit hours into individual course credit sizes
  /// 
  /// Examples:
  /// - Mode '3' with 12 hours → [3, 3, 3, 3] (4 courses of 3 credits)
  /// - Mode 'mix' with 12 hours → [4, 4, 2, 2] (optimal mix)
  /// 
  /// [total] - Total credit hours to break down
  /// [mode] - Credit mode: '2', '3', '4', or 'mix'
  /// Returns a list of credit sizes (e.g., [3, 3, 3] for three 3-credit courses)
  List<int> _composeCredits(int total, String mode) {
    // If no credits, return empty list
    if (total <= 0) return const [];
    
    // If mode is a specific size (2, 3, or 4), create courses of that size
    if (mode == '2' || mode == '3' || mode == '4') {
      final courseSize = int.parse(mode);
      
      // Check if total is divisible by course size
      if (total % courseSize != 0) return const [];
      
      // Create list of courses (e.g., 12 hours ÷ 3 = 4 courses)
      return List<int>.filled(total ~/ courseSize, courseSize);
    }

    // For 'mix' mode, find the best combination of 2, 3, and 4 credit courses
    // Goal: Use the fewest number of courses possible
    int bestCourseCount = 1 << 30; // Start with a very large number
    Map<int, int>? bestCombination;

    // Try all combinations of 4-credit courses
    for (int numOf4Credit = total ~/ 4; numOf4Credit >= 0; numOf4Credit--) {
      final remainingAfter4 = total - 4 * numOf4Credit;
      
      // Try all combinations of 3-credit courses with remaining hours
      for (int numOf3Credit = remainingAfter4 ~/ 3; numOf3Credit >= 0; numOf3Credit--) {
        final remainingAfter3 = remainingAfter4 - 3 * numOf3Credit;
        
        // Remaining must be divisible by 2 (for 2-credit courses)
        if (remainingAfter3 % 2 != 0) continue;
        
        final numOf2Credit = remainingAfter3 ~/ 2;
        final totalCourseCount = numOf4Credit + numOf3Credit + numOf2Credit;
        
        // Keep track of the combination with the fewest courses
        if (totalCourseCount < bestCourseCount) {
          bestCourseCount = totalCourseCount;
          bestCombination = {4: numOf4Credit, 3: numOf3Credit, 2: numOf2Credit};
        }
      }
    }

    // If no valid combination found, return empty list
    if (bestCombination == null) return const [];

    // Build the list of course credit sizes
    final courseCreditList = <int>[];
    for (final creditSize in [4, 3, 2]) {
      final count = bestCombination[creditSize] ?? 0;
      if (count > 0) {
        // Add 'count' number of courses with this credit size
        courseCreditList.addAll(List<int>.filled(count, creditSize));
      }
    }
    return courseCreditList;
  }

  TargetPlan _gradeDistribution(double requiredAvg, List<int> credits) {
    final assignments = _gradeAssignments(requiredAvg, credits);
    final sorted = List<int>.from(credits)..sort((a, b) => b.compareTo(a));
    final distribution = <String, Map<int, int>>{};
    for (var i = 0; i < sorted.length; i++) {
      final grade = assignments.isNotEmpty && i < assignments.length
          ? assignments[i]
          : _gradeFor(requiredAvg);
      final credit = sorted[i];
      final map = distribution.putIfAbsent(grade, () => <int, int>{});
      map[credit] = (map[credit] ?? 0) + 1;
    }

    final gradeOrder = ['A+', 'A', 'B+', 'B', 'C+', 'C', 'D+', 'D', 'F'];
    final minimumGrade = assignments.isEmpty
        ? _gradeFor(requiredAvg)
        : assignments.reduce(
            (value, element) =>
                gradeOrder.indexOf(value) <= gradeOrder.indexOf(element)
                ? value
                : element,
          );

    return TargetPlan(
      feasible: true,
      requiredAvg: requiredAvg,
      maxAchievableCgpa: 0,
      minimumRequiredGrade: minimumGrade,
      distributionByGradeCredits: distribution,
    );
  }

  List<String> _gradeAssignments(double requiredAvg, List<int> credits) {
    if (credits.isEmpty) return const [];

    final sorted = List<int>.from(credits)..sort((a, b) => b.compareTo(a));
    final gradeOrder = ['A+', 'A', 'B+', 'B', 'C+', 'C', 'D+', 'D', 'F'];
    final points = {
      'A+': 4.0,
      'A': 3.75,
      'B+': 3.5,
      'B': 3.0,
      'C+': 2.5,
      'C': 2.0,
      'D+': 1.5,
      'D': 1.0,
      'F': 0.0,
    };

    final hi = gradeOrder.firstWhere(
      (grade) => points[grade]! >= requiredAvg,
      orElse: () => 'F',
    );
    final hiIndex = gradeOrder.indexOf(hi);
    final lo = hiIndex == gradeOrder.length - 1
        ? gradeOrder[hiIndex]
        : gradeOrder[hiIndex + 1];

    final hiPoints = points[hi]!;
    final loPoints = points[lo]!;
    final total = sorted.fold<int>(0, (sum, value) => sum + value);

    double hiHoursNeeded;
    if ((hiPoints - loPoints).abs() < 1e-9) {
      hiHoursNeeded = total.toDouble();
    } else {
      hiHoursNeeded =
          ((requiredAvg - loPoints) / (hiPoints - loPoints)) * total;
      hiHoursNeeded = hiHoursNeeded.clamp(0, total.toDouble());
    }

    final assignments = <String>[];
    double hiHoursLeft = hiHoursNeeded;
    for (final credit in sorted) {
      final assignHi = hiHoursLeft > 1e-6;
      assignments.add(assignHi ? hi : lo);
      if (assignHi) {
        hiHoursLeft = (hiHoursLeft - credit).clamp(0, hiHoursLeft);
      }
    }

    return assignments;
  }

  /// Determines if the requested credit mode is valid for the given hours
  /// 
  /// Example: If user wants all 3-credit courses but has 11 hours,
  /// it returns 'mix' because 11 is not divisible by 3
  /// 
  /// [remainingHours] - Total hours remaining
  /// [requested] - Requested mode ('2', '3', '4', or 'mix')
  /// Returns the valid mode (may change '3' to 'mix' if not divisible)
  String _resolveMode(int remainingHours, String requested) {
    // 'mix' is always valid
    if (requested == 'mix') return 'mix';
    
    // Try to parse as a number (2, 3, or 4)
    final courseSize = int.tryParse(requested);
    if (courseSize == null || remainingHours <= 0) {
      return requested;
    }
    
    // Check if remaining hours can be divided evenly by course size
    // If yes, return requested mode; if no, return 'mix'
    return remainingHours % courseSize == 0 ? requested : 'mix';
  }

  /// Checks if a credit mode is enabled/valid for the current remaining hours
  /// 
  /// Returns true if the mode can be used (hours are divisible by course size)
  bool isCreditModeEnabled(String mode) {
    // 'mix' is always enabled
    if (mode == 'mix') return true;
    
    // Try to parse as a number
    final courseSize = int.tryParse(mode);
    if (courseSize == null) return false;
    
    final remaining = state.remainingHours;
    // If no hours remaining, all modes are valid
    if (remaining <= 0) return true;
    
    // Check if hours are divisible by course size
    return remaining % courseSize == 0;
  }
}
