import 'package:flutter/material.dart';

/// Centralized spacing constants for the entire app
/// Edit these values to change spacing app-wide
class AppSpacing {
  AppSpacing._();

  // Padding values
  static const double xs = 4.0;
  static const double sm = 8.0;
  static const double md = 12.0;
  static const double lg = 16.0;
  static const double xl = 20.0;
  static const double xxl = 24.0;
  static const double xxxl = 32.0;

  // Common EdgeInsets
  static const EdgeInsets paddingXS = EdgeInsets.all(xs);
  static const EdgeInsets paddingSM = EdgeInsets.all(sm);
  static const EdgeInsets paddingMD = EdgeInsets.all(md);
  static const EdgeInsets paddingLG = EdgeInsets.all(lg);
  static const EdgeInsets paddingXL = EdgeInsets.all(xl);
  static const EdgeInsets paddingXXL = EdgeInsets.all(xxl);
  static const EdgeInsets paddingXXXL = EdgeInsets.all(xxxl);

  // Horizontal padding
  static const EdgeInsets horizontalXS = EdgeInsets.symmetric(horizontal: xs);
  static const EdgeInsets horizontalSM = EdgeInsets.symmetric(horizontal: sm);
  static const EdgeInsets horizontalMD = EdgeInsets.symmetric(horizontal: md);
  static const EdgeInsets horizontalLG = EdgeInsets.symmetric(horizontal: lg);
  static const EdgeInsets horizontalXL = EdgeInsets.symmetric(horizontal: xl);
  static const EdgeInsets horizontalXXL = EdgeInsets.symmetric(horizontal: xxl);

  // Vertical padding
  static const EdgeInsets verticalXS = EdgeInsets.symmetric(vertical: xs);
  static const EdgeInsets verticalSM = EdgeInsets.symmetric(vertical: sm);
  static const EdgeInsets verticalMD = EdgeInsets.symmetric(vertical: md);
  static const EdgeInsets verticalLG = EdgeInsets.symmetric(vertical: lg);
  static const EdgeInsets verticalXL = EdgeInsets.symmetric(vertical: xl);
  static const EdgeInsets verticalXXL = EdgeInsets.symmetric(vertical: xxl);

  // Gap values (for spacing between widgets)
  static const double gapXS = 4.0;
  static const double gapSM = 8.0;
  static const double gapMD = 12.0;
  static const double gapLG = 16.0;
  static const double gapXL = 20.0;
  static const double gapXXL = 24.0;
  static const double gapXXXL = 32.0;

  // SizedBox shortcuts
  static const SizedBox verticalSpaceXS = SizedBox(height: gapXS);
  static const SizedBox verticalSpaceSM = SizedBox(height: gapSM);
  static const SizedBox verticalSpaceMD = SizedBox(height: gapMD);
  static const SizedBox verticalSpaceLG = SizedBox(height: gapLG);
  static const SizedBox verticalSpaceXL = SizedBox(height: gapXL);
  static const SizedBox verticalSpaceXXL = SizedBox(height: gapXXL);
  static const SizedBox verticalSpaceXXXL = SizedBox(height: gapXXXL);

  static const SizedBox horizontalSpaceXS = SizedBox(width: gapXS);
  static const SizedBox horizontalSpaceSM = SizedBox(width: gapSM);
  static const SizedBox horizontalSpaceMD = SizedBox(width: gapMD);
  static const SizedBox horizontalSpaceLG = SizedBox(width: gapLG);
  static const SizedBox horizontalSpaceXL = SizedBox(width: gapXL);
  static const SizedBox horizontalSpaceXXL = SizedBox(width: gapXXL);
  static const SizedBox horizontalSpaceXXXL = SizedBox(width: gapXXXL);

  // Border radius
  static const double radiusXS = 4.0;
  static const double radiusSM = 8.0;
  static const double radiusMD = 12.0;
  static const double radiusLG = 16.0;
  static const double radiusXL = 20.0;
  static const double radiusXXL = 24.0;
  static const double radiusRound = 28.0;
  static const double radiusCircular = 999.0;

  // BorderRadius shortcuts
  static BorderRadius borderRadiusXS = BorderRadius.circular(radiusXS);
  static BorderRadius borderRadiusSM = BorderRadius.circular(radiusSM);
  static BorderRadius borderRadiusMD = BorderRadius.circular(radiusMD);
  static BorderRadius borderRadiusLG = BorderRadius.circular(radiusLG);
  static BorderRadius borderRadiusXL = BorderRadius.circular(radiusXL);
  static BorderRadius borderRadiusXXL = BorderRadius.circular(radiusXXL);
  static BorderRadius borderRadiusRound = BorderRadius.circular(radiusRound);

  // Icon sizes
  static const double iconXS = 16.0;
  static const double iconSM = 20.0;
  static const double iconMD = 24.0;
  static const double iconLG = 28.0;
  static const double iconXL = 32.0;
  static const double iconXXL = 40.0;
  static const double iconXXXL = 48.0;

  // Elevation
  static const double elevationNone = 0.0;
  static const double elevationXS = 1.0;
  static const double elevationSM = 2.0;
  static const double elevationMD = 4.0;
  static const double elevationLG = 8.0;
  static const double elevationXL = 12.0;

  // Specific UI element sizes
  static const double appBarHeight = 56.0;
  static const double bottomNavHeight = 60.0;
  static const double buttonHeight = 48.0;
  static const double buttonHeightSM = 36.0;
  static const double buttonHeightLG = 56.0;
  static const double inputHeight = 48.0;
  static const double chipHeight = 32.0;
  static const double avatarSizeXS = 24.0;
  static const double avatarSizeSM = 32.0;
  static const double avatarSizeMD = 40.0;
  static const double avatarSizeLG = 48.0;
  static const double avatarSizeXL = 64.0;

  // Card specific
  static const double cardElevation = 2.0;
  static const double cardBorderRadius = 16.0;
  static const EdgeInsets cardPadding = EdgeInsets.all(lg);
  static const EdgeInsets cardMargin = EdgeInsets.only(bottom: md);

  // List item specific
  static const double listItemHeight = 72.0;
  static const double listItemHeightSM = 56.0;
  static const double listItemHeightLG = 88.0;

  // Divider
  static const double dividerThickness = 1.0;
  static const double dividerIndent = lg;

  // Container constraints
  static const double maxContentWidth = 600.0;
  static const double minTapTargetSize = 44.0;
}
