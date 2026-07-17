import '../models/study_task.dart';
import 'hive_service.dart';

class TaskService {
  TaskService(this._hive);
  final HiveService _hive;
  Future<List<StudyTask>> getAll() async =>
      List.unmodifiable(_hive.tasks.values);
  Future<StudyTask?> getById(String id) async => _hive.tasks.get(id);
  Future<bool> contains(String id) async => _hive.tasks.containsKey(id);
  Future<void> put(StudyTask task) => _hive.tasks.put(task.id, task);
  Future<void> delete(String id) => _hive.tasks.delete(id);
}
