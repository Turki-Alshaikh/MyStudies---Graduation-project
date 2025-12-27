import 'package:flutter/material.dart';

import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_sizes.dart';
class HomeQuickAccessItem extends StatelessWidget {
  final String title;
  final IconData icon;
  final VoidCallback onTap;
  final Color color;
  final Gradient? gradient;

  const HomeQuickAccessItem({
    super.key,
    required this.title,
    required this.icon,
    required this.onTap,
    required this.color,
    this.gradient,
  });

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 1,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            gradient: gradient,
            borderRadius: AppSpacing.borderRadiusLG,
            boxShadow: [
              BoxShadow(
                color: color.withOpacity(0.3),
                blurRadius: 8,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: Colors.white, size: AppSpacing.iconLG),
              const SizedBox(height: AppSpacing.sm),
              Text(
                title,
                style: const TextStyle(
                  fontSize: AppSizes.fontSM,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                softWrap: true,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
