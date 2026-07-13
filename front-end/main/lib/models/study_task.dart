enum TaskPriority { high, medium, low }

enum TaskStatus { toDo, inProgress, done }

class StudyTask {
  StudyTask({
    required this.title,
    required this.course,
    required this.due,
    required this.category,
    required this.priority,
    required this.dueDate,
    this.description = '',
    this.status = TaskStatus.toDo,
    this.completed = false,
  });

  final String title;
  final String course;
  final String due;
  final String category;
  final TaskPriority priority;
  final DateTime dueDate;
  final String description;
  TaskStatus status;
  bool completed;
}
