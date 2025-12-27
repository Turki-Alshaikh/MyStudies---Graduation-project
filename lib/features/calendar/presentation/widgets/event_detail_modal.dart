import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../data/models/event.dart';
import 'event_reminder_list.dart';

import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_sizes.dart';

Future<void> showEventDetailModal(BuildContext context, Event event) async {
  await showDialog(
    context: context,
    barrierColor: Colors.black87.withOpacity(0.65),
    builder: (context) {
      return Dialog(
        shape: RoundedRectangleBorder(borderRadius: AppSpacing.borderRadiusXXL),
        insetPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.xl - 2,
          vertical: AppSpacing.iconXXL,
        ),
        backgroundColor: Theme.of(context).dialogBackgroundColor,
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.xxl,
                AppSpacing.iconLG,
                AppSpacing.xxl,
                AppSpacing.xl - 2,
              ),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(
                          event.type == EventType.exam
                              ? Icons.task_alt_rounded
                              : event.type == EventType.assignment
                              ? Icons.assignment_rounded
                              : Icons.event_note,
                          color: event.color,
                          size: AppSpacing.iconLG,
                        ),
                        const SizedBox(width: AppSpacing.md - 2),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                event.title,
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: AppSizes.fontXXL + 2,
                                ),
                              ),
                              const SizedBox(height: 5),
                              Row(
                                children: [
                                  _typeChip(event),
                                  if (event.course.isNotEmpty) ...[
                                    AppSpacing.horizontalSpaceSM,
                                    Text(
                                      event.course,
                                      style: TextStyle(
                                        fontSize: AppSizes.fontMD,
                                        fontWeight: FontWeight.w600,
                                        color: Theme.of(context)
                                            .textTheme
                                            .bodyMedium
                                            ?.color
                                            ?.withOpacity(0.7),
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          icon: Icon(
                            Icons.close,
                            size: AppSpacing.iconMD + 2,
                            color: Colors.grey[500],
                          ),
                          splashRadius: 22,
                          onPressed: () => Navigator.pop(context),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    Divider(),
                    AppSpacing.verticalSpaceXS,
                    Text(
                      DateFormat(
                        'EEE, MMM d, yyyy • h:mm a',
                      ).format(event.dateTime),
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: AppSizes.fontMD + 1,
                        color: event.color.withOpacity(0.85),
                      ),
                    ),
                    if (event.description?.isNotEmpty == true) ...[
                      const SizedBox(height: 10),
                      Text(
                        event.description!,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ],
                    AppSpacing.verticalSpaceXL,
                    Text(
                      'Reminders',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: AppSizes.fontLG + 1,
                      ),
                    ),
                    AppSpacing.verticalSpaceMD,
                    EventReminderList(
                      eventId: event.id,
                      eventTitle: event.title,
                      isDialog: true,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      );
    },
  );
}

Widget _typeChip(Event event) {
  final chipColor = event.type == EventType.exam
      ? Colors.red[300]
      : event.type == EventType.assignment
      ? Colors.orange[300]
      : Colors.cyan[400];
  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
    decoration: BoxDecoration(
      color: chipColor?.withOpacity(0.21),
      borderRadius: AppSpacing.borderRadiusSM,
    ),
    child: Text(
      event.type.name.toUpperCase(),
      style: TextStyle(
        fontSize: AppSizes.fontXS + 1.5,
        fontWeight: FontWeight.bold,
        color: chipColor,
        letterSpacing: 0.5,
      ),
    ),
  );
}
