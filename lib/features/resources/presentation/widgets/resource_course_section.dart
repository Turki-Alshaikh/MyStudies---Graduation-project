import 'package:flutter/material.dart';

import '../../../../core/constants/app_sizes.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/app_cards.dart';
import '../../../schedule/data/models/course.dart';
import 'resource_card.dart';
import '../../data/models/resource.dart';

class ResourceCourseSection extends StatelessWidget {
  final Course course;
  final List<Resource> resources;

  const ResourceCourseSection({
    super.key,
    required this.course,
    required this.resources,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: AppSpacing.lg),
      child: ExpansionTile(
        title: Text(
          course.code,
          style: TextStyle(
            fontSize: AppSizes.fontXL,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).textTheme.titleLarge?.color,
          ),
        ),
        subtitle: Text(
          '${resources.length} resources',
          style: TextStyle(
            color: Theme.of(
              context,
            ).textTheme.bodyMedium?.color?.withOpacity(0.7),
          ),
        ),
        leading: AppIconContainer(
          icon: Icons.school,
          color: AppTheme.classTeal,
        ),
        children: [
          if (resources.isEmpty)
            Padding(
              padding: AppSpacing.paddingLG,
              child: const Text(
                'No available resources.',
                style: TextStyle(color: AppTheme.textSecondary),
              ),
            )
          else
            Padding(
              padding: AppSpacing.paddingLG,
              child: Column(
                children: resources
                    .map((resource) => ResourceCard(resource: resource))
                    .toList(),
              ),
            ),
        ],
      ),
    );
  }
}
