import 'package:uuid/uuid.dart';
import '../errors/app_exceptions.dart';
import '../models/study_task.dart';
import '../services/task_service.dart';
import '../utils/date_time_utils.dart';
import '../utils/validators.dart';

class TaskRepository {
  TaskRepository(this._service, {Uuid? uuid}) : _uuid = uuid ?? const Uuid();
  final TaskService _service;
  final Uuid _uuid;
  Future<List<StudyTask>> getAllTasks() => _service.getAll();
  Future<StudyTask?> getTaskById(String id) => _service.getById(id);

  Future<StudyTask> addTask(StudyTask task) async {
    final id = task.id.trim().isEmpty ? _uuid.v4() : task.id.trim();
    if (await _service.contains(id)) {
      throw const ValidationException('A task with this ID already exists.');
    }
    final now = DateTime.now();
    final saved = _validated(task.copyWith(
        id: id,
        createdAt: now,
        updatedAt: now,
        completed: task.status == TaskStatus.done,
        completedAt:
            task.status == TaskStatus.done ? task.completedAt ?? now : null,
        clearCompletedAt: task.status != TaskStatus.done));
    await _write(() => _service.put(saved));
    return saved;
  }

  Future<StudyTask> updateTask(StudyTask task) async {
    final original = await _service.getById(task.id);
    if (original == null) throw const TaskNotFoundException();
    final done = task.status == TaskStatus.done;
    final saved = _validated(task.copyWith(
        createdAt: original.createdAt,
        updatedAt: DateTime.now(),
        completed: done,
        completedAt: done ? task.completedAt ?? DateTime.now() : null,
        clearCompletedAt: !done));
    await _write(() => _service.put(saved));
    return saved;
  }

  Future<void> deleteTask(String id) async {
    if (!await _service.contains(id)) throw const TaskNotFoundException();
    await _write(() => _service.delete(id));
  }

  Future<StudyTask> markTaskCompleted(String id) =>
      updateTaskStatus(id, TaskStatus.done);
  Future<StudyTask> updateTaskStatus(String id, TaskStatus status) async {
    final task = await _service.getById(id);
    if (task == null) throw const TaskNotFoundException();
    return updateTask(task.copyWith(status: status));
  }

  Future<List<StudyTask>> byStatus(TaskStatus value) async =>
      List.unmodifiable((await getAllTasks()).where((t) => t.status == value));
  Future<List<StudyTask>> bySubject(String id) async =>
      List.unmodifiable((await getAllTasks()).where((t) => t.subjectId == id));
  Future<List<StudyTask>> byDate(DateTime date) async => List.unmodifiable(
      (await getAllTasks()).where((t) => isSameDate(t.dueDateTime, date)));
  Future<List<StudyTask>> dueToday({DateTime? now}) async {
    final n = now ?? DateTime.now();
    return List.unmodifiable((await getAllTasks()).where(
        (t) => t.status != TaskStatus.done && isSameDate(t.dueDateTime, n)));
  }

  Future<List<StudyTask>> overdue({DateTime? now}) async {
    final n = now ?? DateTime.now();
    return List.unmodifiable((await getAllTasks()).where(
        (t) => t.status != TaskStatus.done && t.dueDateTime.isBefore(n)));
  }

  Future<List<StudyTask>> upcoming({DateTime? now}) async {
    final n = now ?? DateTime.now(), end = n.add(const Duration(days: 7));
    return List.unmodifiable((await getAllTasks()).where((t) =>
        t.status != TaskStatus.done &&
        t.dueDateTime.isAfter(n) &&
        !t.dueDateTime.isAfter(end)));
  }

  Future<List<StudyTask>> completedThisWeek({DateTime? now}) async {
    final start = startOfWeek(now ?? DateTime.now()),
        end = start.add(const Duration(days: 7));
    return List.unmodifiable((await getAllTasks()).where((t) =>
        t.completedAt != null &&
        !t.completedAt!.isBefore(start) &&
        t.completedAt!.isBefore(end)));
  }

  Future<List<StudyTask>> sortedByDueDate() async {
    final list = [...await getAllTasks()];
    list.sort((a, b) => a.dueDateTime.compareTo(b.dueDateTime));
    return List.unmodifiable(list);
  }

  Future<List<StudyTask>> sortedByPriority() async {
    final list = [...await getAllTasks()];
    list.sort((a, b) {
      final p =
          priorityWeight(b.priority).compareTo(priorityWeight(a.priority));
      return p != 0 ? p : a.dueDateTime.compareTo(b.dueDateTime);
    });
    return List.unmodifiable(list);
  }

  StudyTask _validated(StudyTask task) {
    if (task.id.trim().isEmpty) {
      throw const ValidationException('Task ID is required.');
    }
    return task.copyWith(
        title: Validators.taskTitle(task.title),
        description: Validators.description(task.description));
  }

  Future<void> _write(Future<void> Function() operation) async {
    try {
      await operation();
    } catch (error) {
      if (error is ValidationException || error is TaskNotFoundException) {
        rethrow;
      }
      throw const AppDatabaseException(
          'The task could not be saved to local storage.');
    }
  }
}
