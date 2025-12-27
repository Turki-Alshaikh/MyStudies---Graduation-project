import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../calendar/presentation/cubits/deadline_scan_cubit.dart';

import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_sizes.dart';
class ScanDeadlineScreen extends StatelessWidget {
  const ScanDeadlineScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Scan Deadline'),
        backgroundColor: Colors.transparent,
        elevation: AppSpacing.elevationNone,
      ),
      body: Padding(
        padding: AppSpacing.paddingLG,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.camera_alt, size: 80, color: AppTheme.primaryTeal),
            AppSpacing.verticalSpaceXXL,
            Text(
              'OCR Camera Scanner',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontSize: AppSizes.fontXXXL,
                fontWeight: FontWeight.bold,
              ),
            ),
            AppSpacing.verticalSpaceLG,
            Text(
              'Point your camera at a deadline or assignment to automatically extract the information.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: AppSizes.fontLG,
                color: Theme.of(context).textTheme.bodyMedium?.color,
              ),
            ),
            AppSpacing.verticalSpaceXXXL,
            BlocProvider(
              create: (_) => DeadlineScanCubit(),
              child: Builder(
                builder: (context) {
                  return Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () =>
                              _startScan(context, ImageSource.camera),
                          icon: const Icon(Icons.photo_camera_outlined),
                          label: const Text('Use Camera'),
                        ),
                      ),
                      AppSpacing.horizontalSpaceMD,
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () =>
                              _startScan(context, ImageSource.gallery),
                          icon: const Icon(Icons.photo_outlined),
                          label: const Text('Choose Photo'),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _startScan(BuildContext context, ImageSource source) async {
    final picker = ImagePicker();
    final x = await picker.pickImage(source: source);
    if (x == null) return;

    // Show "not implemented" message instead of calling OCR
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('OCR service not yet connected.')),
    );
    
    // Original OCR implementation (commented out - will be restored when OCR is connected):
    // final cubit = context.read<DeadlineScanCubit>();
    // await cubit.scanImage(File(x.path));
    // final state = cubit.state;
    // if (state is DeadlineScanError) {
    //   ScaffoldMessenger.of(context).showSnackBar(
    //     SnackBar(content: Text('Scan failed: ${state.message}')),
    //   );
    //   return;
    // }
    // if (state is DeadlineScanSuccess) {
    //   final result = await _showOCRReviewModal(
    //     context,
    //     title: state.title,
    //     course: state.courseCode,
    //     dateISO: state.date != null
    //         ? '${state.date!.year.toString().padLeft(4, '0')}-${state.date!.month.toString().padLeft(2, '0')}-${state.date!.day.toString().padLeft(2, '0')}'
    //         : '',
    //     type: state.type,
    //   );
    //   if (result is Map) {
    //     final title = (result['title'] as String).trim();
    //     final courseCode = (result['course'] as String).trim();
    //     final date = DateTime.parse(result['date'] as String);
    //     final typeStr = (result['type'] as String).toLowerCase();
    //     final scheduleCubit = context.read<ScheduleCubit>();
    //     String? courseId;
    //     for (final c in scheduleCubit.courses) {
    //       if (c.code.replaceAll(' ', '').toLowerCase() ==
    //           courseCode.replaceAll(' ', '').toLowerCase()) {
    //         courseId = c.id;
    //         break;
    //       }
    //     }
    //     final eventType = typeStr == 'exam' ? EventType.exam : EventType.assignment;
    //     final event = Event(
    //       id: 'scan:${date.millisecondsSinceEpoch}:${courseCode}',
    //       courseId: courseId ?? '',
    //       title: title.isEmpty
    //           ? (eventType == EventType.exam ? 'Exam' : 'Assignment')
    //           : title,
    //       dateTime: date,
    //       type: eventType,
    //       course: courseCode,
    //       description: '',
    //     );
    //     scheduleCubit.addEvent(event);
    //     ScaffoldMessenger.of(context).showSnackBar(
    //       const SnackBar(content: Text('Deadline added to calendar.')),
    //     );
    //   }
    // }
  }

  Future<dynamic> _showOCRReviewModal(
    BuildContext context, {
    required String title,
    required String course,
    required String dateISO,
    required String type,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => OCRReviewModal(
        initialTitle: title,
        initialCourse: course,
        initialDateISO: dateISO,
        initialType: type,
      ),
    );
  }
}

