import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../../features/calendar/data/models/event.dart';
import '../../features/resources/data/models/resource.dart';

class AppColorUtils {
  /// Get color for event type
  static Color getEventColor(EventType type) {
    switch (type) {
      case EventType.course:
        return AppTheme.classTeal;
      case EventType.exam:
        return AppTheme.primaryIndigo;
      case EventType.assignment:
        return AppTheme.assignmentOrange;
    }
  }

  /// Get icon for event type
  static IconData getEventIcon(EventType type) {
    switch (type) {
      case EventType.course:
        return Icons.school;
      case EventType.exam:
        return Icons.assignment_turned_in;
      case EventType.assignment:
        return Icons.assignment;
    }
  }

  /// Get color for resource type
  static Color getResourceColor(ResourceType type) {
    switch (type) {
      case ResourceType.telegram:
        return Colors.blue;
      case ResourceType.website:
        return AppTheme.primaryTeal;
      case ResourceType.submission:
        return AppTheme.assignmentOrange;
      case ResourceType.video:
        return Colors.red;
      case ResourceType.document:
        return Colors.orange;
      case ResourceType.code:
        return Colors.green;
      case ResourceType.communication:
        return Colors.purple;
      case ResourceType.whatsapp:
        return Colors.green;
      case ResourceType.sharedDrive:
        return Colors.indigo;
    }
  }

  /// Get icon for resource type
  static IconData getResourceIcon(ResourceType type) {
    switch (type) {
      case ResourceType.telegram:
        return Icons.telegram;
      case ResourceType.website:
        return Icons.language;
      case ResourceType.submission:
        return Icons.assignment_turned_in;
      case ResourceType.video:
        return Icons.video_library;
      case ResourceType.document:
        return Icons.description;
      case ResourceType.code:
        return Icons.code;
      case ResourceType.communication:
        return Icons.chat;
      case ResourceType.whatsapp:
        return Icons.chat_bubble;
      case ResourceType.sharedDrive:
        return Icons.cloud;
    }
  }

  /// Get label for resource type
  static String getResourceLabel(ResourceType type) {
    switch (type) {
      case ResourceType.telegram:
        return 'Telegram Group';
      case ResourceType.website:
        return 'Website';
      case ResourceType.submission:
        return 'Assignment Platform';
      case ResourceType.video:
        return 'Video Content';
      case ResourceType.document:
        return 'Document';
      case ResourceType.code:
        return 'Code Repository';
      case ResourceType.communication:
        return 'Communication';
      case ResourceType.whatsapp:
        return 'WhatsApp Group';
      case ResourceType.sharedDrive:
        return 'Shared Drive';
    }
  }

  /// Parse ResourceType from string
  static ResourceType parseResourceType(String type) {
    return ResourceType.values.firstWhere(
      (value) => value.name.toLowerCase() == type.toLowerCase(),
      orElse: () => ResourceType.website,
    );
  }

  /// Get text color based on background brightness
  static Color getTextColor(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? Colors.white
        : AppTheme.textPrimary;
  }

  /// Get secondary text color based on background brightness
  static Color getSecondaryTextColor(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? Colors.white70
        : AppTheme.textSecondary;
  }
}
