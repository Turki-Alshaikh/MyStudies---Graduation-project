import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../schedule/presentation/cubits/schedule_cubit.dart';
import '../cubit/gpa_cubit.dart';
import '../widgets/current_gpa_tab.dart';
import '../widgets/target_gpa_tab.dart';

import '../../../../core/constants/app_spacing.dart';

class GPAScreen extends StatelessWidget {
  const GPAScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final scheduleCubit = context.read<ScheduleCubit>();
    return BlocProvider(
      create: (_) => GpaCubit(scheduleCubit: scheduleCubit),
      child: const _GpaView(),
    );
  }
}

class _GpaView extends StatelessWidget {
  const _GpaView();

  @override
  Widget build(BuildContext context) {
    final isSmallScreen = MediaQuery.of(context).size.width < 400;
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('GPA Calculator'),
          backgroundColor: Colors.transparent,
          elevation: AppSpacing.elevationNone,
        ),
        body: Column(
          children: [
            Padding(
              padding: EdgeInsets.fromLTRB(
                isSmallScreen ? 12 : 16,
                8,
                isSmallScreen ? 12 : 16,
                0,
              ),
              child: const _GpaTabSelector(),
            ),
            const Expanded(
              child: TabBarView(
                physics: NeverScrollableScrollPhysics(),
                children: [CurrentGpaTab(), TargetGpaTab()],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _GpaTabSelector extends StatefulWidget {
  const _GpaTabSelector();

  @override
  State<_GpaTabSelector> createState() => _GpaTabSelectorState();
}

class _GpaTabSelectorState extends State<_GpaTabSelector> {
  late TabController _controller;
  int _index = 0;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _controller = DefaultTabController.of(context);
    _index = _controller.index;
    _controller.removeListener(_handleChange);
    _controller.addListener(_handleChange);
  }

  void _handleChange() {
    if (mounted && _index != _controller.index) {
      setState(() => _index = _controller.index);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final unselected =
        Theme.of(context).textTheme.bodyMedium?.color ??
        (isDark ? Colors.white70 : Colors.black87);

    return Padding(
      padding: const EdgeInsets.all(AppSpacing.sm - 2),
      child: CupertinoSlidingSegmentedControl<int>(
        groupValue: _index,
        thumbColor: AppTheme.primaryTeal,
        backgroundColor: Colors.grey.withOpacity(0.1),
        children: {
          0: Padding(
            padding: const EdgeInsets.symmetric(
              vertical: AppSpacing.sm,
              horizontal: 12,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Calculator',
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    color: _index == 0 ? Colors.white : unselected,
                  ),
                ),
              ],
            ),
          ),
          1: Padding(
            padding: const EdgeInsets.symmetric(
              vertical: AppSpacing.sm,
              horizontal: 12,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Target',
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    color: _index == 1 ? Colors.white : unselected,
                  ),
                ),
              ],
            ),
          ),
        },
        onValueChanged: (value) {
          if (value != null) {
            _controller.animateTo(value);
            setState(() => _index = value);
          }
        },
      ),
    );
  }
}
