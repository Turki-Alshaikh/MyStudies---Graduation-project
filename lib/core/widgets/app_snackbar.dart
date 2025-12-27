import 'package:flutter/material.dart';

class AppSnackBars {
  static OverlayEntry? _current;

  static void show(
    BuildContext context, {
    required String message,
    required bool success,
    IconData? icon,
    Duration duration = const Duration(seconds: 3),
  }) {
    // Remove any existing to avoid stacking
    _current?.remove();
    _current = null;

    final overlay = Overlay.of(context, rootOverlay: true);

    final entry = OverlayEntry(
      builder: (ctx) => _SnackOverlay(
        message: message,
        success: success,
        icon: icon,
        duration: duration,
        onDismissed: () {
          _current?.remove();
          _current = null;
        },
      ),
    );
    _current = entry;
    overlay.insert(entry);
  }

  static void showSuccess(BuildContext context, String message) => show(
        context,
        message: message,
        success: true,
        icon: Icons.check_circle_rounded,
      );

  static void showError(BuildContext context, String message) => show(
        context,
        message: message,
        success: false,
        icon: Icons.error_outline_rounded,
      );
}

class _SnackOverlay extends StatefulWidget {
  final String message;
  final bool success;
  final IconData? icon;
  final Duration duration;
  final VoidCallback onDismissed;

  const _SnackOverlay({
    required this.message,
    required this.success,
    required this.icon,
    required this.duration,
    required this.onDismissed,
  });

  @override
  State<_SnackOverlay> createState() => _SnackOverlayState();
}

class _SnackOverlayState extends State<_SnackOverlay>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 250),
    reverseDuration: const Duration(milliseconds: 250),
  );

  @override
  void initState() {
    super.initState();
    _controller.forward();
    Future.delayed(widget.duration, () async {
      if (!mounted) return;
      await _controller.reverse();
      if (mounted) widget.onDismissed();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    const softGreen = Color(0xFF81C784);
    const softRed = Color(0xFFF28B82);
    final base = widget.success ? softGreen : softRed;
    final bg = Color.alphaBlend(
      base.withOpacity(isDark ? 0.25 : 0.15),
      theme.cardColor,
    );
    final textColor = theme.textTheme.bodyLarge?.color ?? Colors.black87;

    return Positioned.fill(
      child: IgnorePointer(
        ignoring: true,
        child: SafeArea(
          child: Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(0, 0.2),
                  end: Offset.zero,
                ).animate(CurvedAnimation(
                  parent: _controller,
                  curve: Curves.easeOut,
                  reverseCurve: Curves.easeIn,
                )),
                child: FadeTransition(
                  opacity: _controller,
                  child: Material(
                    color: bg,
                    elevation: 2,
                    borderRadius: BorderRadius.circular(12),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (widget.icon != null)
                            Padding(
                              padding: const EdgeInsets.only(right: 10),
                              child: Icon(widget.icon, color: textColor, size: 20),
                            ),
                          Flexible(
                            child: Text(
                              widget.message,
                              style: TextStyle(
                                color: textColor,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
