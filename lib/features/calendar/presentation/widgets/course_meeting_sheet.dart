import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../core/constants/app_spacing.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../schedule/data/models/course.dart';
import '../../../schedule/data/models/course_meeting.dart';
import 'calendar_manage_sheets.dart';

Future<void> showCourseMeetingSheet(
  BuildContext context, {
  required Course course,
  required CourseMeeting meeting,
  required DateTime occurrenceDate,
}) async {
  await showModalBottomSheet(
    context: context,
    backgroundColor: Theme.of(context).scaffoldBackgroundColor,
    shape: RoundedRectangleBorder(
      borderRadius: AppSpacing.borderRadiusLG,
    ),
    builder: (ctx) => _CourseMeetingSheet(
      course: course,
      meeting: meeting,
      occurrenceDate: occurrenceDate,
    ),
  );
}

class _CourseMeetingSheet extends StatelessWidget {
  const _CourseMeetingSheet({
    required this.course,
    required this.meeting,
    required this.occurrenceDate,
  });

  final Course course;
  final CourseMeeting meeting;
  final DateTime occurrenceDate;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final timeRange = _formatTimeRange(meeting);
    final dateLabel = DateFormat('EEEE, MMM d').format(occurrenceDate);
    final locationParts = [
      if (course.building != null && course.building!.isNotEmpty)
        course.building,
      if (course.room != null && course.room!.isNotEmpty) course.room,
    ].whereType<String>().toList();

    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppTheme.primaryTeal.withOpacity(0.1),
                  borderRadius: AppSpacing.borderRadiusMD,
                ),
                child: Icon(
                  Icons.class_,
                  color: AppTheme.primaryTeal,
                  size: 28,
                ),
              ),
              AppSpacing.horizontalSpaceMD,
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      course.code,
                      style: textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: AppTheme.primaryTeal,
                      ),
                    ),
                    AppSpacing.verticalSpaceXS,
                    Text(
                      course.name,
                      style: textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (locationParts.isNotEmpty) ...[
                      AppSpacing.verticalSpaceXS,
                      Row(
                        children: [
                          const Icon(Icons.place, size: 18),
                          AppSpacing.horizontalSpaceXS,
                          Expanded(
                            child: Text(
                              locationParts.join(' • '),
                              style: textTheme.bodyMedium,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
          AppSpacing.verticalSpaceXL,
          _DetailRow(
            icon: Icons.calendar_today,
            label: 'Date',
            value: dateLabel,
          ),
          AppSpacing.verticalSpaceMD,
          _DetailRow(
            icon: Icons.schedule,
            label: 'Time',
            value: timeRange,
          ),
          AppSpacing.verticalSpaceMD,
          _DetailRow(
            icon: Icons.repeat,
            label: 'Frequency',
            value: 'Weekly on ${DateFormat('EEEE').format(occurrenceDate)}',
          ),
          AppSpacing.verticalSpaceXL,
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    showManageCourseSheet(context, course);
                  },
                  child: const Text('Manage Course'),
                ),
              ),
              AppSpacing.horizontalSpaceMD,
              Expanded(
                child: FilledButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Close'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _formatTimeRange(CourseMeeting meeting) {
    String formatMinutes(int minutes) {
      final dt = DateTime(0, 1, 1, minutes ~/ 60, minutes % 60);
      return DateFormat('h:mm a').format(dt);
    }

    return '${formatMinutes(meeting.startMinutes)} - ${formatMinutes(meeting.endMinutes)}';
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20),
        AppSpacing.horizontalSpaceMD,
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: textTheme.bodySmall?.copyWith(
                  color: textTheme.bodySmall?.color?.withOpacity(0.7),
                ),
              ),
              AppSpacing.verticalSpaceXS,
              Text(
                value,
                style: textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
