import 'package:flutter/material.dart';

import '../models/task.dart';
import 'priority_badge.dart';

/// Данные, которые пользователь ввёл в форме.
class TaskDraft {
  const TaskDraft({
    required this.title,
    required this.priority,
    required this.isDone,
  });

  final String title;
  final TaskPriority priority;
  final bool isDone;
}

/// Открывает форму. Если передана [task] — режим редактирования,
/// иначе — создание новой задачи. Возвращает null, если форму закрыли.
Future<TaskDraft?> showTaskEditor(BuildContext context, {Task? task}) {
  return showModalBottomSheet<TaskDraft>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    showDragHandle: true,
    builder: (_) => TaskEditorSheet(task: task),
  );
}

class TaskEditorSheet extends StatefulWidget {
  const TaskEditorSheet({super.key, this.task});

  final Task? task;

  @override
  State<TaskEditorSheet> createState() => _TaskEditorSheetState();
}

class _TaskEditorSheetState extends State<TaskEditorSheet> {
  late final TextEditingController _titleController;
  late TaskPriority _priority;
  late bool _isDone;

  bool get _isEditing => widget.task != null;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.task?.title ?? '');
    _priority = widget.task?.priority ?? TaskPriority.medium;
    _isDone = widget.task?.isDone ?? false;
  }

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  void _submit() {
    final title = _titleController.text.trim();
    if (title.isEmpty) return;

    Navigator.of(context).pop(
      TaskDraft(title: title, priority: _priority, isDone: _isDone),
    );
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final keyboardInset = MediaQuery.viewInsetsOf(context).bottom;

    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(20, 0, 20, 20 + keyboardInset),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            _isEditing ? 'Редактирование задачи' : 'Новая задача',
            style: textTheme.titleLarge,
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _titleController,
            autofocus: true,
            maxLength: 200,
            minLines: 1,
            maxLines: 4,
            textCapitalization: TextCapitalization.sentences,
            textInputAction: TextInputAction.done,
            onSubmitted: (_) => _submit(),
            decoration: const InputDecoration(
              labelText: 'Что нужно сделать?',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 8),
          Text('Важность', style: textTheme.labelLarge),
          const SizedBox(height: 8),
          SegmentedButton<TaskPriority>(
            showSelectedIcon: false,
            segments: [
              for (final priority in TaskPriority.values)
                ButtonSegment(
                  value: priority,
                  label: Text(priority.label),
                  icon: Icon(
                    Icons.flag,
                    color: PriorityBadge.colorOf(priority),
                  ),
                ),
            ],
            selected: {_priority},
            onSelectionChanged: (selection) =>
                setState(() => _priority = selection.first),
          ),
          if (_isEditing)
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Выполнена'),
              value: _isDone,
              onChanged: (value) => setState(() => _isDone = value),
            ),
          const SizedBox(height: 16),
          // Кнопка неактивна, пока текст задачи пустой.
          ValueListenableBuilder<TextEditingValue>(
            valueListenable: _titleController,
            builder: (context, value, _) {
              final canSubmit = value.text.trim().isNotEmpty;
              return FilledButton.icon(
                onPressed: canSubmit ? _submit : null,
                icon: Icon(_isEditing ? Icons.save_outlined : Icons.add),
                label: Text(_isEditing ? 'Сохранить' : 'Добавить'),
              );
            },
          ),
        ],
      ),
    );
  }
}
