import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../calendar/data/models/event.dart';
import 'home_deadline_card.dart';

import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_sizes.dart';
class HomeDeadlinesSection extends StatelessWidget {
  final List<Event> deadlines;

  const HomeDeadlinesSection({super.key, required this.deadlines});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                color: AppTheme.assignmentOrange.withOpacity(0.1),
                borderRadius: BorderRadius.circular(AppSpacing.radiusSM - 2),
              ),
              child: Icon(
                Icons.event_note_rounded,
                color: AppTheme.assignmentOrange,
                size: AppSpacing.iconSM,
              ),
            ),
            const SizedBox(width: AppSpacing.md - 2),
            Text(
              'Upcoming Deadlines',
              style: TextStyle(
                fontSize: AppSizes.fontXXL,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).brightness == Brightness.dark
                    ? Colors.white
                    : AppTheme.textPrimary,
              ),
            ),
          ],
        ),
        AppSpacing.verticalSpaceMD,
        if (deadlines.isEmpty)
          Container(
            width: double.infinity,
            padding: AppSpacing.paddingXL,
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: AppSpacing.borderRadiusLG,
              border: Border.all(
                color: Theme.of(context).dividerColor.withOpacity(0.1),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.emoji_events_outlined,
                  color: Theme.of(
                    context,
                  ).textTheme.bodyMedium?.color?.withOpacity(0.6),
                ),
                AppSpacing.horizontalSpaceMD,
                Expanded(
                  child: Text(
                    'No upcoming deadlines. Add one or import from your schedule.',
                    style: TextStyle(
                      color: Theme.of(
                        context,
                      ).textTheme.bodyMedium?.color?.withOpacity(0.7),
                    ),
                  ),
                ),
              ],
            ),
          )
        else
          ...deadlines.map((deadline) => HomeDeadlineCard(deadline: deadline)),
      ],
    );
  }
}
