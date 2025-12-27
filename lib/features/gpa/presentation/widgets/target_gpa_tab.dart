import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../schedule/data/models/course.dart';
import '../cubit/gpa_cubit.dart';
import '../cubit/gpa_state.dart';
import 'gpa_widgets.dart';
import 'target_input_card.dart';

import '../../../../core/constants/app_spacing.dart';
class TargetGpaTab extends StatelessWidget {
  const TargetGpaTab({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<GpaCubit, GpaState>(
      builder: (context, state) {
        final cubit = context.read<GpaCubit>();
        final scheduleCourses = cubit
            .scheduleCourses()
            .where((course) => course.creditHours > 0)
            .toList();
        final remaining = state.remainingHours;

        final pendingCourses = <Course>[
          ...scheduleCourses.map(
            (course) => Course(
              id: course.id,
              name: '${course.code} • ${course.name}',
              code: course.code,
              creditHours: course.creditHours,
            ),
          ),
          if (remaining > 0)
            Course(
              id: 'other',
              name: 'Other Credits ($remaining cr)',
              code: '—',
              creditHours: remaining,
            ),
        ];

        final requiredGrades = cubit.requiredGrades(pendingCourses);
        final plan = cubit.targetPlan();

        return SingleChildScrollView(
          padding: AppSpacing.paddingLG,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const TargetInputCard(),
              AppSpacing.verticalSpaceXXL,
              if (state.targetGpa > 0 && requiredGrades.isNotEmpty) ...[
                SummaryHighlight(
                  title: 'Minimum grade required',
                  value: plan.minimumRequiredGrade,
                  helper: 'Required on remaining hours to reach your goal.',
                ),
                AppSpacing.verticalSpaceMD,
                SummaryHighlight(
                  title: 'Maximum achievable GPA',
                  value: plan.maxAchievableCgpa.toStringAsFixed(2),
                  helper: 'Assuming straight A+ on all remaining credits.',
                ),
                AppSpacing.verticalSpaceMD,
                ...requiredGrades.entries.map(
                  (entry) =>
                      GradeChipTile(title: entry.key, grade: entry.value),
                ),
                AppSpacing.verticalSpaceXXL,
              ],
              if (state.targetGpa > 0 && state.remainingHours > 0)
                TargetPlanSection(plan: plan),
            ],
          ),
        );
      },
    );
  }
}
