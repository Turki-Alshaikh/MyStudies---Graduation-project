import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/navigation_utils.dart';
import '../../../../core/widgets/app_cards.dart';
import '../screens/import_schedule_screen.dart';
import '../screens/scan_deadline_screen.dart';
import 'add_event_bottom_sheet.dart';
import 'home_quick_access_item.dart';

import '../../../../core/constants/app_spacing.dart';
class HomeQuickAccessSection extends StatelessWidget {
  const HomeQuickAccessSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppSectionHeader(
          title: 'Quick Access',
          icon: Icons.bolt_rounded,
          iconColor: AppTheme.primaryIndigo,
        ),
        AppSpacing.verticalSpaceLG,
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: HomeQuickAccessItem(
                title: 'Import Schedule',
                icon: Icons.calendar_month_rounded,
                onTap: () =>
                    AppNavigation.push(context, const ImportScheduleScreen()),
                color: AppTheme.primaryTeal,
                gradient: LinearGradient(
                  colors: [AppTheme.primaryTeal, AppTheme.classTeal],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
            ),
            AppSpacing.horizontalSpaceMD,
            Expanded(
              child: HomeQuickAccessItem(
                title: 'Scan Deadline',
                icon: Icons.document_scanner_rounded,
                onTap: () =>
                    AppNavigation.push(context, const ScanDeadlineScreen()),
                color: AppTheme.assignmentOrange,
                gradient: LinearGradient(
                  colors: [AppTheme.assignmentOrange, AppTheme.deadlineYellow],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
            ),
            AppSpacing.horizontalSpaceMD,
            Expanded(
              child: HomeQuickAccessItem(
                title: 'Add Events',
                icon: Icons.add_circle_rounded,
                onTap: () => showAddEventBottomSheet(context),
                color: AppTheme.primaryIndigo,
                gradient: LinearGradient(
                  colors: [AppTheme.primaryIndigo, AppTheme.primaryTeal],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
