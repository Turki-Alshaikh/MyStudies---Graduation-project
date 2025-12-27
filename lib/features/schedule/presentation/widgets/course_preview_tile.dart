import 'package:flutter/material.dart';

import '../../../../core/constants/app_spacing.dart';
import '../../presentation/cubits/schedule_cubit.dart';

class CoursePreviewTile extends StatelessWidget {
  const CoursePreviewTile({super.key, required this.course});

  final CourseImportSummary course;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final cardColor = theme.brightness == Brightness.dark
        ? colorScheme.surfaceVariant.withOpacity(0.4)
        : colorScheme.surfaceVariant.withOpacity(0.9);
    final textTheme = theme.textTheme;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: AppSpacing.borderRadiusMD,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '${course.code} • ${course.name}',
            style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
          ),
          AppSpacing.verticalSpaceXS,
          Text(
            '${course.meetingCount} meeting${course.meetingCount == 1 ? '' : 's'}',
            style: textTheme.bodySmall?.copyWith(
              color: textTheme.bodySmall?.color?.withOpacity(0.7),
            ),
          ),
          if (course.meetingDetails.isNotEmpty) ...[
            AppSpacing.verticalSpaceSM,
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: course.meetingDetails
                  .map((detail) => _MeetingPill(label: detail))
                  .toList(),
            ),
          ],
        ],
      ),
    );
  }
}

class _MeetingPill extends StatelessWidget {
  const _MeetingPill({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final background = colorScheme.primary.withOpacity(
      theme.brightness == Brightness.dark ? 0.18 : 0.12,
    );

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: theme.textTheme.bodySmall?.copyWith(
          color: colorScheme.primary,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
