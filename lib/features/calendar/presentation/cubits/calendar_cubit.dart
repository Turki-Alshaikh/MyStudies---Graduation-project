import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';

class CalendarCubit extends Cubit<Map<String, Color>> {
  CalendarCubit() : super(<String, Color>{});

  static const List<Color> _palette = <Color>[
    Color(0xFF90CAF9),
    Color(0xFFA5D6A7),
    Color(0xFFCE93D8),
    Color(0xFF80DEEA),
    Color(0xFF9FA8DA),
    Color(0xFFFFB74D),
    Color(0xFFEF5350),
    Color(0xFF64B5F6),
    Color(0xFF81C784),
    Color(0xFFBA68C8),
    Color(0xFF4DD0E1),
    Color(0xFF9575CD),
    Color(0xFFFFA726),
    Color(0xFFF06292),
    Color(0xFF4DB6AC),
    Color(0xFF7986CB),
    Color(0xFFFFB300),
    Color(0xFFE57373),
    Color(0xFF66BB6A),
    Color(0xFFAB47BC),
    Color(0xFF42A5F5),
    Color(0xFF26A69A),
    Color(0xFF7E57C2),
    Color(0xFFFF6F00),
    Color(0xFFEC407A),
  ];

  Color courseColorFor(String code) {
    final key = code.toUpperCase().trim();
    final existing = state[key];
    if (existing != null) return existing;

    // Stable hash
    int hash = 0;
    for (int i = 0; i < key.length; i++) {
      hash = ((hash << 5) - hash) + key.codeUnitAt(i);
      hash = hash & hash;
    }
    int idx = hash.abs() % _palette.length;
    int attempts = 0;
    while (state.values.contains(_palette[idx]) && attempts < _palette.length) {
      idx = (idx + 1) % _palette.length;
      attempts++;
    }

    final color = _palette[idx];
    final next = Map<String, Color>.from(state)..[key] = color;
    emit(next);
    return color;
  }
}
