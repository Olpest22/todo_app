import 'package:flutter_test/flutter_test.dart';
import 'package:todo_app/controllers/task_controller.dart';
import 'package:todo_app/models/task.dart';
import 'package:todo_app/services/task_storage.dart';

/// Хранилище в памяти, чтобы тесты не зависели от устройства.
class InMemoryTaskStorage implements TaskStorage {
  List<Task> saved = [];

  @override
  Future<List<Task>> load() async => List.of(saved);

  @override
  Future<void> save(List<Task> tasks) async => saved = List.of(tasks);
}

void main() {
  late InMemoryTaskStorage storage;
  late TaskController controller;

  setUp(() async {
    storage = InMemoryTaskStorage();
    controller = TaskController(storage);
    await controller.load();
  });

  test('добавление задачи сохраняет её в хранилище', () async {
    controller.add('  Купить молоко  ', TaskPriority.medium);
    await Future<void>.delayed(Duration.zero);

    expect(controller.visibleTasks.single.title, 'Купить молоко');
    expect(storage.saved, hasLength(1));
  });

  test('пустая задача не добавляется', () {
    controller.add('   ', TaskPriority.low);
    expect(controller.totalCount, 0);
  });

  test('фильтрация по статусу', () {
    controller.add('A', TaskPriority.low);
    controller.add('B', TaskPriority.low);
    final taskA = controller.visibleTasks.firstWhere((t) => t.title == 'A');
    controller.toggleDone(taskA.id);

    controller.setFilter(TaskFilter.active);
    expect(controller.visibleTasks.map((t) => t.title), ['B']);

    controller.setFilter(TaskFilter.done);
    expect(controller.visibleTasks.map((t) => t.title), ['A']);
  });

  test('сортировка по важности', () {
    controller.add('Низкая', TaskPriority.low);
    controller.add('Высокая', TaskPriority.high);
    controller.add('Средняя', TaskPriority.medium);

    controller.setSortOption(SortOption.priority);
    expect(
      controller.visibleTasks.map((t) => t.title),
      ['Высокая', 'Средняя', 'Низкая'],
    );
  });

  test('редактирование задачи', () {
    controller.add('Старый текст', TaskPriority.low);
    final task = controller.visibleTasks.single;

    controller.updateTask(task.copyWith(title: 'Новый текст', isDone: true));

    final updated = controller.visibleTasks.single;
    expect(updated.title, 'Новый текст');
    expect(updated.isDone, isTrue);
  });

  test('удаление и отмена удаления', () {
    controller.add('Задача', TaskPriority.high);
    final task = controller.visibleTasks.single;

    final index = controller.delete(task.id);
    expect(controller.totalCount, 0);

    controller.restore(task, index);
    expect(controller.visibleTasks.single.id, task.id);
  });
}
