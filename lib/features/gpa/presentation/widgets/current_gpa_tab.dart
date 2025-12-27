import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/app_cards.dart';
import '../cubit/gpa_cubit.dart';
import 'expected_course_tile.dart';
import 'gpa_summary_card.dart';

import '../../../../core/constants/app_spacing.dart';
class CurrentGpaTab extends StatelessWidget {
  const CurrentGpaTab({super.key});

  @override
  Widget build(BuildContext context) {
    final gpaCubit = context.read<GpaCubit>();
    // Filter out practical parts (courses with 0 or null credits)
    final scheduleCourses = gpaCubit
        .scheduleCourses()
        .where((course) => course.creditHours > 0)
        .toList();

    final expectedGrades = context.select(
      (GpaCubit cubit) => cubit.state.expectedGrades,
    );
    final projectedGpa = gpaCubit.projectedGpa(scheduleCourses);
    final totalCredits = gpaCubit.totalCredits(scheduleCourses);

    return SingleChildScrollView(
      padding: AppSpacing.paddingLG,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GpaSummaryCard(gpa: projectedGpa, credits: totalCredits),
          AppSpacing.verticalSpaceXXL,
          AppSectionHeader(
            title: 'Current Courses',
            icon: Icons.school_outlined,
            iconColor: AppTheme.primaryTeal,
          ),
          if (scheduleCourses.isEmpty)
            Text(
              'No courses found. Import your schedule to begin tracking GPA.',
              style: TextStyle(
                color: Theme.of(context).textTheme.bodyMedium?.color,
              ),
            )
          else
            ...scheduleCourses.map(
              (course) => ExpectedCourseTile(
                course: course,
                selected: expectedGrades[course.id] ?? 'A',
                onChanged: (grade) =>
                    context.read<GpaCubit>().setExpectedGrade(course.id, grade),
              ),
            ),
        ],
      ),
    );
  }
}
