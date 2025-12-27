import 'package:flutter/material.dart';

import '../constants/app_sizes.dart';
import '../constants/app_spacing.dart';

/// Primary elevated button with consistent styling
class AppPrimaryButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final String text;
  final IconData? icon;
  final bool isLoading;
  final EdgeInsets? padding;

  const AppPrimaryButton({
    super.key,
    required this.onPressed,
    required this.text,
    this.icon,
    this.isLoading = false,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    if (icon != null) {
      return ElevatedButton.icon(
        onPressed: isLoading ? null : onPressed,
        icon: isLoading
            ? const SizedBox(
                width: AppSpacing.iconXS,
                height: AppSpacing.iconXS,
                child: CircularProgressIndicator(
                  strokeWidth: AppSizes.strokeMedium,
                ),
              )
            : Icon(icon),
        label: Text(text),
        style: ElevatedButton.styleFrom(
          padding:
              padding ??
              const EdgeInsets.symmetric(
                horizontal: AppSpacing.xxl,
                vertical: AppSpacing.md,
              ),
        ),
      );
    }

    return ElevatedButton(
      onPressed: isLoading ? null : onPressed,
      style: ElevatedButton.styleFrom(
        padding:
            padding ??
            const EdgeInsets.symmetric(
              horizontal: AppSpacing.xxl,
              vertical: AppSpacing.md,
            ),
      ),
      child: isLoading
          ? const SizedBox(
              width: AppSpacing.iconXS,
              height: AppSpacing.iconXS,
              child: CircularProgressIndicator(
                strokeWidth: AppSizes.strokeMedium,
              ),
            )
          : Text(text),
    );
  }
}

/// Outlined button with consistent styling
class AppOutlinedButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final String text;
  final IconData? icon;
  final Color? color;
  final EdgeInsets? padding;

  const AppOutlinedButton({
    super.key,
    required this.onPressed,
    required this.text,
    this.icon,
    this.color,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    final buttonStyle = OutlinedButton.styleFrom(
      padding:
          padding ??
          const EdgeInsets.symmetric(
            horizontal: AppSpacing.xxl,
            vertical: AppSpacing.md,
          ),
      side: color != null
          ? BorderSide(color: color!, width: AppSizes.strokeMedium)
          : null,
      foregroundColor: color,
    );

    if (icon != null) {
      return OutlinedButton.icon(
        onPressed: onPressed,
        icon: Icon(icon),
        label: Text(text),
        style: buttonStyle,
      );
    }

    return OutlinedButton(
      onPressed: onPressed,
      style: buttonStyle,
      child: Text(text),
    );
  }
}

/// Text button with consistent styling
class AppTextButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final String text;
  final Color? color;

  const AppTextButton({
    super.key,
    required this.onPressed,
    required this.text,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: onPressed,
      style: color != null
          ? TextButton.styleFrom(foregroundColor: color)
          : null,
      child: Text(text),
    );
  }
}

/// Icon button with consistent styling and optional badge
class AppIconButton extends StatelessWidget {
  final VoidCallback onPressed;
  final IconData icon;
  final String? tooltip;
  final Color? color;
  final int? badgeCount;

  const AppIconButton({
    super.key,
    required this.onPressed,
    required this.icon,
    this.tooltip,
    this.color,
    this.badgeCount,
  });

  @override
  Widget build(BuildContext context) {
    final button = IconButton(
      onPressed: onPressed,
      icon: Icon(icon),
      tooltip: tooltip,
      color: color,
    );

    if (badgeCount != null && badgeCount! > 0) {
      return Stack(
        clipBehavior: Clip.none,
        children: [
          button,
          Positioned(
            right: AppSpacing.sm,
            top: AppSpacing.sm,
            child: Container(
              padding: AppSpacing.paddingXS,
              decoration: const BoxDecoration(
                color: Colors.red,
                shape: BoxShape.circle,
              ),
              constraints: const BoxConstraints(
                minWidth: AppSpacing.iconXS,
                minHeight: AppSpacing.iconXS,
              ),
              child: Text(
                badgeCount! > 99 ? '99+' : badgeCount.toString(),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: AppSizes.fontXS,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ],
      );
    }

    return button;
  }
}
