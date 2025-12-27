import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../core/theme/app_theme.dart';

class ThemeCubit extends Cubit<bool> {
  static const _prefKeyDarkMode = 'settings_dark_mode';

  ThemeCubit() : super(false);

  ThemeData get currentTheme =>
      state ? AppTheme.darkTheme : AppTheme.lightTheme;

  bool get isDarkMode => state;

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    final stored = prefs.getBool(_prefKeyDarkMode) ?? false;
    emit(stored);
  }

  Future<void> toggleTheme() async {
    await setTheme(!state);
  }

  Future<void> setTheme(bool isDark) async {
    if (state == isDark) return;
    emit(isDark);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_prefKeyDarkMode, isDark);
  }
}
