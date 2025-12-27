import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/widgets/app_snackbar.dart';
import '../../../../core/widgets/ios_time_picker_dialog.dart';
import '../cubits/schedule_cubit.dart';
import '../../../calendar/data/models/event.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_sizes.dart';

Future<void> showAddEventBottomSheet(BuildContext context) async {
  final titleController = TextEditingController();
  final courseController = TextEditingController();
  final descriptionController = TextEditingController();
  DateTime selectedDate = DateTime.now();
  TimeOfDay selectedTime = TimeOfDay.now();
  String selectedType = 'assignment';

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
                    'Add Event',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  AppSpacing.verticalSpaceMD,
                  TextField(
                    controller: titleController,
                    decoration: const InputDecoration(
                      labelText: 'Event Title',
                      hintText: 'e.g., Midterm Exam, Assignment 3',
                    ),
                  ),
                  AppSpacing.verticalSpaceMD,
                  TextField(
                    controller: courseController,
                    decoration: const InputDecoration(
                      labelText: 'Course Code',
                      hintText: 'e.g., CS 473, MATH 301',
                    ),
                  ),
                  AppSpacing.verticalSpaceMD,
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(bottom: 8, left: 4),
                        child: Text(
                          'Event Type',
                          style: TextStyle(
                            fontSize: 12,
                            color: Theme.of(context).textTheme.bodySmall?.color,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      PopupMenuButton<String>(
                        initialValue: selectedType,
                        onSelected: (value) {
                          setModalState(() {
                            selectedType = value;
                          });
                        },
                        itemBuilder: (context) => const [
                          PopupMenuItem(
                            value: 'exam',
                            child: Text('Exam'),
                          ),
                          PopupMenuItem(
                            value: 'assignment',
                            child: Text('Assignment'),
                          ),
                          PopupMenuItem(
                            value: 'course',
                            child: Text('Other'),
                          ),
                        ],
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 14,
                          ),
                          decoration: BoxDecoration(
                            color: Theme.of(context).cardColor,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: Theme.of(context).dividerColor.withOpacity(0.2),
                              width: 1,
                            ),
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: Text(
                                  selectedType == 'exam'
                                      ? 'Exam'
                                      : selectedType == 'assignment'
                                          ? 'Assignment'
                                          : 'Other',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 16,
                                    color: Theme.of(context)
                                        .textTheme
                                        .bodyLarge
                                        ?.color,
                                  ),
                                ),
                              ),
                              Icon(
                                Icons.arrow_drop_down_rounded,
                                color: Theme.of(context).textTheme.bodyMedium?.color,
                              ),
                            ],
                          ),
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        color: Theme.of(context).cardColor,
                        elevation: 4,
                      ),
                    ],
                  ),
                  AppSpacing.verticalSpaceMD,
                  Row(
                    children: [
                      Expanded(
                        child: InkWell(
                          onTap: () async {
                            final DateTime? picked = await showDatePicker(
                              context: context,
                              initialDate: selectedDate,
                              firstDate: DateTime.now(),
                              lastDate: DateTime.now().add(const Duration(days: 365)),
                            );
                            if (picked != null) {
                              setModalState(() {
                                selectedDate = picked;
                              });
                            }
                          },
                          child: InputDecorator(
                            decoration: const InputDecoration(labelText: 'Date'),
                            child: Text(
                              '${selectedDate.day}/${selectedDate.month}/${selectedDate.year}',
                              style: TextStyle(
                                fontSize: AppSizes.fontLG,
                                color: Theme.of(context).textTheme.bodyLarge?.color,
                              ),
                            ),
                          ),
                        ),
                      ),
                      AppSpacing.horizontalSpaceLG,
                      Expanded(
                        child: InkWell(
                          onTap: () async {
                            final TimeOfDay? picked = await showIOSTimePicker(
                              context: context,
                              initialTime: selectedTime,
                            );
                            if (picked != null) {
                              setModalState(() {
                                selectedTime = picked;
                              });
                            }
                          },
                          child: InputDecorator(
                            decoration: const InputDecoration(labelText: 'Time'),
                            child: Text(
                              selectedTime.format(context),
                              style: TextStyle(
                                fontSize: AppSizes.fontLG,
                                color: Theme.of(context).textTheme.bodyLarge?.color,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  AppSpacing.verticalSpaceMD,
                  TextField(
                    controller: descriptionController,
                    decoration: const InputDecoration(
                      labelText: 'Description (Optional)',
                      hintText: 'Additional details about the event',
                    ),
                    maxLines: 3,
                  ),
                  AppSpacing.verticalSpaceLG,
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        final title = titleController.text.trim();
                        final course = courseController.text.trim();
                        final desc = descriptionController.text.trim();

                        if (title.isEmpty || course.isEmpty) {
                          AppSnackBars.showError(
                            context,
                            'Please fill in title and course code.',
                          );
                          return;
                        }

                        final eventType = selectedType == 'exam'
                            ? EventType.exam
                            : selectedType == 'assignment'
                                ? EventType.assignment
                                : EventType.course;

                        final dt = DateTime(
                          selectedDate.year,
                          selectedDate.month,
                          selectedDate.day,
                          selectedTime.hour,
                          selectedTime.minute,
                        );

                        final event = Event(
                          id: Uuid().v4(),
                          courseId: course,
                          title: title,
                          dateTime: dt,
                          type: eventType,
                          course: course,
                          description: desc.isEmpty ? null : desc,
                        );

                        context.read<ScheduleCubit>().addEvent(event);
                        AppSnackBars.showSuccess(
                          context,
                          'Event added to your schedule.',
                        );

                        Navigator.pop(context);
                      },
                      child: const Text('Create Event'),
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

