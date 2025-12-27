import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/models/event.dart';
import '../../../schedule/data/models/course.dart';
import '../../../schedule/presentation/cubits/schedule_cubit.dart';
import '../../../../core/widgets/app_snackbar.dart';
import 'calendar_edit_event_dialog.dart';

import '../../../../core/constants/app_spacing.dart';
Future<void> showManageEventSheet(BuildContext context, Event event) async {
  showModalBottomSheet(
    context: context,
    backgroundColor: Theme.of(context).cardColor,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
    ),
    builder: (ctx) => SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: const Icon(Icons.edit),
            title: const Text('Edit Event'),
            onTap: () async {
              Navigator.pop(ctx);
              await showEditEventDialog(context, event);
            },
          ),
          ListTile(
            leading: const Icon(Icons.delete, color: Colors.red),
            title: const Text('Delete Event'),
            onTap: () async {
              final ok =
                  await showDialog<bool>(
                    context: context,
                    builder: (dctx) => AlertDialog(
                      title: const Text('Delete Event?'),
                      content: Text('Delete "${event.title}"?'),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(dctx, false),
                          child: const Text('Cancel'),
                        ),
                        ElevatedButton(
                          onPressed: () => Navigator.pop(dctx, true),
                          child: const Text('Delete'),
                        ),
                      ],
                    ),
                  ) ??
                  false;
              if (ok) {
                context.read<ScheduleCubit>().deleteEvent(event.id);
                AppSnackBars.showSuccess(context, 'Event deleted.');
                Navigator.pop(ctx);
              }
            },
          ),
        ],
      ),
    ),
  );
}

Future<void> showManageCourseSheet(BuildContext context, Course course) async {
  final name = TextEditingController(text: course.name);
  final code = TextEditingController(text: course.code);
  final room = TextEditingController(text: course.room ?? '');
  final building = TextEditingController(text: course.building ?? '');
  final credits = TextEditingController(text: course.creditHours.toString());

  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Theme.of(context).cardColor,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
    ),
    builder: (ctx) => Padding(
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        bottom: MediaQuery.of(ctx).viewInsets.bottom + 16,
        top: 16,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // local helper for consistent field fill color
          // blends a subtle overlay into scaffold background
          Row(
            children: [
              const Icon(Icons.edit),
              AppSpacing.horizontalSpaceSM,
              const Text(
                'Edit Course',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              const Spacer(),
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => Navigator.pop(ctx),
              ),
            ],
          ),
          AppSpacing.verticalSpaceMD,
          TextField(
            controller: name,
            decoration: InputDecoration(
              labelText: 'Name',
              filled: true,
              fillColor: _sheetFieldFillColor(ctx),
            ),
          ),
          AppSpacing.verticalSpaceSM,
          TextField(
            controller: code,
            decoration: InputDecoration(
              labelText: 'Code',
              filled: true,
              fillColor: _sheetFieldFillColor(ctx),
            ),
          ),
          AppSpacing.verticalSpaceSM,
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: room,
                  decoration: InputDecoration(
                    labelText: 'Room',
                    filled: true,
                    fillColor: _sheetFieldFillColor(ctx),
                  ),
                ),
              ),
              AppSpacing.horizontalSpaceSM,
              Expanded(
                child: TextField(
                  controller: building,
                  decoration: InputDecoration(
                    labelText: 'Building',
                    filled: true,
                    fillColor: _sheetFieldFillColor(ctx),
                  ),
                ),
              ),
            ],
          ),
          AppSpacing.verticalSpaceSM,
          TextField(
            controller: credits,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              labelText: 'Credit Hours',
              filled: true,
              fillColor: _sheetFieldFillColor(ctx),
            ),
          ),
          AppSpacing.verticalSpaceMD,
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                final scheduleCubit = context.read<ScheduleCubit>();
                final updated = course.copyWith(
                  name: name.text.trim(),
                  code: code.text.trim(),
                  room: room.text.trim().isEmpty ? null : room.text.trim(),
                  building: building.text.trim().isEmpty
                      ? null
                      : building.text.trim(),
                  creditHours:
                      int.tryParse(credits.text.trim()) ?? course.creditHours,
                );
                final ok = scheduleCubit.updateCourse(updated);
                if (ok) {
                  AppSnackBars.showSuccess(context, 'Course updated.');
                  Navigator.pop(ctx);
                } else {
                  AppSnackBars.showError(
                    context,
                    scheduleCubit.lastError ?? 'Could not update course.',
                  );
                }
              },
              child: const Text('Save Changes'),
            ),
          ),
          AppSpacing.verticalSpaceSM,
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: AppSpacing.borderRadiusMD,
                ),
              ),
              onPressed: () async {
                final ok =
                    await showDialog<bool>(
                      context: context,
                      builder: (dctx) => AlertDialog(
                        title: const Text('Delete Course?'),
                        content: Text(
                          'Delete ${course.code}? This will also remove related events.',
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(dctx, false),
                            child: const Text('Cancel'),
                          ),
                          ElevatedButton(
                            onPressed: () => Navigator.pop(dctx, true),
                            child: const Text('Delete'),
                          ),
                        ],
                      ),
                    ) ??
                    false;
                if (!ok) return;
                final scheduleCubit = context.read<ScheduleCubit>();
                scheduleCubit.deleteCourse(course.id);
                AppSnackBars.showSuccess(context, 'Course deleted.');
                Navigator.pop(ctx);
              },
              icon: const Icon(Icons.delete),
              label: const Text('Delete Course'),
            ),
          ),
        ],
      ),
    ),
  );
}

Color _sheetFieldFillColor(BuildContext context) {
  final theme = Theme.of(context);
  final bg = theme.scaffoldBackgroundColor;
  final overlay = theme.brightness == Brightness.dark
      ? Colors.white.withOpacity(0.04)
      : Colors.black.withOpacity(0.03);
  return Color.alphaBlend(overlay, bg);
}
