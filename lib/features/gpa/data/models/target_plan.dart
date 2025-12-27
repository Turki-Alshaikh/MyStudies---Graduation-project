import 'package:equatable/equatable.dart';

class TargetPlan extends Equatable {
  final bool feasible;
  final double requiredAvg;
  final double maxAchievableCgpa;
  final String minimumRequiredGrade;
  final Map<String, Map<int, int>> distributionByGradeCredits;

  const TargetPlan({
    required this.feasible,
    required this.requiredAvg,
    required this.maxAchievableCgpa,
    required this.minimumRequiredGrade,
    required this.distributionByGradeCredits,
  });

  const TargetPlan.impossible()
      : feasible = false,
        requiredAvg = 0,
        maxAchievableCgpa = 0,
        minimumRequiredGrade = 'F',
        distributionByGradeCredits = const {};

  TargetPlan copyWith({
    bool? feasible,
    double? requiredAvg,
    double? maxAchievableCgpa,
    String? minimumRequiredGrade,
    Map<String, Map<int, int>>? distributionByGradeCredits,
  }) {
    return TargetPlan(
      feasible: feasible ?? this.feasible,
      requiredAvg: requiredAvg ?? this.requiredAvg,
      maxAchievableCgpa: maxAchievableCgpa ?? this.maxAchievableCgpa,
      minimumRequiredGrade: minimumRequiredGrade ?? this.minimumRequiredGrade,
      distributionByGradeCredits:
          distributionByGradeCredits ?? this.distributionByGradeCredits,
    );
  }

  @override
  List<Object?> get props =>
      [
        feasible,
        requiredAvg,
        maxAchievableCgpa,
        minimumRequiredGrade,
        distributionByGradeCredits,
      ];
}
