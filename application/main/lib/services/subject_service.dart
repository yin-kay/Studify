import '../models/subject.dart';
import 'hive_service.dart';

class SubjectService {
  SubjectService(this._hive);
  final HiveService _hive;
  Future<List<Subject>> getAll() async {
    final repaired = <Subject>[];
    for (final key in _hive.subjects.keys.toList(growable: false)) {
      final subject = _hive.subjects.get(key);
      if (subject == null) continue;
      if (subject.id == Subject.recoveredId) {
        final recoveredKey = key.toString().trim();
        var safeId = recoveredKey.isEmpty
            ? 'recovered-subject-${repaired.length}'
            : recoveredKey;
        if (key != safeId && _hive.subjects.containsKey(safeId)) {
          safeId = 'recovered-subject-${repaired.length}-$safeId';
        }
        final recovered = subject.copyWith(id: safeId);
        await _hive.subjects.put(safeId, recovered);
        if (key != safeId) await _hive.subjects.delete(key);
        repaired.add(recovered);
      } else {
        repaired.add(subject);
      }
    }
    return List.unmodifiable(repaired);
  }

  Future<Subject?> getById(String id) async => _hive.subjects.get(id);
  Future<bool> contains(String id) async => _hive.subjects.containsKey(id);
  Future<void> put(Subject subject) => _hive.subjects.put(subject.id, subject);
  Future<void> delete(String id) => _hive.subjects.delete(id);
}
