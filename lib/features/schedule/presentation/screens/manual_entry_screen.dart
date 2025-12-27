import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/app_snackbar.dart';
import '../../../../core/widgets/ios_time_picker_dialog.dart';
import '../cubits/schedule_cubit.dart';
import '../../../calendar/data/models/event.dart';

import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_sizes.dart';

class ManualEntryScreen extends StatefulWidget {
  const ManualEntryScreen({super.key});

  @override
  State<ManualEntryScreen> createState() => _ManualEntryScreenState();
}

class _ManualEntryScreenState extends State<ManualEntryScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _courseController = TextEditingController();
  final _descriptionController = TextEditingController();

  DateTime _selectedDate = DateTime.now();
  TimeOfDay _selectedTime = TimeOfDay.now();
  String _selectedType = 'assignment';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Manual Entry'),
        backgroundColor: Colors.transparent,
        elevation: AppSpacing.elevationNone,
        actions: [
          TextButton(
            onPressed: _saveEvent,
            child: const Text(
              'Save',
              style: TextStyle(
                color: AppTheme.primaryTeal,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: AppSpacing.paddingLG,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Create New Event',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontSize: AppSizes.fontXXXL,
                  fontWeight: FontWeight.bold,
                ),
              ),
              AppSpacing.verticalSpaceXXL,

              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'Event Title',
                  hintText: 'e.g., Midterm Exam, Assignment 3',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter an event title';
                  }
                  return null;
                },
              ),
              AppSpacing.verticalSpaceLG,

              TextFormField(
                controller: _courseController,
                decoration: const InputDecoration(
                  labelText: 'Course Code',
                  hintText: 'e.g., CS 473, MATH 301',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a course code';
                  }
                  return null;
                },
              ),
              AppSpacing.verticalSpaceLG,

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
                    initialValue: _selectedType,
                    onSelected: (value) {
                      setState(() {
                        _selectedType = value;
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
                              _selectedType == 'exam'
                                  ? 'Exam'
                                  : _selectedType == 'assignment'
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
              AppSpacing.verticalSpaceLG,

              Row(
                children: [
                  Expanded(
                    child: InkWell(
                      onTap: _selectDate,
                      child: InputDecorator(
                        decoration: const InputDecoration(labelText: 'Date'),
                        child: Text(
                          '${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}',
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
                      onTap: _selectTime,
                      child: InputDecorator(
                        decoration: const InputDecoration(labelText: 'Time'),
                        child: Text(
                          _selectedTime.format(context),
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
              AppSpacing.verticalSpaceLG,

              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Description (Optional)',
                  hintText: 'Additional details about the event',
                ),
                maxLines: 3,
              ),
              AppSpacing.verticalSpaceXXXL,

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _saveEvent,
                  child: const Text('Create Event'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _selectTime() async {
    final TimeOfDay? picked = await showIOSTimePicker(
      context: context,
      initialTime: _selectedTime,
    );
    if (picked != null && picked != _selectedTime) {
      setState(() {
        _selectedTime = picked;
      });
    }
  }

  void _saveEvent() {
    if (!_formKey.currentState!.validate()) return;

    final title = _titleController.text.trim();
    final course = _courseController.text.trim();
    final desc = _descriptionController.text.trim();

    final eventType = _selectedType == 'exam'
        ? EventType.exam
        : _selectedType == 'assignment'
        ? EventType.assignment
        : EventType.course;

    final dt = DateTime(
      _selectedDate.year,
      _selectedDate.month,
      _selectedDate.day,
      _selectedTime.hour,
      _selectedTime.minute,
    );

    final event = Event(
      id: Uuid().v4(),
      courseId: course, // using course code/name as identifier for now
      title: title,
      dateTime: dt,
      type: eventType,
      course: course,
      description: desc.isEmpty ? null : desc,
    );

    context.read<ScheduleCubit>().addEvent(event);
    AppSnackBars.showSuccess(context, 'Event added to your schedule.');

    Navigator.pop(context);
  }
}
