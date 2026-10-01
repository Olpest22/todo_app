/// Важность задачи. Порядок значений важен: чем выше индекс, тем важнее задача.
enum TaskPriority {
  low('Низкая'),
  medium('Средняя'),
  high('Высокая');

  const TaskPriority(this.label);

  final String label;
}

/// Модель задачи. Неизменяемая: любые изменения делаются через [copyWith].
class Task {
  const Task({
    required this.id,
    required this.title,
    required this.createdAt,
    this.priority = TaskPriority.medium,
    this.isDone = false,
  });

  final String id;
  final String title;
  final DateTime createdAt;
  final TaskPriority priority;
  final bool isDone;

  Task copyWith({String? title, TaskPriority? priority, bool? isDone}) {
    return Task(
      id: id,
      title: title ?? this.title,
      createdAt: createdAt,
      priority: priority ?? this.priority,
      isDone: isDone ?? this.isDone,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'createdAt': createdAt.toIso8601String(),
        'priority': priority.name,
        'isDone': isDone,
      };

  factory Task.fromJson(Map<String, dynamic> json) {
    final priorityName = json['priority'] as String?;
    return Task(
      id: json['id'] as String,
      title: json['title'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      priority: TaskPriority.values.firstWhere(
        (p) => p.name == priorityName,
        orElse: () => TaskPriority.medium,
      ),
      isDone: json['isDone'] as bool? ?? false,
    );
  }
}