class OCRReviewModal extends StatefulWidget {
  final String initialTitle;
  final String initialCourse;
  final String initialDateISO; // YYYY-MM-DD
  final String initialType; // 'exam' | 'assignment'

  const OCRReviewModal({
    super.key,
    required this.initialTitle,
    required this.initialCourse,
    required this.initialDateISO,
    required this.initialType,
  });

  @override
  State<OCRReviewModal> createState() => _OCRReviewModalState();
}

class _OCRReviewModalState extends State<OCRReviewModal> {
  late final TextEditingController _titleController;
  late final TextEditingController _courseController;
  late final TextEditingController _dateController;
  String _selectedType = 'assignment';

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.initialTitle);
    _courseController = TextEditingController(text: widget.initialCourse);
    _dateController = TextEditingController(text: widget.initialDateISO);
    _selectedType = widget.initialType;
  }

  @override
  Widget build(BuildContext context) {
    final cardColor = Theme.of(context).cardColor;
    final handleColor = Theme.of(context).brightness == Brightness.dark
        ? Colors.white.withOpacity(0.2)
        : Colors.black.withOpacity(0.1);

    return Container(
      height: MediaQuery.of(context).size.height * 0.8,
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Padding(
        padding: AppSpacing.paddingXL,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Handle bar
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: handleColor,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            AppSpacing.verticalSpaceXL,

            Text(
              'Review Extracted Information',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontSize: AppSizes.fontXXL,
                fontWeight: FontWeight.bold,
              ),
            ),
            AppSpacing.verticalSpaceXL,

            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    TextField(
                      controller: _titleController,
                      decoration: const InputDecoration(
                        labelText: 'Title',
                        hintText: 'Enter event title',
                      ),
                    ),
                    AppSpacing.verticalSpaceLG,

                    TextField(
                      controller: _courseController,
                      decoration: const InputDecoration(
                        labelText: 'Course',
                        hintText: 'Enter course code',
                      ),
                    ),
                    AppSpacing.verticalSpaceLG,

                    TextField(
                      controller: _dateController,
                      decoration: const InputDecoration(
                        labelText: 'Date',
                        hintText: 'YYYY-MM-DD',
                      ),
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
                                color: Theme.of(context)
                                    .dividerColor
                                    .withOpacity(0.2),
                                width: 1,
                              ),
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    _selectedType == 'exam' ? 'Exam' : 'Assignment',
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
                                  color: Theme.of(context)
                                      .textTheme
                                      .bodyMedium
                                      ?.color,
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
            ),

            AppSpacing.verticalSpaceXL,
            Row(
              children: [
                Expanded(
                  child: TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Cancel'),
                  ),
                ),
                AppSpacing.horizontalSpaceLG,
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      // Build event date at 23:59
                      final parts = _dateController.text.split('-');
                      if (parts.length == 3) {
                        final y = int.tryParse(parts[0]);
                        final m = int.tryParse(parts[1]);
                        final d = int.tryParse(parts[2]);
                        if (y != null && m != null && d != null) {
                          final date = DateTime(y, m, d, 23, 59);
                          // Return a simple map back to caller to create Event in cubit/schedule
                          Navigator.pop(context, {
                            'title': _titleController.text.trim(),
                            'course': _courseController.text.trim(),
                            'date': date.toIso8601String(),
                            'type': _selectedType,
                          });
                          return;
                        }
                      }
                      Navigator.pop(context);
                    },
                    child: const Text('Save Event'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
