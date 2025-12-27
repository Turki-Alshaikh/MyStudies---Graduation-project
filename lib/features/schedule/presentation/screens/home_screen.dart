import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../calendar/data/models/event.dart';
import '../../../settings/presentation/cubit/theme_cubit.dart';
import '../cubits/schedule_cubit.dart';
import '../cubits/schedule_state.dart';
import '../widgets/home_deadlines_section.dart';
import '../widgets/home_next_class_card.dart';
import '../widgets/home_quick_access_section.dart';

import '../../../../core/constants/app_spacing.dart';
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    context.watch<ThemeCubit>().state;
    return BlocBuilder<ScheduleCubit, ScheduleState>(
      builder: (context, scheduleState) {
        final scheduleCubit = context.read<ScheduleCubit>();
        final nextClass = scheduleCubit.getNextClass();
        List<Event> upcomingEvents = scheduleCubit.upcomingEvents(limit: 4);
        if (nextClass != null) {
          upcomingEvents = upcomingEvents
              .where((event) => event.id != nextClass.id)
              .toList();
        }
        if (upcomingEvents.length > 3) {
          upcomingEvents = upcomingEvents.take(3).toList();
        }

        return Scaffold(
          appBar: AppBar(
            title: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.school_rounded,
                  color: AppTheme.primaryTeal,
                  size: AppSpacing.iconLG,
                ),
                AppSpacing.horizontalSpaceSM,
                const Text(
                  'MyStudies',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    letterSpacing: -0.5,
                  ),
                ),
              ],
            ),
            centerTitle: false,
            backgroundColor: Theme.of(context).cardColor,
            elevation: AppSpacing.elevationNone,
            scrolledUnderElevation: 2,
          ),
          body: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Greeting removed per request

                // Next Class Card
                HomeNextClassCard(nextClass: nextClass),
                AppSpacing.verticalSpaceXXL,

                // Quick Access Section
                const HomeQuickAccessSection(),
                AppSpacing.verticalSpaceXXL,

                // Deadlines Section
                HomeDeadlinesSection(deadlines: upcomingEvents),
              ],
            ),
          ),
        );
      },
    );
  }

  // Greeting removed
}
