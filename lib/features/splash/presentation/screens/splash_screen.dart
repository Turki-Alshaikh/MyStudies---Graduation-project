import 'dart:async';

import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../navigation/main_navigation.dart';

import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_sizes.dart';
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer(const Duration(seconds: 2), () {
      if (!mounted) return;
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const MainNavigation()),
      );
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : AppTheme.textPrimary;

    return Scaffold(
      body: Center(
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.school_rounded, color: AppTheme.primaryTeal, size: AppSpacing.iconXXL),
            AppSpacing.horizontalSpaceMD,
            Text(
              'MyStudies',
              style: TextStyle(
                fontSize: AppSizes.fontDisplay,
                fontWeight: FontWeight.bold,
                color: textColor,
                letterSpacing: -0.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
