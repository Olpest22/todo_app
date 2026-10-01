import 'package:flutter/material.dart';

import '../models/task.dart';
import '../utils/date_format.dart';
import 'priority_badge.dart';

enum _TaskAction { edit, delete }

/// Карточка задачи: чекбокс выполнения, текст, важность, дата создания
/// и меню действий. Свайп влево удаляет задачу.
class TaskTile extends StatelessWidget {
  const TaskTile({
    super.key,
    required this.task,
    required this.onToggle,
    required this.onEdit,
    required this.onDelete,
  });

  final Task task;
  final VoidCallback onToggle;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  static const _margin = EdgeInsets.symmetric(horizontal: 12, vertical: 4);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Dismissible(
      key: ValueKey('dismiss_${task.id}'),
      direction: DismissDirection.endToStart,
      onDismissed: (_) => onDelete(),
      background: Container(
        margin: _margin,
        padding: const EdgeInsets.symmetric(horizontal: 24),
        alignment: Alignment.centerRight,
        decoration: BoxDecoration(
          color: colors.errorContainer,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(Icons.delete_outline, color: colors.onErrorContainer),
      ),
      child: Card(
        margin: _margin,
        child: ListTile(
          onTap: onEdit,
          leading: Checkbox(
            value: task.isDone,
            onChanged: (_) => onToggle(),
          ),
          title: Text(
            task.title,
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
            style: task.isDone
                ? TextStyle(
                    decoration: TextDecoration.lineThrough,
                    color: colors.onSurfaceVariant,
                  )
                : null,
          ),
          subtitle: Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Row(
              children: [
                PriorityBadge(priority: task.priority),
                const SizedBox(width: 12),
                Icon(Icons.schedule, size: 14, color: colors.onSurfaceVariant),
                const SizedBox(width: 4),
                Flexible(
                  child: Text(
                    formatDateTime(task.createdAt),
                    style: theme.textTheme.bodySmall,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
          trailing: PopupMenuButton<_TaskAction>(
            tooltip: 'Действия',
            onSelected: (action) {
              switch (action) {
                case _TaskAction.edit:
                  onEdit();
                case _TaskAction.delete:
                  onDelete();
              }
            },
            itemBuilder: (_) => const [
              PopupMenuItem(
                value: _TaskAction.edit,
                child: ListTile(
                  leading: Icon(Icons.edit_outlined),
                  title: Text('Изменить'),
                  contentPadding: EdgeInsets.zero,
                ),
              ),
              PopupMenuItem(
                value: _TaskAction.delete,
                child: ListTile(
                  leading: Icon(Icons.delete_outline),
                  title: Text('Удалить'),
                  contentPadding: EdgeInsets.zero,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
