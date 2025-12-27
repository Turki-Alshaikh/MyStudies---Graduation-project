import 'package:flutter/material.dart';

import '../constants/app_sizes.dart';
import '../constants/app_spacing.dart';

/// Reusable gradient card widget
class AppGradientCard extends StatelessWidget {
  final Widget child;
  final List<Color> gradientColors;
  final double borderRadius;
  final EdgeInsets padding;
  final double elevation;

  const AppGradientCard({
    super.key,
    required this.child,
    required this.gradientColors,
    this.borderRadius = AppSpacing.radiusXL,
    this.padding = AppSpacing.paddingXXL,
    this.elevation = AppSpacing.elevationMD,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: elevation,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(borderRadius),
      ),
      child: Container(
        width: double.infinity,
        padding: padding,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(borderRadius),
          gradient: LinearGradient(
            colors: gradientColors,
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: child,
      ),
    );
  }
}

/// Reusable icon container (used for leading icons in lists, etc.)
class AppIconContainer extends StatelessWidget {
  final IconData icon;
  final Color color;
  final double size;
  final double iconSize;

  const AppIconContainer({
    super.key,
    required this.icon,
    required this.color,
    this.size = AppSizes.iconContainerSize,
    this.iconSize = AppSpacing.iconMD,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color.withOpacity(AppSizes.overlayMedium),
        borderRadius: AppSpacing.borderRadiusSM,
      ),
      child: Icon(icon, color: color, size: iconSize),
    );
  }
}

/// Reusable chip widget
class AppChip extends StatelessWidget {
  final String text;
  final Color color;
  final IconData? icon;
  final EdgeInsets padding;

  const AppChip({
    super.key,
    required this.text,
    required this.color,
    this.icon,
    this.padding = const EdgeInsets.symmetric(
      horizontal: AppSpacing.md - 2,
      vertical: AppSpacing.xs,
    ),
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: color.withOpacity(AppSizes.overlayMedium),
        borderRadius: AppSpacing.borderRadiusMD,
        border: Border.all(
          color: color.withOpacity(AppSizes.shadowDark),
          width: AppSizes.strokeThin,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: AppSizes.fontMD, color: color),
            AppSpacing.horizontalSpaceXS,
          ],
          Text(
            text,
            style: TextStyle(
              fontSize: AppSizes.fontXS,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

/// Reusable section header
class AppSectionHeader extends StatelessWidget {
  final String title;
  final IconData? icon;
  final Color? iconColor;
  final Widget? trailing;
  final double? iconContainerSize;
  final double? iconSize;

  const AppSectionHeader({
    super.key,
    required this.title,
    this.icon,
    this.iconColor,
    this.trailing,
    this.iconContainerSize,
    this.iconSize,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(
        left: AppSpacing.xs,
        bottom: AppSpacing.lg,
      ),
      child: Row(
        children: [
          if (icon != null) ...[
            AppIconContainer(
              icon: icon!,
              color: iconColor ?? Theme.of(context).primaryColor,
              size: iconContainerSize ?? AppSpacing.iconLG,
              iconSize: iconSize ?? AppSpacing.iconSM,
            ),
            const SizedBox(width: AppSpacing.md - 2),
          ],
          Expanded(
            child: Text(
              title,
              style: TextStyle(
                fontSize: AppSizes.fontXXL,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).brightness == Brightness.dark
                    ? Colors.white
                    : Theme.of(context).textTheme.titleLarge?.color,
              ),
            ),
          ),
          if (trailing != null) trailing!,
        ],
      ),
    );
  }
}

/// Reusable empty state widget
class AppEmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String message;
  final Widget? action;

  const AppEmptyState({
    super.key,
    required this.icon,
    required this.title,
    required this.message,
    this.action,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: AppSpacing.paddingXXXL,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: AppSpacing.iconXXXL + 32,
              color: Theme.of(context).disabledColor,
            ),
            AppSpacing.verticalSpaceXXL,
            Text(
              title,
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            AppSpacing.verticalSpaceSM,
            Text(
              message,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(
                  context,
                ).textTheme.bodyMedium?.color?.withOpacity(0.7),
              ),
              textAlign: TextAlign.center,
            ),
            if (action != null) ...[AppSpacing.verticalSpaceXXL, action!],
          ],
        ),
      ),
    );
  }
}
