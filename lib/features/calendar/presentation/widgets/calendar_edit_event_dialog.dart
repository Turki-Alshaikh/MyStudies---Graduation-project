import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/models/event.dart';
import '../../../schedule/presentation/cubits/schedule_cubit.dart';
import '../../../../core/widgets/app_snackbar.dart';
import '../../../../core/widgets/ios_time_picker_dialog.dart';
import '../cubits/reminder_cubit.dart';

import '../../../../core/constants/app_spacing.dart';

Future<void> showEditEventDialog(BuildContext context, Event event) async {
  final titleController = TextEditingController(text: event.title);
  final courseController = TextEditingController(text: event.course);
  EventType selectedType = event.type;
  DateTime selectedDate = event.dateTime;
  TimeOfDay selectedTime = TimeOfDay(
    hour: event.dateTime.hour,
    minute: event.dateTime.minute,
  );

  await showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: const Text('Edit Event'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleController,
                decoration: const InputDecoration(labelText: 'Title'),
              ),
              AppSpacing.verticalSpaceMD,
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8, left: 4),
                    child: Text(
                      'Type',
                      style: TextStyle(
                        fontSize: 12,
                        color: Theme.of(context).textTheme.bodySmall?.color,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  StatefulBuilder(
                    builder: (context, setState) => PopupMenuButton<EventType>(
                      initialValue: selectedType,
                      onSelected: (v) => setState(() => selectedType = v),
                      itemBuilder: (context) => EventType.values
                          .map(
                            (e) => PopupMenuItem<EventType>(
                              value: e,
                              child: Row(
                                children: [
                                  if (e == selectedType)
                                    Icon(
                                      Icons.check,
                                      size: 18,
                                      color: Theme.of(context)
                                          .colorScheme
                                          .primary,
                                    )
                                  else
                                    const SizedBox(width: 18),
                                  const SizedBox(width: 8),
                                  Text(
                                    e == EventType.course
                                        ? 'Other'
                                        : e.name[0].toUpperCase() + e.name.substring(1),
                                  ),
                                ],
                              ),
                            ),
                          )
                          .toList(),
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 14,
                        ),
                        decoration: BoxDecoration(
                          color: Theme.of(context).cardColor,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: Theme.of(context)
                                .dividerColor
                                .withOpacity(0.2),
                            width: 1,
                          ),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                selectedType == EventType.course
                                    ? 'Other'
                                    : selectedType.name[0].toUpperCase() +
                                        selectedType.name.substring(1),
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 16,
                                  color: Theme.of(context)
                                      .textTheme
                                      .bodyLarge
                                      ?.color,
                                ),
                              ),
                            ),
                            Icon(
                              Icons.arrow_drop_down_rounded,
                              color: Theme.of(context)
                                  .textTheme
                                  .bodyMedium
                                  ?.color,
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
                  ),
                ],
              ),
              AppSpacing.verticalSpaceMD,
              TextField(
                controller: courseController,
                decoration: const InputDecoration(
                  labelText: 'Course (e.g., CS 473)',
                ),
              ),
              AppSpacing.verticalSpaceMD,
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () async {
                        final d = await showDatePicker(
                          context: context,
                          initialDate: selectedDate,
                          firstDate: DateTime(2020),
                          lastDate: DateTime(2035),
                        );
                        if (d != null) selectedDate = d;
                      },
                      child: Text(DateFormat('yMMMd').format(selectedDate)),
                    ),
                  ),
                  AppSpacing.horizontalSpaceSM,
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () async {
                        final t = await showIOSTimePicker(
                          context: context,
                          initialTime: selectedTime,
                        );
                        if (t != null) selectedTime = t;
                      },
                      child: Text(selectedTime.format(context)),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (titleController.text.trim().isEmpty) return;
              final dt = DateTime(
                selectedDate.year,
                selectedDate.month,
                selectedDate.day,
                selectedTime.hour,
                selectedTime.minute,
              );

              // Check if dateTime has changed
              final dateTimeChanged = dt != event.dateTime;

              // If dateTime changed, remove all reminders for this event
              if (dateTimeChanged) {
                context.read<ReminderCubit>().removeRemindersForEvent(event.id);
              }

              final updated = Event(
                id: event.id,
                courseId: event.courseId,
                title: titleController.text.trim(),
                dateTime: dt,
                type: selectedType,
                course: courseController.text.trim(),
                description: event.description,
                reminders: event.reminders,
              );
              final ok = context.read<ScheduleCubit>().updateEvent(updated);
              if (ok) {
                AppSnackBars.showSuccess(
                  context,
                  dateTimeChanged
                      ? 'Event updated. Reminders have been removed due to time change.'
                      : 'Event updated.',
                );
                Navigator.pop(context);
              } else {
                AppSnackBars.showError(context, 'Could not update event.');
              }
            },
            child: const Text('Save'),
          ),
        ],
      );
    },
  );
}
