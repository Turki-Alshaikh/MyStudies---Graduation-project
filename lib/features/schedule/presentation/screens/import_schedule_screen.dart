import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/app_snackbar.dart';
import '../cubits/schedule_cubit.dart';
import '../widgets/add_course_bottom_sheet.dart';
import '../widgets/course_preview_tile.dart';

import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_sizes.dart';

class ImportScheduleScreen extends StatelessWidget {
  const ImportScheduleScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Import Schedule'),
        backgroundColor: Colors.transparent,
        elevation: AppSpacing.elevationNone,
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 480),
          child: Padding(
            padding: AppSpacing.paddingLG,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    color: Colors.blue.withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.file_download_outlined,
                    size: 80,
                    color: AppTheme.primaryTeal,
                  ),
                ),
                AppSpacing.verticalSpaceXXL,
                Text(
                  'Import Your Schedule',
                  style: TextStyle(
                    fontSize: AppSizes.fontXXXL,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).textTheme.titleLarge?.color,
                  ),
                ),
                AppSpacing.verticalSpaceLG,
                Text(
                  "Choose your original College Schedule as a PDF.",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: AppSizes.fontLG,
                    color: Theme.of(context).textTheme.bodyMedium?.color,
                  ),
                ),
                AppSpacing.verticalSpaceXXXL,
                ElevatedButton.icon(
                  onPressed: () => _importSchedule(context),
                  icon: const Icon(Icons.download, color: Colors.white),
                  label: const Text(
                    'Select PDF File',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
                AppSpacing.verticalSpaceLG,
                TextButton(
                  onPressed: () => showAddCourseBottomSheet(context),
                  child: const Text('Enter a Course Manually'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _importSchedule(BuildContext context) async {
    try {
      // Pick PDF file
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf'],
      );

      if (result != null) {
        // Show "not implemented" message instead of processing PDF
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('PDF parser not yet implemented.')),
        );
        return;

        // Original PDF processing (commented out):
        // final file = File(result.files.single.path!);
        // AppSnackBars.showSuccess(context, 'Processing PDF...');
        // await _processPdfFile(context, file);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error importing PDF: $e'),
          backgroundColor: Colors.red,
        ),
      );
  }
}

  Future<void> _processPdfFile(BuildContext context, File pdfFile) async {
    try {
      // Show improved loading dialog
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const CircularProgressIndicator(),
              AppSpacing.verticalSpaceXXL,
              Text(
                'Importing Schedule',
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
              ),
              AppSpacing.verticalSpaceMD,
              Text(
                'File: ${pdfFile.path.split('/').last}',
                style: Theme.of(context).textTheme.bodySmall,
                textAlign: TextAlign.center,
              ),
              AppSpacing.verticalSpaceSM,
              Text(
                'Parsing PDF and extracting course data...',
                style: Theme.of(context).textTheme.bodyMedium,
                textAlign: TextAlign.center,
              ),
              AppSpacing.verticalSpaceSM,
              Text(
                'Please wait',
                style: Theme.of(
                  context,
                ).textTheme.bodySmall?.copyWith(fontStyle: FontStyle.italic),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );

      // Process the PDF file into a preview (do not apply yet)
      final scheduleCubit = context.read<ScheduleCubit>();
      final result = await scheduleCubit.previewFromPdf(pdfFile);

      // Close processing dialog
      Navigator.pop(context);

      await result.fold(
        (failure) async {
          AppSnackBars.showError(
            context,
            'Error processing PDF: ${failure.message}',
          );
        },
        (data) async {
          final summary = scheduleCubit.summarizeImport(data);

          final confirmed = await showDialog<bool>(
            context: context,
            barrierDismissible: false,
            builder: (ctx) {
              return AlertDialog(
                title: const Text('Confirm Schedule'),
                content: ConstrainedBox(
                  constraints: const BoxConstraints(
                    maxWidth: 420,
                    maxHeight: 420,
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Detected ${summary.uniqueCourseCount} '
                        '${summary.uniqueCourseCount == 1 ? 'course' : 'courses'} '
                        'with ${summary.totalMeetings} class '
                        '${summary.totalMeetings == 1 ? 'meeting' : 'meetings'}.',
                      ),
                      AppSpacing.verticalSpaceMD,
                      Flexible(
                        child: SingleChildScrollView(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: summary.courses
                                .map(
                                  (course) =>
                                      CoursePreviewTile(course: course),
                                )
                                .toList(),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(ctx, false),
                    child: const Text('Cancel'),
                  ),
                  ElevatedButton(
                    onPressed: () => Navigator.pop(ctx, true),
                    child: const Text('Confirm'),
                  ),
                ],
              );
            },
          );

          if (confirmed == true) {
            scheduleCubit.setSchedule(data);
            AppSnackBars.showSuccess(
              context,
              'Imported ${summary.uniqueCourseCount} '
              '${summary.uniqueCourseCount == 1 ? 'course' : 'courses'} '
              'with ${summary.totalMeetings} class meetings.',
            );
            Navigator.pop(context);
          }
        },
      );
    } catch (e) {
      // Close any open dialogs
      Navigator.pop(context);

      AppSnackBars.showError(context, 'Error processing PDF: $e');
    }
  }
}
