import 'package:hive_flutter/hive_flutter.dart';
import '../models/study_task.dart';
import '../models/subject.dart';

class HiveBoxNames {
  static const tasks = 'tasks';
  static const subjects = 'subjects';
  static const settings = 'settings';
  const HiveBoxNames._();
}

class HiveService {
  bool _initialized = false;
  Future<void> initialize({String? testPath}) async {
    if (_initialized) return;
    if (testPath == null) {
      await Hive.initFlutter();
    } else {
      Hive.init(testPath);
    }
    if (!Hive.isAdapterRegistered(0)) Hive.registerAdapter(StudyTaskAdapter());
    if (!Hive.isAdapterRegistered(1)) Hive.registerAdapter(SubjectAdapter());
    await Future.wait([
      Hive.openBox<StudyTask>(HiveBoxNames.tasks),
      Hive.openBox<Subject>(HiveBoxNames.subjects),
      Hive.openBox<dynamic>(HiveBoxNames.settings),
    ]);
    _initialized = true;
  }

  Box<StudyTask> get tasks => _box<StudyTask>(HiveBoxNames.tasks);
  Box<Subject> get subjects => _box<Subject>(HiveBoxNames.subjects);
  Box<dynamic> get settings => _box<dynamic>(HiveBoxNames.settings);
  Box<T> _box<T>(String name) {
    if (!_initialized || !Hive.isBoxOpen(name)) {
      throw StateError('Local storage is not initialized.');
    }
    return Hive.box<T>(name);
  }

  Future<void> close() async {
    await Hive.close();
    _initialized = false;
  }
}
