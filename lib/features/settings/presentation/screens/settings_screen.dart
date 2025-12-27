import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/constants/app_spacing.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/app_cards.dart';
import '../cubit/theme_cubit.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  Color _textColor(BuildContext context) =>
      Theme.of(context).textTheme.bodyLarge?.color ?? Colors.black;
  Color _secondaryColor(BuildContext context) =>
      Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.7) ??
      Colors.grey;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        backgroundColor: Colors.transparent,
        elevation: AppSpacing.elevationNone,
      ),
      body: ListView(
        padding: AppSpacing.paddingLG,
        children: [
          _buildSectionHeader('Appearance'),
          _buildAppearanceSettings(),
          AppSpacing.verticalSpaceXXL,

          _buildSectionHeader('About'),
          _buildAboutSection(),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return AppSectionHeader(title: title);
  }

  Widget _buildAppearanceSettings() {
    return Card(
      child: BlocBuilder<ThemeCubit, bool>(
        builder: (context, isDarkMode) {
          return Column(
            children: [
              SwitchListTile(
                title: Text(
                  'Dark Mode',
                  style: TextStyle(
                    fontWeight: FontWeight.w500,
                    color: _textColor(context),
                  ),
                ),
                subtitle: Text(
                  'Switch to dark theme',
                  style: TextStyle(color: _secondaryColor(context)),
                ),
                value: isDarkMode,
                onChanged: (value) =>
                    context.read<ThemeCubit>().setTheme(value),
                activeColor: AppTheme.primaryTeal,
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildAboutSection() {
    return Card(
      child: Column(
        children: [
          ListTile(
            leading: AppIconContainer(
              icon: Icons.info,
              color: AppTheme.primaryTeal,
            ),
            title: Text(
              'App Version',
              style: TextStyle(
                fontWeight: FontWeight.w500,
                color: _textColor(context),
              ),
            ),
            subtitle: Text(
              '1.0.0',
              style: TextStyle(color: _secondaryColor(context)),
            ),
          ),
        ],
      ),
    );
  }
}
