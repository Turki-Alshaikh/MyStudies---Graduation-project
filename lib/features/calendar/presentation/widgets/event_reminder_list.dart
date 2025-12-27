import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/constants/app_sizes.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/widgets/app_snackbar.dart';
import '../../../schedule/presentation/cubits/schedule_cubit.dart';
import '../../data/models/event.dart';
import '../../data/models/reminder.dart';
import '../cubits/reminder_cubit.dart';
import 'reminder_picker_dialog.dart';

class EventReminderList extends StatelessWidget {
  final String eventId;
  final String eventTitle;
  final bool isDialog;
  const EventReminderList({
    Key? key,
    required this.eventId,
    required this.eventTitle,
    this.isDialog = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ReminderCubit, ReminderState>(
      builder: (context, state) {
        final reminders = state.reminders
            .where((r) => r.eventId == eventId)
            .toList();
        final eventDate = _findEventTime(eventId, context);
        final padding = isDialog
            ? const EdgeInsets.symmetric(vertical: 8.0)
            : EdgeInsets.zero;
        return Padding(
          padding: padding,
          child: Column(
            crossAxisAlignment: isDialog
                ? CrossAxisAlignment.center
                : CrossAxisAlignment.start,
            children: [
              if (reminders.isEmpty) ...[
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 11),
                  child: Column(
                    children: [
                      Icon(
                        Icons.alarm_add_rounded,
                        size: 34,
                        color: Colors.grey.withOpacity(0.45),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        'No reminders set.',
                        style: TextStyle(
                          color: Colors.grey.withOpacity(0.75),
                          fontWeight: FontWeight.w500,
                          fontSize: AppSizes.fontMD + 1,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              ...reminders.map(
                (r) => ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(
                    eventDate != null
                        ? _formatLeadTime(r, eventDate)
                        : 'Reminder',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: AppSizes.fontMD + 1,
                    ),
                  ),
                  subtitle: Text('At ${_fmt(context, r.triggerTime)}'),
                  trailing: IconButton(
                    icon: Icon(Icons.delete_outline),
                    onPressed: () =>
                        context.read<ReminderCubit>().removeReminder(r.id),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              if (isDialog)
                Center(
                  child: SizedBox(
                    width: 160,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).colorScheme.primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                        minimumSize: const Size(160, 42),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(13),
                        ),
                        textStyle: TextStyle(fontWeight: FontWeight.bold),
                        elevation: AppSpacing.elevationXS,
                      ),
                      onPressed: () async {
                        final d = await showDialog<Duration>(
                          context: context,
                          builder: (context) => ReminderPickerDialog(),
                        );
                        if (d == null || d <= Duration.zero) return;
                        final now = DateTime.now();
                        final base = _findEventTime(eventId, context);
                        if (base != null) {
                          final scheduledTime = base.subtract(d);
                          if (scheduledTime.isBefore(now)) {
                            AppSnackBars.showError(
                              context,
                              'Reminder must be set before the event and in the future.',
                            );
                            return;
                          }
                          final reminder = Reminder(
                            id: UniqueKey().toString(),
                            eventId: eventId,
                            message: 'Reminder for $eventTitle',
                            triggerTime: scheduledTime,
                            createdAt: now,
                          );
                          final event = _findEvent(eventId, context);
                          context.read<ReminderCubit>().addReminder(
                            reminder,
                            eventTitle: eventTitle,
                            courseId: event?.courseId,
                          );
                          AppSnackBars.showSuccess(context, 'Reminder set!');
                        }
                      },
                      child: Text(
                        'Add',
                        style: TextStyle(fontSize: AppSizes.fontLG),
                      ),
                    ),
                  ),
                )
              else
                TextButton.icon(
                  icon: Icon(Icons.add_alert),
                  label: Text('Add Reminder'),
                  onPressed: () async {
                    final d = await showDialog<Duration>(
                      context: context,
                      builder: (context) => ReminderPickerDialog(),
                    );
                    if (d == null || d <= Duration.zero) return;
                    final now = DateTime.now();
                    final base = _findEventTime(eventId, context);
                    if (base != null) {
                      final scheduledTime = base.subtract(d);
                      if (scheduledTime.isBefore(now)) {
                        AppSnackBars.showError(
                          context,
                          'Reminder must be set before the event and in the future.',
                        );
                        return;
                      }
                      final reminder = Reminder(
                        id: UniqueKey().toString(),
                        eventId: eventId,
                        message: 'Reminder for $eventTitle',
                        triggerTime: scheduledTime,
                        createdAt: now,
                      );
                      context.read<ReminderCubit>().addReminder(
                        reminder,
                        eventTitle: eventTitle,
                      );
                      AppSnackBars.showSuccess(context, 'Reminder set!');
                    }
                  },
                ),
            ],
          ),
        );
      },
    );
  }

  DateTime? _findEventTime(String eventId, BuildContext context) {
    final event = _findEvent(eventId, context);
    if (event == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to locate event for reminder.')),
      );
      return null;
    }
    return event.dateTime;
  }

  Event? _findEvent(String eventId, BuildContext context) {
    final scheduleCubit = context.read<ScheduleCubit>();
    final matches = scheduleCubit.events.where((e) => e.id == eventId);
    return (matches.isNotEmpty) ? matches.first : null;
  }

  String _formatLeadTime(Reminder reminder, DateTime eventDate) {
    // Calculate the difference between event date and reminder trigger time
    final diff = eventDate.difference(reminder.triggerTime);

    // Ensure the difference is positive (triggerTime should be before eventDate)
    if (diff.isNegative) {
      return 'Reminder set for past time';
    }

    if (diff.inDays >= 1) {
      return 'Remind me ${diff.inDays} day${diff.inDays > 1 ? 's' : ''} before';
    }
    if (diff.inHours >= 1) {
      return 'Remind me ${diff.inHours} hour${diff.inHours > 1 ? 's' : ''} before';
    }
    if (diff.inMinutes >= 1) {
      return 'Remind me ${diff.inMinutes} minute${diff.inMinutes > 1 ? 's' : ''} before';
    }
    return 'Remind me ${diff.inSeconds} second${diff.inSeconds != 1 ? 's' : ''} before';
  }

  String _fmt(BuildContext context, DateTime dt) {
    return MaterialLocalizations.of(context).formatFullDate(dt) +
        ', ' +
        TimeOfDay.fromDateTime(dt).format(context);
  }
}
