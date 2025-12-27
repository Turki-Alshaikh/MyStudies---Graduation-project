import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../schedule/presentation/cubits/schedule_cubit.dart';
import '../../../schedule/presentation/cubits/schedule_state.dart';
import 'calendar_weekly_time_grid.dart';
import '../cubits/calendar_cubit.dart';

import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_sizes.dart';
class CalendarWeeklyView extends StatefulWidget {
  final DateTime focusedDay;
  final VoidCallback onPrevWeek;
  final VoidCallback onNextWeek;
  final VoidCallback onToday;

  const CalendarWeeklyView({
    super.key,
    required this.focusedDay,
    required this.onPrevWeek,
    required this.onNextWeek,
    required this.onToday,
  });

  @override
  State<CalendarWeeklyView> createState() => _CalendarWeeklyViewState();
}

class _CalendarWeeklyViewState extends State<CalendarWeeklyView> {
  bool _dayView = false;
  late DateTime _selectedDay;

  @override
  void initState() {
    super.initState();
    _selectedDay = widget.focusedDay;
  }

  @override
  void didUpdateWidget(covariant CalendarWeeklyView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.focusedDay != oldWidget.focusedDay) {
      _selectedDay = widget.focusedDay;
    }
  }

  @override
  Widget build(BuildContext context) {
    final scheduleCubit = context.read<ScheduleCubit>();
    final state = context.watch<ScheduleCubit>().state;
    final courses = state is ScheduleSuccess
        ? state.courses
        : scheduleCubit.courses;
    final events = state is ScheduleSuccess
        ? state.events
        : scheduleCubit.events;

    final startOfWeek = widget.focusedDay.subtract(
      Duration(days: widget.focusedDay.weekday % 7),
    );
    final endOfWeek = startOfWeek.add(const Duration(days: 4)); // Sun-Thu

    return Column(
      children: [
        Container(
          padding: AppSpacing.paddingLG,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Week of',
                    style: TextStyle(
                      fontSize: AppSizes.fontMD,
                      fontWeight: FontWeight.w500,
                      color: Theme.of(context).brightness == Brightness.dark
                          ? Colors.white70
                          : AppTheme.textSecondary,
                    ),
                  ),
                  Text(
                    '${DateFormat('MMM d').format(startOfWeek)} - ${DateFormat('MMM d').format(endOfWeek)}',
                    style: TextStyle(
                      fontSize: AppSizes.fontXL,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).brightness == Brightness.dark
                          ? Colors.white
                          : AppTheme.textPrimary,
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  IconButton(
                    onPressed: () {
                      setState(() {
                        _selectedDay = _selectedDay.subtract(
                          const Duration(days: 7),
                        );
                      });
                      widget.onPrevWeek();
                    },
                    icon: const Icon(Icons.chevron_left),
                  ),
                  TextButton(
                    onPressed: () {
                      setState(() {
                        _selectedDay = DateTime.now();
                      });
                      widget.onToday();
                    },
                    child: Text(
                      'Today',
                      style: TextStyle(
                        color: AppTheme.primaryTeal,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () {
                      setState(() {
                        _selectedDay = _selectedDay.add(
                          const Duration(days: 7),
                        );
                      });
                      widget.onNextWeek();
                    },
                    icon: const Icon(Icons.chevron_right),
                  ),
                ],
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
          child: CupertinoSlidingSegmentedControl<int>(
            // Use int keys for consistency with other controls
            groupValue: _dayView ? 1 : 0,
            children: const {
              0: Padding(
                padding: EdgeInsets.symmetric(vertical: 6, horizontal: 10),
                child: Text('Week'),
              ),
              1: Padding(
                padding: EdgeInsets.symmetric(vertical: 6, horizontal: 10),
                child: Text('Day'),
              ),
            },
            onValueChanged: (v) {
              if (v != null) setState(() => _dayView = v == 1);
            },
          ),
        ),
        AppSpacing.verticalSpaceSM,
        Expanded(
          child: BlocProvider(
            create: (_) => CalendarCubit(),
            child: CalendarWeeklyTimeGrid(
              focusedDay: widget.focusedDay,
              courses: courses,
              events: events,
              dayView: _dayView,
              selectedDay: _selectedDay,
              onSelectDay: (d) => setState(() {
                _selectedDay = d;
                _dayView = true; // auto-enter Day view on tap
              }),
            ),
          ),
        ),
      ],
    );
  }
}
