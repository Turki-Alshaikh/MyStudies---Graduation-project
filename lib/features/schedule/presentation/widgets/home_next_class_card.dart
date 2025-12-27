import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../calendar/data/models/event.dart';
import 'home_info_chip.dart';

import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_sizes.dart';
class HomeNextClassCard extends StatelessWidget {
  final Event? nextClass;

  const HomeNextClassCard({super.key, required this.nextClass});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: AppSpacing.elevationMD,
      shadowColor: AppTheme.shadowColor,
      shape: RoundedRectangleBorder(borderRadius: AppSpacing.borderRadiusXL),
      child: Container(
        width: double.infinity,
        padding: AppSpacing.paddingXXL,
        decoration: BoxDecoration(
          borderRadius: AppSpacing.borderRadiusXL,
          gradient: LinearGradient(
            colors: [AppTheme.primaryTeal, AppTheme.accentBlue],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          boxShadow: [
            BoxShadow(
              color: AppTheme.shadowColor.withOpacity(0.3),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: AppSpacing.paddingSM,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: AppSpacing.borderRadiusMD,
                  ),
                  child: const Icon(
                    Icons.access_time_rounded,
                    color: Colors.white,
                    size: AppSizes.fontXL,
                  ),
                ),
                AppSpacing.horizontalSpaceMD,
                const Text(
                  'NEXT CLASS',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: AppSizes.fontMD,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 1.2,
                  ),
                ),
              ],
            ),
            AppSpacing.verticalSpaceXL,
            if (nextClass != null) ...[
              Text(
                nextClass!.title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: AppSizes.fontXXXL + 4,
                  fontWeight: FontWeight.bold,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: AppSpacing.borderRadiusXL,
                ),
                child: Text(
                  '${nextClass!.course} • ${DateFormat('h:mm a').format(nextClass!.dateTime)}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: AppSizes.fontLG,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              AppSpacing.verticalSpaceXL,
              Row(
                children: [
                  HomeInfoChip(
                    icon: Icons.calendar_today_rounded,
                    text: DateFormat('EEE, MMM d').format(nextClass!.dateTime),
                  ),
                  if (nextClass!.description != null &&
                      nextClass!.description!.isNotEmpty) ...[
                    AppSpacing.horizontalSpaceMD,
                    Expanded(
                      child: HomeInfoChip(
                        icon: Icons.location_on_rounded,
                        text: nextClass!.description!,
                      ),
                    ),
                  ],
                ],
              ),
            ] else ...[
              const Text(
                'No upcoming classes',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: AppSizes.fontXXXL,
                  fontWeight: FontWeight.bold,
                  letterSpacing: -0.5,
                ),
              ),
              AppSpacing.verticalSpaceMD,
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.15),
                  borderRadius: AppSpacing.borderRadiusLG,
                  border: Border.all(color: Colors.white.withOpacity(0.1)),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.info_outline_rounded,
                      color: Colors.white.withOpacity(0.9),
                      size: AppSpacing.iconSM,
                    ),
                    AppSpacing.horizontalSpaceMD,
                    const Expanded(
                      child: Text(
                        'Import your schedule or add a class to see it here.',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: AppSizes.fontMD,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
