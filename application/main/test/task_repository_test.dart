import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:main/errors/app_exceptions.dart';
import 'package:main/models/study_task.dart';
import 'package:main/repositories/task_repository.dart';
import 'package:main/services/hive_service.dart';
import 'package:main/services/task_service.dart';

void main() {
  late Directory directory;
  late HiveService hive;
  late TaskRepository repository;
  setUp(() async {
    directory = await Directory.systemTemp.createTemp('studyflow_test_');
    hive = HiveService();
    await hive.initialize(testPath: directory.path);
    repository = TaskRepository(TaskService(hive));
  });
  tearDown(() async {
    await hive.close();
    await directory.delete(recursive: true);
  });
  StudyTask task({String title = 'Assignment', DateTime? due}) => StudyTask(
      title: title,
      dueDateTime: due ?? DateTime.now().add(const Duration(hours: 1)));

  test('adds and persists a valid task', () async {
    final saved = await repository.addTask(task());
    expect(saved.id, isNotEmpty);
    expect((await repository.getAllTasks()).single.title, 'Assignment');
  });
  test('rejects invalid titles and duplicate IDs', () async {
    expect(() => repository.addTask(task(title: ' ')),
        throwsA(isA<ValidationException>()));
    final saved = await repository.addTask(task());
    expect(
        () => repository.addTask(saved), throwsA(isA<ValidationException>()));
  });
  test('updates while preserving createdAt and setting updatedAt', () async {
    final saved = await repository.addTask(task());
    await Future<void>.delayed(const Duration(milliseconds: 2));
    final updated =
        await repository.updateTask(saved.copyWith(title: 'Changed'));
    expect(updated.createdAt, saved.createdAt);
    expect(updated.updatedAt.isAfter(saved.updatedAt), isTrue);
  });
  test('completion sets and reopening clears completedAt', () async {
    final saved = await repository.addTask(task());
    final done = await repository.markTaskCompleted(saved.id);
    expect(done.completedAt, isNotNull);
    final reopened =
        await repository.updateTaskStatus(saved.id, TaskStatus.toDo);
    expect(reopened.completedAt, isNull);
  });
  test('deletes final task and reports missing task', () async {
    final saved = await repository.addTask(task());
    await repository.deleteTask(saved.id);
    expect(await repository.getAllTasks(), isEmpty);
    expect(() => repository.deleteTask(saved.id),
        throwsA(isA<TaskNotFoundException>()));
  });
  test('overdue excludes completed tasks', () async {
    final old = await repository
        .addTask(task(due: DateTime.now().subtract(const Duration(days: 1))));
    expect(await repository.overdue(), hasLength(1));
    await repository.markTaskCompleted(old.id);
    expect(await repository.overdue(), isEmpty);
  });
}
