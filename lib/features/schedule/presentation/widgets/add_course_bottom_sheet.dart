import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uuid/uuid.dart';

import '../../../../core/constants/app_spacing.dart';
import '../../../../core/widgets/app_snackbar.dart';
import '../../../../core/widgets/ios_time_picker_dialog.dart';
import '../../data/models/course.dart';
import '../../data/models/course_meeting.dart';
import '../cubits/schedule_cubit.dart';

Future<void> showAddCourseBottomSheet(BuildContext context) async {
  final nameController = TextEditingController();
  final codeController = TextEditingController();
  final roomController = TextEditingController();
  final buildingController = TextEditingController();
  final selectedDays = <int>{};
  final creditController = TextEditingController(text: '3');
  // Map to store times for each day: weekday -> {'start': TimeOfDay, 'end': TimeOfDay}
  final dayTimes = <int, Map<String, TimeOfDay>>{};

  await showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Theme.of(context).cardColor,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (context) {
      return StatefulBuilder(
        builder: (context, setModalState) {
          return Padding(
            padding: EdgeInsets.only(
              left: 16,
              right: 16,
              bottom: MediaQuery.of(context).viewInsets.bottom + 16,
              top: 16,
            ),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                Text(
                  'Add Course',
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                ),
                AppSpacing.verticalSpaceMD,
                _SheetTextField(
                  controller: nameController,
                  label: 'Course Name',
                  hint: 'e.g., Data Structures',
                ),
                AppSpacing.verticalSpaceMD,
                _SheetTextField(
                  controller: codeController,
                  label: 'Course Code',
                  hint: 'e.g., CS 201',
                ),
                AppSpacing.verticalSpaceMD,
                Row(
                  children: [
                    Expanded(
                      child: _SheetTextField(
                        controller: roomController,
                        label: 'Room',
                        hint: 'e.g., 205',
                      ),
                    ),
                    AppSpacing.horizontalSpaceMD,
                    Expanded(
                      child: _SheetTextField(
                        controller: buildingController,
                        label: 'Building',
                        hint: 'e.g., Main Hall',
                      ),
                    ),
                  ],
                ),
                AppSpacing.verticalSpaceMD,
                _SheetTextField(
                  controller: creditController,
                  label: 'Credit Hours',
                  hint: 'e.g., 3',
                  keyboardType: TextInputType.number,
                ),
                AppSpacing.verticalSpaceMD,
                Text('Days', style: Theme.of(context).textTheme.titleMedium),
                AppSpacing.verticalSpaceSM,
                Wrap(
                  spacing: 8,
                  children: List.generate(5, (i) {
                    const labels = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu'];
                    final selected = selectedDays.contains(i);
                    return FilterChip(
                      label: Text(labels[i]),
                      selected: selected,
                      onSelected: (v) {
                        setModalState(() {
                          if (v) {
                            selectedDays.add(i);
                            // Initialize default times for new day (8:00 AM - 9:00 AM)
                            if (!dayTimes.containsKey(i)) {
                              dayTimes[i] = {
                                'start': const TimeOfDay(hour: 8, minute: 0),
                                'end': const TimeOfDay(hour: 9, minute: 0),
                              };
                            }
                          } else {
                            selectedDays.remove(i);
                            dayTimes.remove(i);
                          }
                        });
                      },
                    );
                  }),
                ),
                if (selectedDays.isNotEmpty) ...[
                  AppSpacing.verticalSpaceMD,
                  Text(
                    'Time Slots',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  AppSpacing.verticalSpaceSM,
                  ...selectedDays.map((day) {
                    const labels = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu'];
                    final times = dayTimes[day] ?? {
                      'start': const TimeOfDay(hour: 8, minute: 0),
                      'end': const TimeOfDay(hour: 9, minute: 0),
                    };
                    final dayStartTime = times['start']!;
                    final dayEndTime = times['end']!;
                    
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            labels[day],
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                              color: Theme.of(context).textTheme.bodyMedium?.color,
                            ),
                          ),
                          AppSpacing.verticalSpaceXS,
                          Row(
                            children: [
                              Expanded(
                                child: OutlinedButton(
                                  onPressed: () async {
                                    final t = await showIOSTimePicker(
                                      context: context,
                                      initialTime: dayStartTime,
                                    );
                                    if (t != null) {
                                      setModalState(() {
                                        dayTimes[day] = {
                                          'start': t,
                                          'end': dayEndTime,
                                        };
                                        // Auto-update end time if start is later than end
                                        final startM = t.hour * 60 + t.minute;
                                        final endM = dayEndTime.hour * 60 + dayEndTime.minute;
                                        if (endM <= startM) {
                                          // Add 50 minutes to start time
                                          final newEndTotalMinutes = startM + 50;
                                          final newEndHour = (newEndTotalMinutes ~/ 60) % 24;
                                          final newEndMinute = newEndTotalMinutes % 60;
                                          dayTimes[day] = {
                                            'start': t,
                                            'end': TimeOfDay(
                                              hour: newEndHour,
                                              minute: newEndMinute,
                                            ),
                                          };
                                        }
                                      });
                                    }
                                  },
                                  child: Text(
                                    'Start: ${dayStartTime.format(context)}',
                                  ),
                                ),
                              ),
                              AppSpacing.horizontalSpaceSM,
                              Expanded(
                                child: OutlinedButton(
                                  onPressed: () async {
                                    final t = await showIOSTimePicker(
                                      context: context,
                                      initialTime: dayEndTime,
                                    );
                                    if (t != null) {
                                      setModalState(() {
                                        dayTimes[day] = {
                                          'start': dayStartTime,
                                          'end': t,
                                        };
                                      });
                                    }
                                  },
                                  child: Text(
                                    'End: ${dayEndTime.format(context)}',
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ],
                AppSpacing.verticalSpaceLG,
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      final name = nameController.text.trim();
                      final code = codeController.text.trim();
                      if (name.isEmpty ||
                          code.isEmpty ||
                          selectedDays.isEmpty) {
                        AppSnackBars.showError(
                          context,
                          'Please fill all fields and select at least one day.',
                        );
                        return;
                      }
                      
                      // Validate all day times
                      for (final day in selectedDays) {
                        final times = dayTimes[day];
                        if (times == null) {
                          AppSnackBars.showError(
                            context,
                            'Please set times for all selected days.',
                          );
                          return;
                        }
                        final startM = times['start']!.hour * 60 + times['start']!.minute;
                        final endM = times['end']!.hour * 60 + times['end']!.minute;
                        if (endM <= startM) {
                          AppSnackBars.showError(
                            context,
                            'End time must be after start time for all days.',
                          );
                          return;
                        }
                      }
                      
                      final meetings = selectedDays
                          .map(
                            (d) {
                              final times = dayTimes[d]!;
                              final startM = times['start']!.hour * 60 + times['start']!.minute;
                              final endM = times['end']!.hour * 60 + times['end']!.minute;
                              return CourseMeeting(
                                weekday: d,
                                startMinutes: startM,
                                endMinutes: endM,
                              );
                            },
                          )
                          .toList();
                      final course = Course(
                        id: Uuid().v4(),
                        name: name,
                        code: code,
                        creditHours:
                            int.tryParse(creditController.text.trim()) ?? 3,
                        room: roomController.text.trim().isEmpty
                            ? null
                            : roomController.text.trim(),
                        building: buildingController.text.trim().isEmpty
                            ? null
                            : buildingController.text.trim(),
                        meetings: meetings,
                      );
                      final scheduleCubit = context.read<ScheduleCubit>();
                      final ok = scheduleCubit.tryAddCourse(course);
                      if (!ok) {
                        final err =
                            scheduleCubit.lastError ??
                            'Course time conflicts with an existing course.';
                        AppSnackBars.showError(context, err);
                        return;
                      }
                      Navigator.pop(context);
                      AppSnackBars.showSuccess(
                        context,
                        'Course added successfully.',
                      );
                    },
                    child: const Text('Add Course'),
                  ),
                ),
              ],
              ),
            ),
          );
        },
      );
    },
  );
}

class _SheetTextField extends StatelessWidget {
  const _SheetTextField({
    required this.controller,
    required this.label,
    required this.hint,
    this.keyboardType,
  });

  final TextEditingController controller;
  final String label;
  final String hint;
  final TextInputType? keyboardType;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        filled: true,
        fillColor: _sheetFieldFillColor(context),
      ),
    );
  }
}

Color _sheetFieldFillColor(BuildContext context) {
  final theme = Theme.of(context);
  final bg = theme.scaffoldBackgroundColor;
  final overlay = theme.brightness == Brightness.dark
      ? Colors.white.withOpacity(0.04)
      : Colors.black.withOpacity(0.03);
  return Color.alphaBlend(overlay, bg);
}
