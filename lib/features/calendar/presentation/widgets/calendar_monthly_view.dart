import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';
import '../../../../core/theme/app_theme.dart';
import '../../data/models/event.dart';

import '../../../../core/constants/app_spacing.dart';
class CalendarMonthlyView extends StatelessWidget {
  final DateTime focusedDay;
  final DateTime? selectedDay;
  final CalendarFormat calendarFormat;
  final void Function(DateTime selectedDay, DateTime focusedDay) onDaySelected;
  final void Function(CalendarFormat format) onFormatChanged;
  final void Function(DateTime focusedDay) onPageChanged;
  final List<Event> events;

  const CalendarMonthlyView({
    super.key,
    required this.focusedDay,
    required this.selectedDay,
    required this.calendarFormat,
    required this.onDaySelected,
    required this.onFormatChanged,
    required this.onPageChanged,
    required this.events,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: AppSpacing.paddingLG,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                DateFormat('MMMM yyyy').format(focusedDay),
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              Row(
                children: [
                  IconButton(
                    onPressed: () {
                      final newFocused = DateTime(
                        focusedDay.year,
                        focusedDay.month - 1,
                      );
                      onPageChanged(newFocused);
                    },
                    icon: const Icon(Icons.chevron_left),
                  ),
                  IconButton(
                    onPressed: () {
                      final newFocused = DateTime(
                        focusedDay.year,
                        focusedDay.month + 1,
                      );
                      onPageChanged(newFocused);
                    },
                    icon: const Icon(Icons.chevron_right),
                  ),
                ],
              ),
            ],
          ),
        ),
        TableCalendar<Event>(
          firstDay: DateTime.utc(2020, 1, 1),
          lastDay: DateTime.utc(2030, 12, 31),
          focusedDay: focusedDay,
          calendarFormat: calendarFormat,
          eventLoader: (day) {
            final key = DateTime(day.year, day.month, day.day);
            return events
                .where(
                  (e) =>
                      DateTime(
                        e.dateTime.year,
                        e.dateTime.month,
                        e.dateTime.day,
                      ) ==
                      key,
                )
                .toList();
          },
          headerVisible: false,
          startingDayOfWeek: StartingDayOfWeek.sunday,
          calendarStyle: CalendarStyle(
            outsideDaysVisible: false,
            weekendTextStyle:
                Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).textTheme.bodyMedium?.color,
                ) ??
                const TextStyle(),
            defaultTextStyle:
                Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).textTheme.bodyMedium?.color,
                ) ??
                const TextStyle(),
            selectedDecoration: BoxDecoration(
              color: AppTheme.primaryTeal,
              shape: BoxShape.circle,
            ),
            todayDecoration: BoxDecoration(
              color: AppTheme.primaryTeal.withOpacity(0.3),
              shape: BoxShape.circle,
            ),
            // We will draw custom markers via calendarBuilders
            markersMaxCount: 5,
          ),
          calendarBuilders: CalendarBuilders<Event>(
            markerBuilder: (context, date, events) {
              if (events.isEmpty) return null;
              // Draw up to 5 small dots using each event's color
              final dots = events.take(5).map((e) {
                return Container(
                  width: 6,
                  height: 6,
                  margin: const EdgeInsets.symmetric(
                    horizontal: 0.5,
                    vertical: 1,
                  ),
                  decoration: BoxDecoration(
                    color: e.color,
                    shape: BoxShape.circle,
                  ),
                );
              }).toList();
              return Align(
                alignment: Alignment.bottomCenter,
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: dots,
                  ),
                ),
              );
            },
          ),
          headerStyle: HeaderStyle(
            formatButtonVisible: false,
            titleCentered: false,
            titleTextStyle:
                Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ) ??
                const TextStyle(),
            leftChevronVisible: false,
            rightChevronVisible: false,
          ),
          onDaySelected: onDaySelected,
          selectedDayPredicate: (day) =>
              selectedDay != null &&
              day.year == selectedDay!.year &&
              day.month == selectedDay!.month &&
              day.day == selectedDay!.day,
          onFormatChanged: onFormatChanged,
          onPageChanged: onPageChanged,
        ),
      ],
    );
  }
}
