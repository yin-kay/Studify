import 'package:flutter/foundation.dart';
import '../errors/app_exceptions.dart';
import '../models/subject.dart';
import '../repositories/subject_repository.dart';

class SubjectProvider extends ChangeNotifier {
  SubjectProvider(this._repository, {this.onSubjectsChanged});
  final SubjectRepository _repository;
  final Future<void> Function()? onSubjectsChanged;
  List<Subject> _subjects = [];
  bool _loading = false, _saving = false;
  String? _error;
  List<Subject> get subjects => List.unmodifiable(_subjects);
  bool get isLoading => _loading;
  String? get errorMessage => _error;
  Subject? findById(String? id) {
    if (id == null) return null;
    for (final s in _subjects) {
      if (s.id == id) return s;
    }
    return null;
  }

  Future<void> loadSubjects() async {
    _loading = true;
    notifyListeners();
    try {
      _subjects = [...await _repository.getAllSubjects()];
      _error = null;
    } catch (_) {
      _error = 'Subjects could not be loaded.';
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<bool> addSubject(
          {required String name, int colorValue = 0xFF5B5CE2}) =>
      _guard(() async {
        final now = DateTime.now();
        final saved = await _repository.addSubject(Subject(
            id: '',
            name: name,
            colorValue: colorValue,
            createdAt: now,
            updatedAt: now));
        _subjects.add(saved);
      });
  Future<bool> updateSubject(Subject subject) => _guard(() async {
        final saved = await _repository.updateSubject(subject);
        final i = _subjects.indexWhere((s) => s.id == saved.id);
        if (i < 0) throw const SubjectNotFoundException();
        _subjects[i] = saved;
      });
  Future<bool> deleteSubject(String id) => _guard(() async {
        await _repository.deleteSubject(id);
        _subjects.removeWhere((s) => s.id == id);
        await onSubjectsChanged?.call();
      });
  Future<bool> _guard(Future<void> Function() action) async {
    if (_saving) return false;
    _saving = true;
    _error = null;
    notifyListeners();
    try {
      await action();
      return true;
    } catch (e) {
      _error = e is DuplicateSubjectException ||
              e is ValidationException ||
              e is AppDatabaseException
          ? e.toString()
          : e is SubjectNotFoundException
              ? 'This subject no longer exists.'
              : 'The subject operation could not be completed.';
      return false;
    } finally {
      _saving = false;
      notifyListeners();
    }
  }
}
