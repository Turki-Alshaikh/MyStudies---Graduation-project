import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/constants/app_spacing.dart';
import '../../../schedule/data/models/course.dart';

class ExpectedCourseTile extends StatelessWidget {
  final Course course;
  final String selected;
  final ValueChanged<String> onChanged;

  static const grades = ['A+', 'A', 'B+', 'B', 'C+', 'C', 'D+', 'D', 'F'];

  const ExpectedCourseTile({
    super.key,
    required this.course,
    required this.selected,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: AppSpacing.cardMargin,
      child: Padding(
        padding: AppSpacing.paddingMD,
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${course.code} • ${course.name}',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: Theme.of(context).textTheme.bodyLarge?.color,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  AppSpacing.verticalSpaceXS,
                  Text(
                    'Credits: ${course.creditHours}',
                    style: TextStyle(
                      color: Theme.of(
                        context,
                      ).textTheme.bodyMedium?.color?.withOpacity(0.7),
                    ),
                  ),
                ],
              ),
            ),
            AppSpacing.horizontalSpaceMD,
            PopupMenuButton<String>(
              initialValue: selected,
              onSelected: (value) {
                HapticFeedback.selectionClick();
                onChanged(value);
              },
              itemBuilder: (context) => grades
                  .map(
                    (grade) => PopupMenuItem<String>(
                      value: grade,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (grade == selected)
                            Icon(
                              Icons.check,
                              size: 18,
                              color: Theme.of(context).colorScheme.primary,
                            )
                          else
                            const SizedBox(width: 18),
                          const SizedBox(width: 8),
                          Text(
                            grade,
                            style: TextStyle(
                              fontWeight: grade == selected
                                  ? FontWeight.w600
                                  : FontWeight.normal,
                              color: grade == selected
                                  ? Theme.of(context).colorScheme.primary
                                  : Theme.of(context).textTheme.bodyMedium?.color,
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                  .toList(),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Theme.of(context).dividerColor.withOpacity(0.2),
                    width: 1,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      selected,
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                        color: Theme.of(context).textTheme.bodyLarge?.color,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Icon(
                      Icons.arrow_drop_down_rounded,
                      color: Theme.of(context).textTheme.bodyMedium?.color,
                    ),
                  ],
                ),
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              color: Theme.of(context).cardColor,
              elevation: 4,
            ),
          ],
        ),
      ),
    );
  }
}
