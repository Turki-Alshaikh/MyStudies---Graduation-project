/// Target GPA Calculator
///
/// Calculates the required average GPA needed to achieve a target GPA
/// using the formula:
/// requiredAverageGpa = ((targetGpa * (earnedHours + remainingHours)) - (currentCgpa * earnedHours)) / remainingHours

/// Input model for target GPA calculation
class TargetGpaInput {
  /// Current cumulative GPA (0.0 - 4.0)
  final double currentCgpa;

  /// Total credit hours already earned
  final int earnedHours;

  /// Desired target GPA (0.0 - 4.0)
  final double targetGpa;

  /// Remaining credit hours to complete
  final int remainingHours;

  /// Optional: Specific credit hour sizes for remaining courses
  /// Example: [3, 3, 4] means three courses with 3, 3, and 4 credit hours
  final List<int>? courseCreditSizes;

  const TargetGpaInput({
    required this.currentCgpa,
    required this.earnedHours,
    required this.targetGpa,
    required this.remainingHours,
    this.courseCreditSizes,
  });

  /// Validates that all input values are valid
  bool isValid() {
    return currentCgpa >= 0 &&
        currentCgpa <= 4.0 &&
        earnedHours >= 0 &&
        targetGpa >= 0 &&
        targetGpa <= 4.0 &&
        remainingHours > 0 &&
        (courseCreditSizes == null ||
            (courseCreditSizes!.isNotEmpty &&
                courseCreditSizes!.every((size) => size > 0)));
  }
}

/// Result model for target GPA calculation
class TargetGpaResult {
  /// The required average GPA needed in remaining courses
  final double requiredAverageGpa;

  /// Whether the target is achievable (requiredAverageGpa <= 4.0)
  final bool achievable;

  /// Human-readable message explaining the result
  final String message;

  /// Optional: Letter grade equivalent of required average GPA
  final String? letterGrade;

  const TargetGpaResult({
    required this.requiredAverageGpa,
    required this.achievable,
    required this.message,
    this.letterGrade,
  });
}

/// Target GPA Calculator
class TargetGpaCalculator {
  /// Calculates the required average GPA to achieve target GPA
  ///
  /// Returns [TargetGpaResult] with calculated values and validation results
  static TargetGpaResult calculate(TargetGpaInput input) {
    // Validate inputs
    if (!input.isValid()) {
      return const TargetGpaResult(
        requiredAverageGpa: 0.0,
        achievable: false,
        message:
            'Invalid input values. Please check your GPA and credit hours.',
      );
    }

    // Validate that hours are positive
    if (input.earnedHours < 0 || input.remainingHours <= 0) {
      return const TargetGpaResult(
        requiredAverageGpa: 0.0,
        achievable: false,
        message:
            'Credit hours must be positive. Remaining hours must be greater than 0.',
      );
    }

    // Calculate required average GPA using the formula:
    // requiredAverageGpa = ((targetGpa * (earnedHours + remainingHours)) - (currentCgpa * earnedHours)) / remainingHours
    final totalHours = input.earnedHours + input.remainingHours;
    final targetTotalPoints = input.targetGpa * totalHours;
    final currentTotalPoints = input.currentCgpa * input.earnedHours;
    final requiredPoints = targetTotalPoints - currentTotalPoints;
    final requiredAverageGpa = requiredPoints / input.remainingHours;

    // Validate if target is achievable (GPA cannot exceed 4.0)
    final isAchievable = requiredAverageGpa <= 4.0;

    // Map GPA to letter grade if applicable
    final letterGrade = _gpaToLetterGrade(requiredAverageGpa);

    // Generate message
    final message = _generateMessage(
      requiredAverageGpa,
      isAchievable,
      input.targetGpa,
      input.remainingHours,
    );

    return TargetGpaResult(
      requiredAverageGpa: requiredAverageGpa,
      achievable: isAchievable,
      message: message,
      letterGrade: letterGrade,
    );
  }

  /// Maps GPA value to letter grade
  ///
  /// Common grading scale:
  /// A+ = 4.0
  /// A  = 3.75
  /// B+ = 3.5
  /// B  = 3.0
  /// C+ = 2.5
  /// C  = 2.0
  /// D+ = 1.5
  /// D  = 1.0
  /// F  = 0.0
  static String? _gpaToLetterGrade(double gpa) {
    if (gpa >= 4.0) return 'A+';
    if (gpa >= 3.75) return 'A';
    if (gpa >= 3.5) return 'B+';
    if (gpa >= 3.0) return 'B';
    if (gpa >= 2.5) return 'C+';
    if (gpa >= 2.0) return 'C';
    if (gpa >= 1.5) return 'D+';
    if (gpa >= 1.0) return 'D';
    if (gpa >= 0.0) return 'F';
    return null;
  }

  /// Generates a human-readable message explaining the calculation result
  static String _generateMessage(
    double requiredAverageGpa,
    bool isAchievable,
    double targetGpa,
    int remainingHours,
  ) {
    if (!isAchievable) {
      return 'Target GPA of $targetGpa is not achievable. '
          'You would need an average GPA of ${requiredAverageGpa.toStringAsFixed(2)} '
          'in your remaining $remainingHours credit hours, which exceeds the maximum 4.0 GPA.';
    }

    final gradeText = _gpaToLetterGrade(requiredAverageGpa) != null
        ? ' (${_gpaToLetterGrade(requiredAverageGpa)})'
        : '';

    return 'To achieve a target GPA of $targetGpa, you need an average GPA of '
        '${requiredAverageGpa.toStringAsFixed(2)}$gradeText '
        'in your remaining $remainingHours credit hours.';
  }
}
