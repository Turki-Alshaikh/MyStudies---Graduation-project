import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../schedule/presentation/cubits/schedule_cubit.dart';
import '../../../schedule/presentation/cubits/schedule_state.dart';
import '../../data/models/resource.dart';

import '../../../../core/constants/app_spacing.dart';
class AddResourceDialog extends StatefulWidget {
  const AddResourceDialog({super.key});

  @override
  State<AddResourceDialog> createState() => _AddResourceDialogState();
}

class _AddResourceDialogState extends State<AddResourceDialog> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _urlController = TextEditingController();
  String? _selectedCourseId;
  ResourceType _selectedType = ResourceType.website;

  @override
  Widget build(BuildContext context) {
    final scheduleCubit = context.read<ScheduleCubit>();
    final state = context.watch<ScheduleCubit>().state;
    final allCourses = state is ScheduleSuccess
        ? state.courses
        : scheduleCubit.courses;

    // Filter out practical parts (courses with 0 or null credits)
    // These should only appear in calendar, not in resources or GPA
    final courses = allCourses
        .where((course) => course.creditHours > 0)
        .toList();
    final selectedCourseId =
        _selectedCourseId ?? (courses.isNotEmpty ? courses.first.id : null);

    return AlertDialog(
      title: const Text('Add Resource'),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(bottom: 8, left: 4),
                  child: Text(
                    'Course',
                    style: TextStyle(
                      fontSize: 12,
                      color: Theme.of(context).textTheme.bodySmall?.color,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                PopupMenuButton<String>(
                  initialValue: selectedCourseId,
                  onSelected: (value) {
                    setState(() {
                      _selectedCourseId = value;
                    });
                  },
                  itemBuilder: (context) => courses
                      .map(
                        (course) => PopupMenuItem<String>(
                          value: course.id,
                          child: Row(
                            children: [
                              if (course.id == selectedCourseId)
                                Icon(
                                  Icons.check,
                                  size: 18,
                                  color: Theme.of(context).colorScheme.primary,
                                )
                              else
                                const SizedBox(width: 18),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text('${course.code} • ${course.name}'),
                              ),
                            ],
                          ),
                        ),
                      )
                      .toList(),
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
                            courses
                                .firstWhere((c) => c.id == selectedCourseId)
                                .code,
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 16,
                              color: Theme.of(context)
                                  .textTheme
                                  .bodyLarge
                                  ?.color,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
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
            TextFormField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: 'Resource Title',
                hintText: 'e.g., Telegram Group',
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a title';
                }
                return null;
              },
            ),
            AppSpacing.verticalSpaceLG,
            TextFormField(
              controller: _urlController,
              decoration: const InputDecoration(
                labelText: 'URL',
                hintText: 'https://example.com',
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a URL';
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
                    'Resource Type',
                    style: TextStyle(
                      fontSize: 12,
                      color: Theme.of(context).textTheme.bodySmall?.color,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                PopupMenuButton<ResourceType>(
                  initialValue: _selectedType,
                  onSelected: (value) {
                    setState(() {
                      _selectedType = value;
                    });
                  },
                  itemBuilder: (context) => ResourceType.values.map((type) {
                    return PopupMenuItem<ResourceType>(
                      value: type,
                      child: Row(
                        children: [
                          if (type == _selectedType)
                            Icon(
                              Icons.check,
                              size: 18,
                              color: Theme.of(context).colorScheme.primary,
                            )
                          else
                            const SizedBox(width: 18),
                          const SizedBox(width: 8),
                          Text(_getResourceTypeLabel(type)),
                        ],
                      ),
                    );
                  }).toList(),
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
                            _getResourceTypeLabel(_selectedType),
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
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(onPressed: _saveResource, child: const Text('Add')),
      ],
    );
  }

  void _saveResource() {
    if (!_formKey.currentState!.validate()) return;

    final scheduleCubit = context.read<ScheduleCubit>();
    // Filter out practical parts when saving resource
    final courses = scheduleCubit.courses
        .where((c) => c.creditHours > 0)
        .toList();
    final courseId =
        _selectedCourseId ?? (courses.isNotEmpty ? courses.first.id : null);

    if (courseId == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Please select a course.')));
      return;
    }

    final resource = Resource(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      courseId: courseId,
      url: _urlController.text.trim(),
      type: _selectedType.name,
      description: _titleController.text.trim(),
    );

    scheduleCubit.addResource(courseId, resource);
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Resource added successfully!')),
    );
  }

  String _getResourceTypeLabel(ResourceType type) {
    switch (type) {
      case ResourceType.telegram:
        return 'Telegram Group';
      case ResourceType.website:
        return 'Website';
      case ResourceType.submission:
        return 'Assignment Platform';
      case ResourceType.video:
        return 'Video Content';
      case ResourceType.document:
        return 'Document';
      case ResourceType.code:
        return 'Code Repository';
      case ResourceType.communication:
        return 'Communication';
      case ResourceType.whatsapp:
        return 'WhatsApp Group';
      case ResourceType.sharedDrive:
        return 'Shared Drive';
    }
  }
}
