import 'package:flutter/material.dart';

import '../../../../core/constants/app_sizes.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/app_cards.dart';

class GpaSummaryCard extends StatelessWidget {
  final double gpa;
  final int credits;

  const GpaSummaryCard({super.key, required this.gpa, required this.credits});

  @override
  Widget build(BuildContext context) {
    return AppGradientCard(
      gradientColors: [
        AppTheme.primaryTeal,
        AppTheme.primaryTeal.withOpacity(0.75),
      ],
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const Text(
            'Semester GPA',
            style: TextStyle(
              color: Colors.white,
              fontSize: AppSizes.fontXL,
              fontWeight: FontWeight.w600,
            ),
          ),
          AppSpacing.verticalSpaceMD,
          Text(
            gpa.toStringAsFixed(2),
            style: const TextStyle(
              color: Colors.white,
              fontSize: AppSizes.gpaDisplaySize,
              fontWeight: FontWeight.bold,
              letterSpacing: -1,
            ),
          ),
          AppSpacing.verticalSpaceMD,
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.xl,
              vertical: AppSpacing.md - 2,
            ),
            decoration: BoxDecoration(
              color: Colors.white12,
              borderRadius: AppSpacing.borderRadiusXXL,
            ),
            child: Text(
              '$credits Credit Hours',
              style: const TextStyle(
                color: Colors.white,
                fontSize: AppSizes.fontLG,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
