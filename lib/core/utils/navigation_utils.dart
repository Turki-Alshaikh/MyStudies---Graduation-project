import 'package:flutter/material.dart';

class AppNavigation {
  /// Push a new screen
  static Future<T?> push<T>(BuildContext context, Widget screen) {
    return Navigator.push<T>(
      context,
      MaterialPageRoute(builder: (_) => screen),
    );
  }

  /// Push and replace current screen
  static Future<T?> pushReplacement<T>(BuildContext context, Widget screen) {
    return Navigator.pushReplacement<T, void>(
      context,
      MaterialPageRoute(builder: (_) => screen),
    );
  }

  /// Push and remove all previous routes
  static Future<T?> pushAndRemoveUntil<T>(BuildContext context, Widget screen) {
    return Navigator.pushAndRemoveUntil<T>(
      context,
      MaterialPageRoute(builder: (_) => screen),
      (route) => false,
    );
  }

  /// Pop current screen
  static void pop<T>(BuildContext context, [T? result]) {
    Navigator.pop<T>(context, result);
  }

  /// Pop until a specific route
  static void popUntil(BuildContext context, bool Function(Route) predicate) {
    Navigator.popUntil(context, predicate);
  }

  /// Check if can pop
  static bool canPop(BuildContext context) {
    return Navigator.canPop(context);
  }
}
