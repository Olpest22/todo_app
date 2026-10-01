import 'package:flutter/material.dart';

import '../controllers/task_controller.dart';
import '../models/task.dart';
import '../widgets/empty_state.dart';
import '../widgets/task_editor_sheet.dart';
import '../widgets/task_tile.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key, required this.controller});

  final TaskController controller;

  Future<void> _addTask(BuildContext context) async {
    final draft = await showTaskEditor(context);
    if (draft == null) return;
    controller.add(draft.title, draft.priority);
  }

  Future<void> _editTask(BuildContext context, Task task) async {
    final draft = await showTaskEditor(context, task: task);
    if (draft == null) return;
    controller.updateTask(task.copyWith(
      title: draft.title,
      priority: draft.priority,
      isDone: draft.isDone,
    ));
  }

  void _deleteTask(BuildContext context, Task task) {
    final index = controller.delete(task.id);
    if (index == -1) return;

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text('Задача «${task.title}» удалена'),
          behavior: SnackBarBehavior.floating,
          action: SnackBarAction(
            label: 'Отменить',
            onPressed: () => controller.restore(task, index),
          ),
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Список дел'),
        actions: [
          PopupMenuButton<SortOption>(
            icon: const Icon(Icons.sort),
            tooltip: 'Сортировка',
            onSelected: controller.setSortOption,
            itemBuilder: (_) => [
              for (final option in SortOption.values)
                CheckedPopupMenuItem(
                  value: option,
                  checked: option == controller.sortOption,
                  child: Text(option.label),
                ),
            ],
          ),
        ],
      ),
      // Перерисовывается только тело экрана, а не весь Scaffold.
      body: ListenableBuilder(
        listenable: controller,
        builder: (context, _) {
          if (controller.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          return Column(
            children: [
              _FilterBar(controller: controller),
              Expanded(child: _buildTaskList(context)),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _addTask(context),
        icon: const Icon(Icons.add),
        label: const Text('Новая задача'),
      ),
    );
  }

  Widget _buildTaskList(BuildContext context) {
    final tasks = controller.visibleTasks;
    if (tasks.isEmpty) {
      return EmptyState(filter: controller.filter);
    }

    // ListView.builder строит только видимые элементы, поэтому
    // список остаётся плавным даже при большом количестве задач.
    return ListView.builder(
      padding: const EdgeInsets.only(top: 4, bottom: 96),
      itemCount: tasks.length,
      itemBuilder: (context, index) {
        final task = tasks[index];
        return TaskTile(
          key: ValueKey(task.id),
          task: task,
          onToggle: () => controller.toggleDone(task.id),
          onEdit: () => _editTask(context, task),
          onDelete: () => _deleteTask(context, task),
        );
      },
    );
  }
}

/// Панель фильтров по статусу с количеством задач и текущей сортировкой.
class _FilterBar extends StatelessWidget {
  const _FilterBar({required this.controller});

  final TaskController controller;

  int _countFor(TaskFilter filter) {
    switch (filter) {
      case TaskFilter.all:
        return controller.totalCount;
      case TaskFilter.active:
        return controller.activeCount;
      case TaskFilter.done:
        return controller.doneCount;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SegmentedButton<TaskFilter>(
            showSelectedIcon: false,
            segments: [
              for (final filter in TaskFilter.values)
                ButtonSegment(
                  value: filter,
                  label: Text('${filter.label} · ${_countFor(filter)}'),
                ),
            ],
            selected: {controller.filter},
            onSelectionChanged: (selection) =>
                controller.setFilter(selection.first),
          ),
          const SizedBox(height: 8),
          Text(
            'Сортировка: ${controller.sortOption.label.toLowerCase()}',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}
