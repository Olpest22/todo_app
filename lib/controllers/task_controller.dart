import 'dart:async';

import 'package:flutter/foundation.dart';

import '../models/task.dart';
import '../services/task_storage.dart';

/// Критерии сортировки списка задач.
enum SortOption {
  newest('Сначала новые'),
  oldest('Сначала старые'),
  priority('По важности'),
  alphabetical('По алфавиту');

  const SortOption(this.label);

  final String label;
}

/// Фильтр задач по статусу.
enum TaskFilter {
  all('Все'),
  active('Активные'),
  done('Готово');

  const TaskFilter(this.label);

  final String label;
}

/// Хранит состояние приложения и бизнес-логику работы со списком задач.
/// Виджеты подписываются на изменения через ListenableBuilder.
class TaskController extends ChangeNotifier {
  TaskController(this._storage);

  final TaskStorage _storage;

  List<Task> _tasks = [];
  List<Task> _visibleTasks = const [];
  SortOption _sortOption = SortOption.newest;
  TaskFilter _filter = TaskFilter.all;
  bool _isLoading = true;
  int _idCounter = 0;

  /// Отфильтрованный и отсортированный список. Пересчитывается только
  /// при изменении данных, а не при каждой перерисовке экрана.
  List<Task> get visibleTasks => _visibleTasks;
  SortOption get sortOption => _sortOption;
  TaskFilter get filter => _filter;
  bool get isLoading => _isLoading;

  int get totalCount => _tasks.length;
  int get doneCount => _tasks.where((t) => t.isDone).length;
  int get activeCount => totalCount - doneCount;

  Future<void> load() async {
    _tasks = List.of(await _storage.load());
    _isLoading = false;
    _refresh(persist: false);
  }

  void add(String title, TaskPriority priority) {
    final trimmed = title.trim();
    if (trimmed.isEmpty) return;

    _tasks.add(Task(
      id: '${DateTime.now().microsecondsSinceEpoch}_${_idCounter++}',
      title: trimmed,
      createdAt: DateTime.now(),
      priority: priority,
    ));
    _refresh();
  }

  void updateTask(Task updated) {
    final index = _indexOf(updated.id);
    if (index == -1 || updated.title.trim().isEmpty) return;

    _tasks[index] = updated.copyWith(title: updated.title.trim());
    _refresh();
  }

  void toggleDone(String id) {
    final index = _indexOf(id);
    if (index == -1) return;

    _tasks[index] = _tasks[index].copyWith(isDone: !_tasks[index].isDone);
    _refresh();
  }

  /// Удаляет задачу и возвращает её позицию (нужна для отмены удаления).
  int delete(String id) {
    final index = _indexOf(id);
    if (index == -1) return -1;

    _tasks.removeAt(index);
    _refresh();
    return index;
  }

  /// Возвращает удалённую задачу на прежнее место.
  void restore(Task task, int index) {
    if (_indexOf(task.id) != -1) return;

    final safeIndex =
        (index < 0 || index > _tasks.length) ? _tasks.length : index;
    _tasks.insert(safeIndex, task);
    _refresh();
  }

  void setSortOption(SortOption option) {
    if (option == _sortOption) return;
    _sortOption = option;
    _refresh(persist: false);
  }

  void setFilter(TaskFilter filter) {
    if (filter == _filter) return;
    _filter = filter;
    _refresh(persist: false);
  }

  int _indexOf(String id) => _tasks.indexWhere((t) => t.id == id);

  void _refresh({bool persist = true}) {
    _visibleTasks = List.unmodifiable(
      _tasks.where(_matchesFilter).toList()..sort(_compare),
    );
    notifyListeners();
    if (persist) {
      unawaited(_storage.save(List.unmodifiable(_tasks)));
    }
  }

  bool _matchesFilter(Task task) {
    switch (_filter) {
      case TaskFilter.all:
        return true;
      case TaskFilter.active:
        return !task.isDone;
      case TaskFilter.done:
        return task.isDone;
    }
  }

  int _compare(Task a, Task b) {
    switch (_sortOption) {
      case SortOption.newest:
        return b.createdAt.compareTo(a.createdAt);
      case SortOption.oldest:
        return a.createdAt.compareTo(b.createdAt);
      case SortOption.priority:
        final byPriority = b.priority.index.compareTo(a.priority.index);
        return byPriority != 0
            ? byPriority
            : b.createdAt.compareTo(a.createdAt);
      case SortOption.alphabetical:
        return a.title.toLowerCase().compareTo(b.title.toLowerCase());
    }
  }
}
