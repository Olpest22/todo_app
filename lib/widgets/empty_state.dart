import 'package:flutter/material.dart';

import '../controllers/task_controller.dart';

/// Подсказка, которая показывается, когда в выбранном фильтре нет задач.
class EmptyState extends StatelessWidget {
  const EmptyState({super.key, required this.filter});

  final TaskFilter filter;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final (icon, title, subtitle) = switch (filter) {
      TaskFilter.all => (
          Icons.checklist_rtl,
          'Задач пока нет',
          'Нажмите «Новая задача», чтобы добавить первую.',
        ),
      TaskFilter.active => (
          Icons.celebration_outlined,
          'Все задачи выполнены',
          'Активных задач нет. Можно отдохнуть!',
        ),
      TaskFilter.done => (
          Icons.hourglass_empty,
          'Нет выполненных задач',
          'Отмечайте задачи галочкой, и они появятся здесь.',
        ),
    };

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 72, color: theme.colorScheme.outline),
            const SizedBox(height: 16),
            Text(title, style: theme.textTheme.titleMedium),
            const SizedBox(height: 8),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
