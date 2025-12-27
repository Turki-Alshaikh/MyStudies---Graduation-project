import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/widgets/app_snackbar.dart';
import '../../../schedule/presentation/cubits/schedule_cubit.dart';
import 'calendar_manage_sheets.dart';

import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_sizes.dart';
class CalendarEventList extends StatelessWidget {
  final DateTime? selectedDay;
  final List<dynamic> events;

  const CalendarEventList({
    super.key,
    required this.selectedDay,
    required this.events,
  });

  @override
  Widget build(BuildContext context) {
    final day = selectedDay ?? DateTime.now();
    final dayKey = DateTime(day.year, day.month, day.day);
    final events = this.events
        .where(
          (e) =>
              DateTime(e.dateTime.year, e.dateTime.month, e.dateTime.day) ==
              dayKey,
        )
        .toList();

    if (events.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.event_note,
              size: 64,
              color: Theme.of(
                context,
              ).textTheme.bodyMedium?.color?.withOpacity(0.3),
            ),
            AppSpacing.verticalSpaceLG,
            Text(
              'No events for this day',
              style: TextStyle(
                color: Theme.of(
                  context,
                ).textTheme.bodyMedium?.color?.withOpacity(0.7),
                fontSize: AppSizes.fontLG,
              ),
            ),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: AppSpacing.paddingLG,
          child: Text(
            'UPCOMING EVENTS',
            style: TextStyle(
              fontSize: AppSizes.fontMD,
              fontWeight: FontWeight.bold,
              color: Theme.of(
                context,
              ).textTheme.bodyMedium?.color?.withOpacity(0.7),
              letterSpacing: 1.2,
            ),
          ),
        ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
            itemCount: events.length,
            itemBuilder: (context, index) {
              final event = events[index];
              return Dismissible(
                key: ValueKey('event-${event.id}'),
                direction: DismissDirection.endToStart,
                background: Container(
                  alignment: Alignment.centerRight,
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                  color: Colors.red.withOpacity(0.2),
                  child: const Icon(Icons.delete, color: Colors.red),
                ),
                confirmDismiss: (_) async {
                  final ok =
                      await showDialog<bool>(
                        context: context,
                        builder: (ctx) => AlertDialog(
                          title: const Text('Delete Event?'),
                          content: Text(
                            'Are you sure you want to delete "${event.title}"?',
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(ctx, false),
                              child: const Text('Cancel'),
                            ),
                            ElevatedButton(
                              onPressed: () => Navigator.pop(ctx, true),
                              child: const Text('Delete'),
                            ),
                          ],
                        ),
                      ) ??
                      false;
                  if (ok) {
                    context.read<ScheduleCubit>().deleteEvent(event.id);
                    AppSnackBars.showSuccess(context, 'Event deleted.');
                  }
                  return ok;
                },
                child: Card(
                  margin: const EdgeInsets.only(bottom: AppSpacing.sm),
                  child: ListTile(
                    leading: Container(
                      width: 4,
                      height: 40,
                      decoration: BoxDecoration(
                        color: event.color,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    title: Text(
                      event.title,
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: Theme.of(context).textTheme.bodyLarge?.color,
                      ),
                    ),
                    subtitle: Text(
                      '${event.course} • ${DateFormat('h:mm a').format(event.dateTime)}',
                      style: TextStyle(
                        color: Theme.of(
                          context,
                        ).textTheme.bodyMedium?.color?.withOpacity(0.7),
                      ),
                    ),
                    onLongPress: () => showManageEventSheet(context, event),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
