import 'package:flutter/material.dart';

import '../../../../core/constants/app_spacing.dart';
class ResourcesEmptyState extends StatelessWidget {
  const ResourcesEmptyState({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: AppSpacing.paddingXXXL,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.folder_off,
              size: 64,
              color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.3),
            ),
            AppSpacing.verticalSpaceLG,
            Text(
              'No courses available',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            AppSpacing.verticalSpaceSM,
            Text(
              'Import your schedule to automatically load course resources.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context)
                        .textTheme
                        .bodyMedium
                        ?.color
                        ?.withOpacity(0.75),
                  ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
