import 'package:uuid/uuid.dart';
import '../errors/app_exceptions.dart';
import '../models/subject.dart';
import '../services/subject_service.dart';
import '../services/task_service.dart';
import '../utils/validators.dart';

class SubjectRepository {
  SubjectRepository(this._subjects, this._tasks, {Uuid? uuid})
      : _uuid = uuid ?? const Uuid();
  final SubjectService _subjects;
  final TaskService _tasks;
  final Uuid _uuid;
  Future<List<Subject>> getAllSubjects() => _subjects.getAll();
  Future<Subject?> getSubjectById(String id) => _subjects.getById(id);
  Future<Subject> addSubject(Subject value) async {
    final name = Validators.subjectName(value.name);
    await _ensureUnique(name);
    final id = value.id.trim().isEmpty ? _uuid.v4() : value.id.trim();
    if (await _subjects.contains(id))
      throw const DuplicateSubjectException(
          'A subject with this ID already exists.');
    final now = DateTime.now();
    final saved =
        value.copyWith(id: id, name: name, createdAt: now, updatedAt: now);
    await _subjects.put(saved);
    return saved;
  }

  Future<Subject> updateSubject(Subject value) async {
    final original = await _subjects.getById(value.id);
    if (original == null) throw const SubjectNotFoundException();
    final name = Validators.subjectName(value.name);
    await _ensureUnique(name, exceptId: value.id);
    final saved = value.copyWith(
        name: name, createdAt: original.createdAt, updatedAt: DateTime.now());
    await _subjects.put(saved);
    if (original.name != saved.name) {
      for (final task in await _tasks.getAll()) {
        if (task.subjectId == original.name) {
          await _tasks.put(
              task.copyWith(subjectId: saved.name, updatedAt: DateTime.now()));
        }
      }
    }
    return saved;
  }

  Future<void> deleteSubject(String id) async {
    if (!await _subjects.contains(id)) throw const SubjectNotFoundException();
    final subject = await _subjects.getById(id);
    final affected = (await _tasks.getAll())
        .where(
            (task) => task.subjectId == id || task.subjectId == subject?.name)
        .toList();
    try {
      for (final task in affected) {
        await _tasks
            .put(task.copyWith(clearSubject: true, updatedAt: DateTime.now()));
      }
      await _subjects.delete(id);
    } catch (_) {
      for (final task in affected) {
        await _tasks.put(task);
      }
      throw const AppDatabaseException(
          'The subject could not be deleted safely.');
    }
  }

  Future<void> _ensureUnique(String name, {String? exceptId}) async {
    final duplicate = (await _subjects.getAll()).any(
        (s) => s.id != exceptId && s.name.toLowerCase() == name.toLowerCase());
    if (duplicate)
      throw const DuplicateSubjectException(
          'A subject with this name already exists.');
  }
}
