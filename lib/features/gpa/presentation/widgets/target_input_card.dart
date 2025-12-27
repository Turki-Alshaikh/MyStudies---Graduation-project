import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/app_theme.dart';
import '../cubit/gpa_cubit.dart';
import '../cubit/gpa_state.dart';

import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_sizes.dart';

class TargetInputCard extends StatefulWidget {
  const TargetInputCard({super.key});

  @override
  State<TargetInputCard> createState() => _TargetInputCardState();
}

class _TargetInputCardState extends State<TargetInputCard> {
  late final TextEditingController _targetController;
  late final TextEditingController _remainingController;
  late final TextEditingController _cgpaController;
  late final TextEditingController _earnedController;

  @override
  void initState() {
    super.initState();
    final cubit = context.read<GpaCubit>();
    final state = cubit.state;
    _targetController = TextEditingController(
      text: state.targetGpa > 0 ? state.targetGpa.toString() : '',
    );
    _remainingController = TextEditingController(
      text: state.remainingHours > 0 ? state.remainingHours.toString() : '',
    );
    _cgpaController = TextEditingController(
      text: state.overrideCgpa?.toString() ?? '',
    );
    _earnedController = TextEditingController(
      text: state.overrideEarnedHours?.toString() ?? '',
    );
  }

  @override
  void dispose() {
    _targetController.dispose();
    _remainingController.dispose();
    _cgpaController.dispose();
    _earnedController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<GpaCubit>();
    final state = cubit.state;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final fillColor = isDark
        ? Colors.white.withOpacity(0.05)
        : Colors.grey.withOpacity(0.06);

    return Card(
      elevation: AppSpacing.elevationSM,
      shape: RoundedRectangleBorder(borderRadius: AppSpacing.borderRadiusLG),
      child: Padding(
        padding: AppSpacing.paddingXL,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.emoji_events_outlined,
                  color: AppTheme.primaryTeal,
                  size: AppSpacing.iconMD,
                ),
                const SizedBox(width: AppSpacing.md - 2),
                Text(
                  'Set Target GPA',
                  style: TextStyle(
                    fontSize: AppSizes.fontXXL,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : AppTheme.textPrimary,
                  ),
                ),
              ],
            ),
            AppSpacing.verticalSpaceXL,
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _cgpaController,
                    decoration: _inputDecoration(
                      label: 'CGPA',
                      hint: '3.20',
                      fillColor: fillColor,
                      suffix: '/ 4.0',
                    ),
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    onChanged: (value) =>
                        cubit.updateOverrideCgpa(double.tryParse(value)),
                  ),
                ),
                AppSpacing.horizontalSpaceMD,
                Expanded(
                  child: TextField(
                    controller: _earnedController,
                    decoration: _inputDecoration(
                      label: 'Earned Hours',
                      hint: '75',
                      fillColor: fillColor,
                    ),
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: false,
                    ),
                    onChanged: (value) =>
                        cubit.updateOverrideEarnedHours(int.tryParse(value)),
                  ),
                ),
              ],
            ),

            AppSpacing.verticalSpaceLG,
            TextField(
              controller: _targetController,
              decoration: _inputDecoration(
                label: 'Target GPA',
                hint: '3.5',
                fillColor: fillColor,
                suffix: '/ 4.0',
              ),
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              onChanged: (value) {
                if (value.isNotEmpty) HapticFeedback.selectionClick();
                cubit.updateTargetGpa(double.tryParse(value));
              },
            ),
            AppSpacing.verticalSpaceLG,
            TextField(
              controller: _remainingController,
              decoration: _inputDecoration(
                label: 'Remaining Credit Hours',
                hint: 'e.g., 15',
                fillColor: fillColor,
              ),
              keyboardType: const TextInputType.numberWithOptions(
                decimal: false,
              ),
              onChanged: (value) {
                if (value.isNotEmpty) HapticFeedback.selectionClick();
                cubit.updateRemainingHours(int.tryParse(value));
              },
            ),
            AppSpacing.verticalSpaceLG,
            Text(
              'Course Credit Size',
              style: TextStyle(
                fontSize: AppSizes.fontMD,
                fontWeight: FontWeight.w600,
                color: isDark ? Colors.white : AppTheme.textPrimary,
              ),
            ),
            AppSpacing.verticalSpaceSM,
            _CreditModeSelector(state: state, cubit: cubit),
          ],
        ),
      ),
    );
  }

  InputDecoration _inputDecoration({
    required String label,
    required String hint,
    required Color fillColor,
    String? suffix,
  }) {
    return InputDecoration(
      labelText: label,
      hintText: hint,
      suffixText: suffix,
      filled: true,
      fillColor: fillColor,
      border: OutlineInputBorder(
        borderRadius: AppSpacing.borderRadiusMD,
        borderSide: BorderSide.none,
      ),
      contentPadding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: 16,
      ),
    );
  }
}

