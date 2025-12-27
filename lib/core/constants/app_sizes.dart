/// Centralized size constants for text, icons, and other UI elements
/// Edit these values to change sizing app-wide
class AppSizes {
  AppSizes._();

  // Font sizes
  static const double fontXS = 10.0;
  static const double fontSM = 12.0;
  static const double fontMD = 14.0;
  static const double fontLG = 16.0;
  static const double fontXL = 18.0;
  static const double fontXXL = 20.0;
  static const double fontXXXL = 24.0;
  static const double fontDisplay = 32.0;
  static const double fontHero = 40.0;
  static const double fontGiant = 52.0;

  // Letter spacing
  static const double letterSpacingTight = -0.5;
  static const double letterSpacingNormal = 0.0;
  static const double letterSpacingWide = 0.5;

  // Line height multipliers
  static const double lineHeightTight = 1.2;
  static const double lineHeightNormal = 1.5;
  static const double lineHeightRelaxed = 1.75;

  // Opacity values
  static const double opacityDisabled = 0.38;
  static const double opacityMedium = 0.6;
  static const double opacityHigh = 0.87;
  static const double opacityFull = 1.0;

  // Opacity for overlays
  static const double overlayLight = 0.05;
  static const double overlayMedium = 0.1;
  static const double overlayDark = 0.2;

  // Shadow opacity
  static const double shadowLight = 0.1;
  static const double shadowMedium = 0.2;
  static const double shadowDark = 0.3;

  // Animation durations (milliseconds)
  static const int animationFast = 150;
  static const int animationNormal = 250;
  static const int animationSlow = 350;

  // Specific widget sizes
  static const double progressIndicatorSize = 24.0;
  static const double progressIndicatorSizeLG = 40.0;
  static const double checkboxSize = 20.0;
  static const double switchWidth = 51.0;
  static const double switchHeight = 31.0;

  // Image/Container aspect ratios
  static const double aspectRatioSquare = 1.0;
  static const double aspectRatioWide = 16 / 9;
  static const double aspectRatioUltraWide = 21 / 9;
  static const double aspectRatioPortrait = 3 / 4;

  // Stroke widths
  static const double strokeThin = 1.0;
  static const double strokeMedium = 2.0;
  static const double strokeThick = 3.0;
  static const double strokeBold = 4.0;

  // Specific component sizes (used in calendar, etc.)
  static const double calendarDaySize = 40.0;
  static const double weekdayHeaderHeight = 40.0;
  static const double monthHeaderHeight = 56.0;
  static const double timeSlotHeight = 60.0;
  static const double hourLabelWidth = 50.0;

  // GPA specific
  static const double gpaDisplaySize = 52.0;
  static const double gradeChipWidth = 60.0;

  // Event card specific
  static const double eventColorBarWidth = 6.0;
  static const double eventCardHeight = 50.0;

  // Icon container specific
  static const double iconContainerSize = 40.0;
  static const double iconContainerSizeSM = 32.0;
  static const double iconContainerSizeLG = 48.0;

  // Modal sizes (0.0 to 1.0)
  static const double modalInitialSize = 0.85;
  static const double modalMinSize = 0.3;
  static const double modalMaxSize = 0.98;
}
