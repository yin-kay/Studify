import '../models/study_task.dart';
import 'hive_service.dart';

class TaskService {
  TaskService(this._hive);
  final HiveService _hive;
  Future<List<StudyTask>> getAll() async {
    final repaired = <StudyTask>[];
    for (final key in _hive.tasks.keys.toList(growable: false)) {
      final task = _hive.tasks.get(key);
      if (task == null) continue;
      if (task.id == StudyTask.recoveredId) {
        final recoveredId = key.toString().trim();
        var safeId =
            recoveredId.isEmpty ? 'recovered-${repaired.length}' : recoveredId;
        if (key != safeId && _hive.tasks.containsKey(safeId)) {
          safeId = 'recovered-${repaired.length}-$safeId';
        }
        final recovered = task.copyWith(id: safeId);
        await _hive.tasks.put(safeId, recovered);
        if (key != safeId) await _hive.tasks.delete(key);
        repaired.add(recovered);
      } else {
        repaired.add(task);
      }
    }
    return List.unmodifiable(repaired);
  }

  Future<StudyTask?> getById(String id) async => _hive.tasks.get(id);
  Future<bool> contains(String id) async => _hive.tasks.containsKey(id);
  Future<void> put(StudyTask task) => _hive.tasks.put(task.id, task);
  Future<void> delete(String id) => _hive.tasks.delete(id);
}