class _CreditModeSelector extends StatelessWidget {
  final GpaState state;
  final GpaCubit cubit;

  const _CreditModeSelector({required this.state, required this.cubit});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final modeEnabled = {
      '2': cubit.isCreditModeEnabled('2'),
      '3': cubit.isCreditModeEnabled('3'),
      '4': cubit.isCreditModeEnabled('4'),
      'mix': cubit.isCreditModeEnabled('mix'),
    };

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(AppSpacing.sm - 2),
          child: CupertinoSlidingSegmentedControl<String>(
            groupValue: state.creditMode,
            thumbColor: AppTheme.primaryTeal,
            backgroundColor: isDark
                ? const Color(0xFF1A232F)
                : const Color(0xFFE0E0E0),
            children: {
              '2': _CreditModeLabel(
                label: '2',
                enabled: modeEnabled['2']!,
                selected: state.creditMode == '2',
              ),
              '3': _CreditModeLabel(
                label: '3',
                enabled: modeEnabled['3']!,
                selected: state.creditMode == '3',
              ),
              '4': _CreditModeLabel(
                label: '4',
                enabled: modeEnabled['4']!,
                selected: state.creditMode == '4',
              ),
              'mix': _CreditModeLabel(
                label: 'Mix',
                enabled: modeEnabled['mix']!,
                selected: state.creditMode == 'mix',
              ),
            },
            onValueChanged: (value) {
              if (value == null) return;
              if (!cubit.isCreditModeEnabled(value)) {
                cubit.updateCreditMode('mix');
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text(
                      'Remaining credits are not divisible by that option. Using Mix instead.',
                    ),
                  ),
                );
                return;
              }
              HapticFeedback.selectionClick();
              cubit.updateCreditMode(value);
            },
          ),
        ),
        AppSpacing.verticalSpaceSM,
        if (state.creditMode != 'mix' && state.remainingHours > 0)
          Builder(
            builder: (_) {
              final fixed = int.tryParse(state.creditMode);
              if (fixed == null) return const SizedBox.shrink();
              if (state.remainingHours % fixed != 0) {
                return Text(
                  'Remaining hours are not divisible by $fixed. Choose Mix or adjust the value.',
                  style: TextStyle(
                    color: Colors.orange.shade700,
                    fontSize: AppSizes.fontSM,
                  ),
                );
              }
              return const SizedBox.shrink();
            },
          ),
      ],
    );
  }
}

class _CreditModeLabel extends StatelessWidget {
  final String label;
  final bool enabled;
  final bool selected;

  const _CreditModeLabel({
    required this.label,
    required this.enabled,
    required this.selected,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final color = enabled
        ? (selected
              ? Colors.white
              : (isDark ? Colors.grey.shade400 : Colors.black87))
        : Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.3);
    return Padding(
      padding: const EdgeInsets.symmetric(
        vertical: AppSpacing.sm,
        horizontal: 12,
      ),
      child: Center(
        child: Text(
          label,
          style: TextStyle(
            fontSize: AppSizes.fontLG,
            fontWeight: FontWeight.w600,
            color: color,
            letterSpacing: 0.2,
          ),
        ),
      ),
    );
  }
}
