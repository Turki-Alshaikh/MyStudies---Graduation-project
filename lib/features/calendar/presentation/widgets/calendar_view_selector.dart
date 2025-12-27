import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';

import '../../../../core/constants/app_spacing.dart';

class CalendarViewSelector extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int?> onValueChanged;

  const CalendarViewSelector({
    super.key,
    required this.selectedIndex,
    required this.onValueChanged,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.sm - 2),
      child: CupertinoSlidingSegmentedControl<int>(
        groupValue: selectedIndex,
        backgroundColor: isDark ? const Color(0xFF1A232F) : const Color(0xFFE0E0E0),
        thumbColor: AppTheme
            .primaryTeal, // Change this to any Color to update the active pill background.
        children: {
          0: _buildSegment(
            'Weekly',
            selectedIndex == 0,
            _textColor(context, isSelected: selectedIndex == 0),
          ),
          1: _buildSegment(
            'Monthly',
            selectedIndex == 1,
            _textColor(context, isSelected: selectedIndex == 1),
          ),
        },
        onValueChanged: onValueChanged,
      ),
    );
  }

  Widget _buildSegment(String text, bool isSelected, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        vertical: AppSpacing.sm,
        horizontal: 12,
      ),
      child: Text(
        text,
        style: TextStyle(fontWeight: FontWeight.w700, color: color),
      ),
    );
  }

  Color _textColor(BuildContext context, {required bool isSelected}) {
    if (isSelected) return Colors.white;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return isDark ? Colors.grey.shade400 : Colors.black87;
  }
}
