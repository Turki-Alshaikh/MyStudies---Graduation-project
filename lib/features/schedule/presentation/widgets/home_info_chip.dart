import 'package:flutter/material.dart';

import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_sizes.dart';
class HomeInfoChip extends StatelessWidget {
  final IconData icon;
  final String text;

  const HomeInfoChip({super.key, required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        borderRadius: AppSpacing.borderRadiusLG,
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white, size: AppSpacing.iconXS),
          AppSpacing.horizontalSpaceSM,
          Flexible(
            child: Text(
              text,
              style: const TextStyle(
                color: Colors.white,
                fontSize: AppSizes.fontMD,
                fontWeight: FontWeight.w500,
              ),
              maxLines: 2,
              softWrap: true,
              overflow: TextOverflow.fade,
            ),
          ),
        ],
      ),
    );
  }
}
