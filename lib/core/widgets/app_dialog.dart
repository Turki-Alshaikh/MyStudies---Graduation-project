import 'package:flutter/material.dart';
import 'app_buttons.dart';

/// Reusable base dialog widget
class AppDialog extends StatelessWidget {
  final String title;
  final Widget content;
  final List<AppDialogAction>? actions;
  final bool scrollable;

  const AppDialog({
    super.key,
    required this.title,
    required this.content,
    this.actions,
    this.scrollable = true,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(title),
      content: scrollable ? SingleChildScrollView(child: content) : content,
      actions: actions?.map((action) => _buildAction(context, action)).toList(),
    );
  }

  Widget _buildAction(BuildContext context, AppDialogAction action) {
    if (action.isPrimary) {
      return AppPrimaryButton(
        onPressed: action.onPressed,
        text: action.text,
        isLoading: action.isLoading,
      );
    }
    return AppTextButton(
      onPressed: action.onPressed,
      text: action.text,
      color: action.isDestructive ? Colors.red : null,
    );
  }
}

/// Dialog action model
class AppDialogAction {
  final String text;
  final VoidCallback onPressed;
  final bool isPrimary;
  final bool isDestructive;
  final bool isLoading;

  const AppDialogAction({
    required this.text,
    required this.onPressed,
    this.isPrimary = false,
    this.isDestructive = false,
    this.isLoading = false,
  });
}

/// Reusable confirmation dialog
Future<bool?> showAppConfirmDialog({
  required BuildContext context,
  required String title,
  required String message,
  String confirmText = 'Confirm',
  String cancelText = 'Cancel',
  bool isDestructive = false,
}) {
  return showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(title),
      content: Text(message),
      actions: [
        AppTextButton(
          onPressed: () => Navigator.of(context).pop(false),
          text: cancelText,
        ),
        AppPrimaryButton(
          onPressed: () => Navigator.of(context).pop(true),
          text: confirmText,
        ),
      ],
    ),
  );
}

/// Reusable loading dialog
Future<void> showAppLoadingDialog(BuildContext context, String message) {
  return showDialog(
    context: context,
    barrierDismissible: false,
    builder: (context) => AlertDialog(
      content: Row(
        children: [
          const CircularProgressIndicator(),
          const SizedBox(width: 24),
          Expanded(child: Text(message)),
        ],
      ),
    ),
  );
}
