import 'package:flutter/material.dart';

import '../../../../core/constants/app_sizes.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/utils/date_utils.dart';
import '../../../../core/widgets/app_cards.dart';
import '../../../calendar/data/models/event.dart';
import '../../../calendar/presentation/widgets/event_detail_modal.dart';

class HomeDeadlineCard extends StatelessWidget {
  final Event deadline;
  const HomeDeadlineCard({super.key, required this.deadline});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => showEventDetailModal(context, deadline),
      child: Card(
        elevation: AppSpacing.elevationSM,
        shadowColor: Colors.black.withOpacity(AppSizes.overlayMedium),
        shape: RoundedRectangleBorder(borderRadius: AppSpacing.borderRadiusLG),
        margin: AppSpacing.cardMargin,
        child: Padding(
          padding: AppSpacing.paddingLG,
          child: Row(
            children: [
              Container(
                width: AppSizes.eventColorBarWidth,
                height: AppSizes.eventCardHeight,
                decoration: BoxDecoration(
                  color: deadline.color,
                  borderRadius: BorderRadius.circular(AppSpacing.radiusXS - 1),
                  boxShadow: [
                    BoxShadow(
                      color: deadline.color.withOpacity(AppSizes.shadowDark),
                      blurRadius: AppSpacing.xs,
                      offset: const Offset(0, AppSizes.strokeMedium),
                    ),
                  ],
                ),
              ),
              AppSpacing.horizontalSpaceLG,
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      deadline.title,
                      style: TextStyle(
                        fontSize: AppSizes.fontLG,
                        fontWeight: FontWeight.w600,
                        letterSpacing: AppSizes.letterSpacingTight + 0.2,
                        color: Theme.of(context).textTheme.bodyLarge?.color,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.sm - 2),
                    Text(
                      deadline.course,
                      style: TextStyle(
                        fontSize: AppSizes.fontMD,
                        fontWeight: FontWeight.w500,
                        color: Theme.of(
                          context,
                        ).textTheme.bodyMedium?.color?.withOpacity(0.7),
                      ),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.md - 2,
                      vertical: AppSpacing.xs,
                    ),
                    decoration: BoxDecoration(
                      color: deadline.color.withOpacity(AppSizes.overlayMedium),
                      borderRadius: AppSpacing.borderRadiusMD,
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.access_time_rounded,
                          size: AppSizes.fontMD,
                          color: deadline.color,
                        ),
                        AppSpacing.horizontalSpaceXS,
                        Text(
                          AppDateUtils.formatDateTime(deadline.dateTime),
                          style: TextStyle(
                            fontSize: AppSizes.fontSM,
                            fontWeight: FontWeight.w500,
                            color: deadline.color,
                          ),
                        ),
                      ],
                    ),
                  ),
                  AppSpacing.verticalSpaceSM,
                  AppChip(
                    text: deadline.type.name.toUpperCase(),
                    color: deadline.color,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
