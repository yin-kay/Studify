import 'package:flutter/foundation.dart';
import '../errors/app_exceptions.dart';
import '../models/study_task.dart';
import '../repositories/task_repository.dart';
import '../utils/date_time_utils.dart';

class TaskProvider extends ChangeNotifier {
  TaskProvider(this._repository);
  final TaskRepository _repository;
  List<StudyTask> _tasks = [];
  bool _loading = false, _saving = false, _disposed = false;
  final Set<String> _deleting = {};
  String? _error;
  List<StudyTask> get tasks => List.unmodifiable(_tasks);
  bool get isLoading => _loading;
  bool get isSaving => _saving;
  String? get errorMessage => _error;
  List<StudyTask> get dueTodayTasks {
    final now = DateTime.now();
    return List.unmodifiable(_tasks.where(
        (t) => t.status != TaskStatus.done && isSameDate(t.dueDateTime, now)));
  }

  List<StudyTask> get overdueTasks {
    final now = DateTime.now();
    return List.unmodifiable(_tasks.where(
        (t) => t.status != TaskStatus.done && t.dueDateTime.isBefore(now)));
  }

  List<StudyTask> get upcomingTasks {
    final now = DateTime.now(), end = now.add(const Duration(days: 7));
    return List.unmodifiable(_tasks.where((t) =>
        t.status != TaskStatus.done &&
        t.dueDateTime.isAfter(now) &&
        !t.dueDateTime.isAfter(end)));
  }

  List<StudyTask> get completedThisWeekTasks {
    final start = startOfWeek(DateTime.now()),
        end = start.add(const Duration(days: 7));
    return List.unmodifiable(_tasks.where((t) =>
        t.completedAt != null &&
        !t.completedAt!.isBefore(start) &&
        t.completedAt!.isBefore(end)));
  }

  int get dueTodayCount => dueTodayTasks.length;
  int get overdueCount => overdueTasks.length;
  int get completedThisWeekCount => completedThisWeekTasks.length;
  Future<void> loadTasks() async {
    _loading = true;
    _error = null;
    _notify();
    try {
      _tasks = [...await _repository.getAllTasks()];
    } catch (_) {
      _error = 'Tasks could not be loaded. Please try again.';
    } finally {
      _loading = false;
      _notify();
    }
  }

  Future<bool> addTask(
          {required String title,
          String? subjectId,
          String description = '',
          required DateTime dueDateTime,
          TaskPriority priority = TaskPriority.medium,
          TaskStatus status = TaskStatus.toDo,
          String category = ''}) async =>
      _guard(() async {
        final saved = await _repository.addTask(StudyTask(
            title: title,
            subjectId: subjectId,
            description: description,
            dueDateTime: dueDateTime,
            priority: priority,
            status: status,
            category: category));
        _tasks.add(saved);
      });
  Future<bool> updateTask(StudyTask task) async => _guard(() async {
        final saved = await _repository.updateTask(task);
        final index = _tasks.indexWhere((t) => t.id == saved.id);
        if (index < 0) throw const TaskNotFoundException();
        _tasks[index] = saved;
      });
  Future<bool> deleteTask(String id) async {
    if (_deleting.contains(id)) return false;
    _deleting.add(id);
    _error = null;
    try {
      await _repository.deleteTask(id);
      _tasks.removeWhere((t) => t.id == id);
      _notify();
      return true;
    } catch (e) {
      _error = _message(e);
      _notify();
      return false;
    } finally {
      _deleting.remove(id);
    }
  }

  Future<bool> markCompleted(String id) async =>
      _changeStatus(id, TaskStatus.done);
  Future<bool> updateStatus(String id, TaskStatus status) async =>
      _changeStatus(id, status);
  Future<bool> _changeStatus(String id, TaskStatus status) async =>
      _guard(() async {
        final saved = await _repository.updateTaskStatus(id, status);
        final i = _tasks.indexWhere((t) => t.id == id);
        if (i < 0) throw const TaskNotFoundException();
        _tasks[i] = saved;
      });
  Future<bool> _guard(Future<void> Function() action) async {
    if (_saving) return false;
    _saving = true;
    _error = null;
    _notify();
    try {
      await action();
      return true;
    } catch (e) {
      _error = _message(e);
      return false;
    } finally {
      _saving = false;
      _notify();
    }
  }

  String _message(Object e) {
    if (e is ValidationException || e is AppDatabaseException) {
      return e.toString();
    }
    if (e is TaskNotFoundException) return 'This task no longer exists.';
    return 'The task operation could not be completed.';
  }

  void _notify() {
    if (!_disposed) notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }
}
