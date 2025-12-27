import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:table_calendar/table_calendar.dart';

import '../../../../core/widgets/app_buttons.dart';
import '../../../schedule/presentation/cubits/schedule_cubit.dart';
import '../../../schedule/presentation/cubits/schedule_state.dart';
import '../widgets/calendar_event_list.dart';
import '../widgets/calendar_monthly_view.dart';
import '../widgets/calendar_weekly_view.dart';
import '../widgets/calendar_view_selector.dart';
import '../widgets/upcoming_events_modal.dart';

import '../../../../core/constants/app_spacing.dart';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen>
    with TickerProviderStateMixin {
  late final TabController _tabController;
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this, initialIndex: 0);
    _selectedDay = DateTime.now();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ScheduleCubit, ScheduleState>(
      builder: (context, state) {
        final scheduleCubit = context.read<ScheduleCubit>();
        final events = state is ScheduleSuccess
            ? state.events
            : scheduleCubit.events;
        return Scaffold(
          appBar: AppBar(
            title: const Text('Calendar'),
            backgroundColor: Colors.transparent,
            elevation: AppSpacing.elevationNone,
            actions: [
              AppIconButton(
                onPressed: () => UpcomingEventsModal.show(context, events),
                icon: Icons.calendar_today,
                tooltip: 'Upcoming Events',
              ),
            ],
          ),
          body: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.lg,
                  AppSpacing.sm,
                  AppSpacing.lg,
                  0,
                ),
                child: CalendarViewSelector(
                  selectedIndex: _tabController.index,
                  onValueChanged: (value) {
                    if (value != null) {
                      setState(() => _tabController.index = value);
                    }
                  },
                ),
              ),
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    CalendarWeeklyView(
                      focusedDay: _focusedDay,
                      onPrevWeek: () => setState(
                        () => _focusedDay = _focusedDay.subtract(
                          const Duration(days: 7),
                        ),
                      ),
                      onNextWeek: () => setState(
                        () => _focusedDay = _focusedDay.add(
                          const Duration(days: 7),
                        ),
                      ),
                      onToday: () =>
                          setState(() => _focusedDay = DateTime.now()),
                    ),
                    Column(
                      children: [
                        CalendarMonthlyView(
                          focusedDay: _focusedDay,
                          selectedDay: _selectedDay,
                          calendarFormat: _calendarFormat,
                          onDaySelected: (selected, focused) {
                            if (!isSameDay(_selectedDay, selected)) {
                              setState(() {
                                _selectedDay = selected;
                                _focusedDay = focused;
                              });
                            }
                          },
                          onFormatChanged: (format) {
                            if (_calendarFormat != format) {
                              setState(() => _calendarFormat = format);
                            }
                          },
                          onPageChanged: (focused) {
                            setState(() => _focusedDay = focused);
                          },
                          events: events,
                        ),
                        AppSpacing.verticalSpaceSM,
                        Expanded(
                          child: CalendarEventList(
                            selectedDay: _selectedDay,
                            events: events,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
