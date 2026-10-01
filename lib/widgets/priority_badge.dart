import 'package:flutter/material.dart';

import '../models/task.dart';

/// Небольшой значок с флажком и подписью важности задачи.
class PriorityBadge extends StatelessWidget {
  const PriorityBadge({super.key, required this.priority});

  final TaskPriority priority;

  static Color colorOf(TaskPriority priority) {
    switch (priority) {
      case TaskPriority.low:
        return Colors.green;
      case TaskPriority.medium:
        return Colors.orange;
      case TaskPriority.high:
        return Colors.red;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(Icons.flag, size: 14, color: colorOf(priority)),
        const SizedBox(width: 4),
        Text(priority.label, style: Theme.of(context).textTheme.bodySmall),
      ],
    );
  }
}
