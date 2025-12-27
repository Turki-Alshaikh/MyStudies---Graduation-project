import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import '../../data/models/target_plan.dart';

import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_sizes.dart';
/// Summary highlight card for target GPA
class SummaryHighlight extends StatelessWidget {
  final String title;
  final String value;
  final String helper;

  const SummaryHighlight({
    super.key,
    required this.title,
    required this.value,
    required this.helper,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Card(
      child: Padding(
        padding: AppSpacing.paddingLG,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: AppSizes.fontMD,
                fontWeight: FontWeight.w600,
                color: isDark ? Colors.white70 : AppTheme.textSecondary,
              ),
            ),
            AppSpacing.verticalSpaceXS,
            Text(
              value,
              style: TextStyle(
                fontSize: AppSizes.fontXXXL,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : AppTheme.textPrimary,
              ),
            ),
            AppSpacing.verticalSpaceXS,
            Text(
              helper,
              style: TextStyle(
                fontSize: AppSizes.fontSM,
                color: Theme.of(
                  context,
                ).textTheme.bodySmall?.color?.withOpacity(0.75),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Grade chip tile
class GradeChipTile extends StatelessWidget {
  final String title;
  final String grade;

  const GradeChipTile({super.key, required this.title, required this.grade});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: ListTile(
        title: Text(
          title,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: Theme.of(context).brightness == Brightness.dark
                ? Colors.white
                : AppTheme.textPrimary,
          ),
        ),
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: 6),
          decoration: BoxDecoration(
            color: gradeColor(grade),
            borderRadius: AppSpacing.borderRadiusMD,
          ),
          child: Text(
            grade,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: AppSizes.fontSM,
            ),
          ),
        ),
      ),
    );
  }
}

/// Target plan section
class TargetPlanSection extends StatelessWidget {
  final TargetPlan plan;

  const TargetPlanSection({super.key, required this.plan});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Card(
          child: Container(
            width: double.infinity,
            padding: AppSpacing.paddingXL,
            decoration: BoxDecoration(
              borderRadius: AppSpacing.borderRadiusLG,
              gradient: LinearGradient(
                colors: [
                  AppTheme.assignmentOrange,
                  AppTheme.assignmentOrange.withOpacity(0.8),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Target Plan',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: AppSizes.fontXL,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                AppSpacing.verticalSpaceSM,
                Text(
                  'Needed GPA on remaining: ${plan.requiredAvg.toStringAsFixed(2)}',
                  style: const TextStyle(color: Colors.white70),
                ),
                AppSpacing.verticalSpaceSM,
                Text(
                  'Maximum achievable GPA: ${plan.maxAchievableCgpa.toStringAsFixed(2)}',
                  style: const TextStyle(color: Colors.white70),
                ),
                if (!plan.feasible) ...[
                  AppSpacing.verticalSpaceSM,
                  const Text(
                    'Goal is not achievable with current inputs.',
                    style: TextStyle(color: Colors.white),
                  ),
                ],
                if (plan.feasible && plan.requiredAvg <= 0) ...[
                  AppSpacing.verticalSpaceSM,
                  const Text(
                    'Already on track — no minimum requirement!',
                    style: TextStyle(color: Colors.white),
                  ),
                ],
              ],
            ),
          ),
        ),
        AppSpacing.verticalSpaceLG,
        if (plan.feasible && plan.distributionByGradeCredits.isNotEmpty) ...[
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Text(
              'Example grade mix',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: AppSizes.fontLG,
                color: isDark ? Colors.white : AppTheme.textPrimary,
              ),
            ),
          ),
          AppSpacing.verticalSpaceSM,
          ...plan.distributionByGradeCredits.entries.map(
            (entry) =>
                DistributionTile(grade: entry.key, creditCounts: entry.value),
          ),
        ] else if (plan.feasible &&
            plan.distributionByGradeCredits.isEmpty) ...[
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Text(
              'Unable to represent remaining hours with the selected credit size. Choose Mix or adjust.',
              style: TextStyle(
                color: Colors.orange.shade700,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ],
    );
  }
}

/// Distribution tile for grade mix
class DistributionTile extends StatelessWidget {
  final String grade;
  final Map<int, int> creditCounts;

  const DistributionTile({
    super.key,
    required this.grade,
    required this.creditCounts,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Card(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: gradeColor(grade),
          child: const Icon(Icons.school, color: Colors.white, size: AppSizes.fontXL),
        ),
        title: Text(
          _formatCreditCounts(creditCounts),
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: isDark ? Colors.white : AppTheme.textPrimary,
          ),
        ),
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: 6),
          decoration: BoxDecoration(
            color: gradeColor(grade).withOpacity(0.15),
            borderRadius: AppSpacing.borderRadiusMD,
          ),
          child: Text(
            grade,
            style: TextStyle(
              color: gradeColor(grade),
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }

  String _formatCreditCounts(Map<int, int> counts) {
    final parts = <String>[];
    for (final size in [4, 3, 2]) {
      final count = counts[size] ?? 0;
      if (count > 0) parts.add('$size cr × $count');
    }
    return parts.isEmpty ? '—' : parts.join(', ');
  }
}

/// Helper function to get color for grade
Color gradeColor(String grade) {
  switch (grade) {
    case 'A+':
    case 'A':
      return Colors.green;
    case 'B+':
    case 'B':
      return Colors.blue;
    case 'C+':
    case 'C':
      return Colors.orange;
    case 'D+':
    case 'D':
      return Colors.red.shade300;
    case 'F':
      return Colors.red;
    default:
      return Colors.grey;
  }
}
