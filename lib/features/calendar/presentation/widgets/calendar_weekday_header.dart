import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';

import '../../../../core/constants/app_spacing.dart';
class CalendarWeekdayHeader extends StatelessWidget {
  final DateTime focusedDay;
  final DateTime? selectedDay;
  final ValueChanged<DateTime>? onSelectDay;

  const CalendarWeekdayHeader({
    super.key,
    required this.focusedDay,
    this.selectedDay,
    this.onSelectDay,
  });

  @override
  Widget build(BuildContext context) {
    final days = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu'];
    final now = DateTime.now();
    // Start week on Sunday for Sun–Thu view
    final startOfWeek = focusedDay.subtract(
      Duration(days: focusedDay.weekday % 7),
    );
    final weekDates = List.generate(
      5,
      (index) => startOfWeek.add(Duration(days: index)),
    );

    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 360;
    final timeColumnWidth = isSmallScreen ? 30.0 : 40.0;
    final dayHeaderFontSize = isSmallScreen ? 12.0 : 14.0;
    final dateFontSize = isSmallScreen ? 10.0 : 12.0;
    final dateContainerSize = isSmallScreen ? 20.0 : 24.0;

    return Row(
      children: [
        SizedBox(width: timeColumnWidth),
        ...days.asMap().entries.map((entry) {
          final dayIndex = entry.key;
          final day = entry.value;
          final date = weekDates[dayIndex];
          final isToday =
              date.year == now.year &&
              date.month == now.month &&
              date.day == now.day;

          final displayDay = isSmallScreen ? day.substring(0, 1) : day;

          final isSelected =
              selectedDay != null &&
              selectedDay!.year == date.year &&
              selectedDay!.month == date.month &&
              selectedDay!.day == date.day;

          return Expanded(
            child: GestureDetector(
              onTap: onSelectDay == null ? null : () => onSelectDay!(date),
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 4.0),
                padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
                decoration: BoxDecoration(
                  color: isToday || isSelected
                      ? AppTheme.primaryTeal.withOpacity(0.15)
                      : Colors.transparent,
                  borderRadius: AppSpacing.borderRadiusSM,
                ),
                child: Column(
                  children: [
                    Text(
                      displayDay,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: dayHeaderFontSize,
                        color: Theme.of(context).brightness == Brightness.dark
                            ? Colors.white
                            : AppTheme.textPrimary,
                      ),
                    ),
                    AppSpacing.verticalSpaceXS,
                    Container(
                      width: dateContainerSize,
                      height: dateContainerSize,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: isToday
                            ? AppTheme.primaryTeal
                            : Colors.transparent,
                      ),
                      child: Center(
                        child: Text(
                          '${date.day}',
                          style: TextStyle(
                            fontSize: dateFontSize,
                            fontWeight: isToday
                                ? FontWeight.bold
                                : FontWeight.normal,
                            color: isToday
                                ? Colors.white
                                : (Theme.of(context).brightness ==
                                          Brightness.dark
                                      ? Colors.white70
                                      : AppTheme.textSecondary),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }),
      ],
    );
  }
}
