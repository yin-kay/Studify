import '../models/subject.dart';
import 'hive_service.dart';

class SubjectService {
  SubjectService(this._hive);
  final HiveService _hive;
  Future<List<Subject>> getAll() async =>
      List.unmodifiable(_hive.subjects.values);
  Future<Subject?> getById(String id) async => _hive.subjects.get(id);
  Future<bool> contains(String id) async => _hive.subjects.containsKey(id);
  Future<void> put(Subject subject) => _hive.subjects.put(subject.id, subject);
  Future<void> delete(String id) => _hive.subjects.delete(id);
}
