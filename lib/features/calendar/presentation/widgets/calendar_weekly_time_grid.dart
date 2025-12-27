import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../../../schedule/data/models/course.dart';
import '../../data/models/event.dart';
import '../cubits/calendar_cubit.dart';
import 'calendar_manage_sheets.dart';
import 'calendar_weekday_header.dart';
import 'event_detail_modal.dart';
import 'course_meeting_sheet.dart';

import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_sizes.dart';
class CalendarWeeklyTimeGrid extends StatelessWidget {
  final DateTime focusedDay;
  final List<Course> courses;
  final List<Event> events;
  final bool dayView;
  final DateTime selectedDay;
  final ValueChanged<DateTime>? onSelectDay;

  const CalendarWeeklyTimeGrid({
    super.key,
    required this.focusedDay,
    required this.courses,
    required this.events,
    required this.dayView,
    required this.selectedDay,
    this.onSelectDay,
  });

  @override
  Widget build(BuildContext context) {
    final hours = List.generate(13, (index) => index + 7);
    final now = DateTime.now();
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 360;
    final timeColumnWidth = isSmallScreen ? 30.0 : 40.0;

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isSmallScreen ? 8 : 12,
        vertical: 8,
      ),
      child: Column(
        children: [
          CalendarWeekdayHeader(
            focusedDay: focusedDay,
            selectedDay: selectedDay,
            onSelectDay: onSelectDay,
          ),
          AppSpacing.verticalSpaceSM,
          Expanded(
            child: SingleChildScrollView(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    width: timeColumnWidth,
                    child: Column(
                      children: [
                        AppSpacing.verticalSpaceXXL,
                        ...hours.map((hour) {
                          final timeLabel = DateFormat('h a').format(
                            DateTime(now.year, now.month, now.day, hour),
                          );
                          return SizedBox(
                            height: 60,
                            child: Align(
                              alignment: Alignment.topCenter,
                              child: Text(
                                timeLabel,
                                style: TextStyle(
                                  color: Theme.of(context)
                                      .textTheme
                                      .bodyMedium
                                      ?.color
                                      ?.withOpacity(0.7),
                                  fontSize: AppSizes.fontSM,
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Row(
                      children: () {
                        final startOfWeek = focusedDay.subtract(
                          Duration(days: focusedDay.weekday % 7),
                        );
                        final selectedIndex = selectedDay
                            .difference(
                              DateTime(
                                startOfWeek.year,
                                startOfWeek.month,
                                startOfWeek.day,
                              ),
                            )
                            .inDays;
                        final indices =
                            dayView && selectedIndex >= 0 && selectedIndex < 5
                            ? [selectedIndex]
                            : List.generate(5, (i) => i);
                        return indices
                            .map(
                              (i) => Expanded(
                                child: buildDayColumn(context, i, hours),
                              ),
                            )
                            .toList();
                      }(),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildEventTile(BuildContext context, Event event) {
    return Padding(
      padding: AppSpacing.paddingXS,
      child: GestureDetector(
        onTap: () => showEventDetailModal(context, event),
        child: Container(
          decoration: BoxDecoration(
            color: event.color.withOpacity(0.15),
            borderRadius: AppSpacing.borderRadiusSM,
            border: Border.all(color: event.color, width: 1),
          ),
          child: Row(
            children: [
              Container(
                width: 4,
                decoration: BoxDecoration(
                  color: event.color,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(8),
                    bottomLeft: Radius.circular(8),
                  ),
                ),
              ),
              AppSpacing.horizontalSpaceSM,
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      event.title,
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: Theme.of(context).textTheme.bodyLarge?.color,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      '${event.course} • ${DateFormat('h:mm a').format(event.dateTime)}',
                      style: TextStyle(
                        fontSize: AppSizes.fontSM,
                        color: Theme.of(
                          context,
                        ).textTheme.bodyMedium?.color?.withOpacity(0.7),
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              Container(
                margin: const EdgeInsets.only(right: 8),
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: 4),
                decoration: BoxDecoration(
                  color: event.color.withOpacity(0.1),
                  borderRadius: AppSpacing.borderRadiusMD,
                ),
                child: Text(
                  event.type.name.toUpperCase(),
                  style: TextStyle(
                    fontSize: AppSizes.fontXS,
                    fontWeight: FontWeight.w600,
                    color: event.color,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildDayColumn(BuildContext context, int dayIndex, List<int> hours) {
    const slotHeight = 60.0;
    final calendarCubit = context.read<CalendarCubit>();
    final startOfWeek = focusedDay.subtract(
      Duration(days: focusedDay.weekday % 7),
    );
    final dayDate = DateTime(
      startOfWeek.year,
      startOfWeek.month,
      startOfWeek.day,
    ).add(Duration(days: dayIndex));
    // Only display courses within the semester window (Aug 24 -> Dec 18)
    final semYear = focusedDay.year;
    final semesterStart = DateTime(semYear, 8, 24);
    final semesterEnd = DateTime(semYear, 12, 18, 23, 59, 59);
    final inSemester =
        !dayDate.isBefore(semesterStart) && !dayDate.isAfter(semesterEnd);
    final dayCourses = (!inSemester)
        ? <Course>[]
        : courses
              .where((c) => c.meetings.any((m) => m.weekday == dayIndex))
              .toList();

    List<Widget> buildCourseBlocks() {
      final blocks = <Widget>[];
      for (final course in dayCourses) {
        for (final m in course.meetings.where((m) => m.weekday == dayIndex)) {
          final top = ((m.startMinutes - 7 * 60) / 60.0) * slotHeight;
          final height = ((m.endMinutes - m.startMinutes) / 60.0) * slotHeight;
          if (height <= 0) continue;
          // Event dots inside the block
          final dayEvents = _eventsForDay(dayDate, events).where((e) {
            final em = e.dateTime.hour * 60 + e.dateTime.minute;
            return em >= m.startMinutes && em < m.endMinutes;
          }).toList();

          blocks.add(
            Positioned(
              top: top.clamp(0, double.infinity),
              left: 6,
              right: 6,
              height: height,
              child: GestureDetector(
                onTap: () => showCourseMeetingSheet(
                  context,
                  course: course,
                  meeting: m,
                  occurrenceDate: dayDate,
                ),
                onLongPress: () => showManageCourseSheet(context, course),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: calendarCubit
                        .courseColorFor(course.code)
                        .withOpacity(0.25),
                    border: Border.all(
                      color: calendarCubit.courseColorFor(course.code),
                      width: 1,
                    ),
                    borderRadius: AppSpacing.borderRadiusSM,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        course.code.replaceAll(' ', ''), // Remove spaces
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: AppSizes.fontXS + 1,
                          color: Theme.of(context).textTheme.bodyLarge?.color,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const Spacer(),
                      if (dayEvents.isNotEmpty)
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: dayEvents.take(4).map((e) {
                            return Container(
                              width: 8,
                              height: 8,
                              margin: const EdgeInsets.only(left: 4, bottom: 2),
                              decoration: BoxDecoration(
                                color: e.color,
                                shape: BoxShape.circle,
                              ),
                            );
                          }).toList(),
                        ),
                    ],
                  ),
                ),
              ),
            ),
          );
        }
      }
      return blocks;
    }

    return Column(
      children: [
        Container(
          height: 24,
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor.withOpacity(0.4),
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(8),
              topRight: Radius.circular(8),
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor.withOpacity(0.2),
            borderRadius: const BorderRadius.only(
              bottomLeft: Radius.circular(8),
              bottomRight: Radius.circular(8),
            ),
          ),
          child: Stack(
            children: [
              // Background hour grid
              Column(
                children: [
                  ...hours.map((hour) {
                    final event = _getEventForTimeSlot(
                      context,
                      dayIndex,
                      hour,
                      events,
                    );
                    return Container(
                      height: slotHeight,
                      decoration: BoxDecoration(
                        border: Border(
                          top: BorderSide(
                            color: Theme.of(
                              context,
                            ).dividerColor.withOpacity(0.2),
                            width: 0.5,
                          ),
                        ),
                      ),
                      child: event == null
                          ? null
                          : (dayView ? buildEventTile(context, event) : null),
                    );
                  }).toList(),
                ],
              ),
              // Course blocks overlay
              ...buildCourseBlocks(),
            ],
          ),
        ),
      ],
    );
  }

  Event? _getEventForTimeSlot(
    BuildContext context,
    int dayIndex,
    int hour,
    List<Event> allEvents,
  ) {
    final startOfWeek = focusedDay.subtract(
      Duration(days: focusedDay.weekday % 7),
    );
    final dayDate = DateTime(
      startOfWeek.year,
      startOfWeek.month,
      startOfWeek.day,
    ).add(Duration(days: dayIndex));
    final dayEvents = _eventsForDay(dayDate, allEvents);
    for (final event in dayEvents) {
      if (event.dateTime.hour == hour) {
        return event;
      }
    }
    return null;
  }

  List<Event> _eventsForDay(DateTime day, List<Event> allEvents) {
    final key = DateTime(day.year, day.month, day.day);
    return allEvents.where((event) {
      final eventKey = DateTime(
        event.dateTime.year,
        event.dateTime.month,
        event.dateTime.day,
      );
      return eventKey == key;
    }).toList();
  }
}
