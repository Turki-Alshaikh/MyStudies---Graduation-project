import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../constants/app_spacing.dart';
import '../theme/app_theme.dart';

/// Modern iOS-style time picker dialog
Future<TimeOfDay?> showIOSTimePicker({
  required BuildContext context,
  required TimeOfDay initialTime,
}) async {
  TimeOfDay selectedTime = initialTime;

  return await showModalBottomSheet<TimeOfDay>(
    context: context,
    backgroundColor: Colors.transparent,
    isDismissible: true,
    enableDrag: true,
    builder: (BuildContext context) {
      return Container(
        height: 280,
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: const BorderRadius.vertical(
            top: Radius.circular(AppSpacing.lg),
          ),
        ),
        child: Column(
          children: [
            // Header with Done button
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.lg,
                vertical: AppSpacing.md,
              ),
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                    color: Theme.of(context).dividerColor.withOpacity(0.2),
                    width: 0.5,
                  ),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Select Time',
                    style: TextStyle(
                      fontSize: AppSpacing.lg,
                      fontWeight: FontWeight.w600,
                      color: Theme.of(context).textTheme.bodyLarge?.color,
                    ),
                  ),
                  CupertinoButton(
                    padding: EdgeInsets.zero,
                    minSize: 0,
                    onPressed: () => Navigator.pop(context, selectedTime),
                    child: Text(
                      'Done',
                      style: TextStyle(
                        color: AppTheme.primaryTeal,
                        fontSize: AppSpacing.lg,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Time picker with modern iOS styling
            Expanded(
              child: CupertinoTheme(
                data: CupertinoTheme.of(context).copyWith(
                  textTheme: CupertinoTextThemeData(
                    dateTimePickerTextStyle: TextStyle(
                      color: Theme.of(context).textTheme.bodyLarge?.color,
                      fontSize: AppSpacing.xxl,
                    ),
                  ),
                ),
                child: CupertinoDatePicker(
                  mode: CupertinoDatePickerMode.time,
                  initialDateTime: DateTime(
                    2024,
                    1,
                    1,
                    initialTime.hour,
                    initialTime.minute,
                  ),
                  use24hFormat: false,
                  minuteInterval: 1,
                  onDateTimeChanged: (DateTime newDateTime) {
                    selectedTime = TimeOfDay(
                      hour: newDateTime.hour,
                      minute: newDateTime.minute,
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      );
    },
  );
}
