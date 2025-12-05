import 'package:flutter/material.dart';

enum SuggestionPriority { low, medium, high }

enum SuggestionType { task, reminder, motivation, warning, tip, celebration }

class MomoSuggestion {
  final String id;
  final String message;
  final String? actionLabel;
  final VoidCallback? onAction;
  final SuggestionPriority priority;
  final SuggestionType type;
  final IconData icon;
  final Color? color;
  final DateTime createdAt;
  bool isDismissed;

  MomoSuggestion({
    required this.id,
    required this.message,
    this.actionLabel,
    this.onAction,
    this.priority = SuggestionPriority.medium,
    this.type = SuggestionType.tip,
    this.icon = Icons.lightbulb_outline,
    this.color,
    DateTime? createdAt,
    this.isDismissed = false,
  }) : createdAt = createdAt ?? DateTime.now();

  Color get displayColor {
    if (color != null) return color!;
    switch (type) {
      case SuggestionType.celebration:
        return Colors.green;
      case SuggestionType.warning:
        return Colors.orange;
      case SuggestionType.task:
        return Colors.blue;
      case SuggestionType.reminder:
        return Colors.purple;
      case SuggestionType.motivation:
        return Colors.amber;
      case SuggestionType.tip:
        return Colors.teal;
    }
  }

  IconData get displayIcon {
    switch (type) {
      case SuggestionType.celebration:
        return Icons.celebration;
      case SuggestionType.warning:
        return Icons.warning_amber;
      case SuggestionType.task:
        return Icons.task_alt;
      case SuggestionType.reminder:
        return Icons.notifications_active;
      case SuggestionType.motivation:
        return Icons.emoji_events;
      case SuggestionType.tip:
        return Icons.lightbulb;
    }
  }
}
