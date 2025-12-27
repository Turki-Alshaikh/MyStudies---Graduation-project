import 'package:flutter/material.dart';
import '../../../../core/widgets/app_cards.dart';
import '../../../schedule/presentation/widgets/home_deadline_card.dart';
import '../../data/models/event.dart';

import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_sizes.dart';

class UpcomingEventsModal {
  static void show(BuildContext context, List<Event> events) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final oneWeekFromNow = today.add(const Duration(days: 7));

    List<Event> upcoming = List<Event>.from(events)
      ..retainWhere((e) => e.dateTime.isAfter(now))
      ..sort((a, b) => a.dateTime.compareTo(b.dateTime));

    Map<String, List<Event>> grouped = {
      'Today': [],
      'Tomorrow': [],
      'This Week': [],
      'Later': [],
    };

    for (final event in upcoming) {
      final eventDay = DateTime(
        event.dateTime.year,
        event.dateTime.month,
        event.dateTime.day,
      );
      final diff = eventDay.difference(today).inDays;
      if (diff == 0) {
        grouped['Today']!.add(event);
      } else if (diff == 1) {
        grouped['Tomorrow']!.add(event);
      } else if (diff > 1 && eventDay.isBefore(oneWeekFromNow)) {
        grouped['This Week']!.add(event);
      } else {
        grouped['Later']!.add(event);
      }
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.85,
        minChildSize: 0.3,
        maxChildSize: 0.98,
        expand: false,
        builder: (context, scrollController) => Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.xl,
            30,
            AppSpacing.xl,
            AppSpacing.xl,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppSectionHeader(
                title: 'Upcoming Events',
                icon: Icons.event_rounded,
                iconColor: Theme.of(context).colorScheme.primary,
                iconContainerSize: AppSpacing.iconXL,
                iconSize: AppSpacing.iconMD,
              ),
              AppSpacing.verticalSpaceMD,
              if (upcoming.isEmpty)
                const Expanded(
                  child: AppEmptyState(
                    icon: Icons.calendar_month_outlined,
                    title: 'No upcoming events!',
                    message: "You're all caught up.",
                  ),
                )
              else
                Expanded(
                  child: ListView(
                    padding: EdgeInsets.zero,
                    controller: scrollController,
                    children: [
                      for (final group in [
                        'Today',
                        'Tomorrow',
                        'This Week',
                        'Later',
                      ])
                        if (grouped[group]!.isNotEmpty) ...[
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            child: Text(
                              group,
                              style: TextStyle(
                                fontWeight: FontWeight.w800,
                                fontSize: AppSizes.fontMD + 1,
                                letterSpacing: -0.5,
                                color: Theme.of(context).colorScheme.primary,
                              ),
                            ),
                          ),
                          ...grouped[group]!
                              .map((event) => HomeDeadlineCard(deadline: event))
                              .toList(),
                        ],
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
