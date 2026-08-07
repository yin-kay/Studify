import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:main/models/study_task.dart';
import 'package:main/models/subject.dart';
import 'package:main/services/hive_service.dart';

void main() {
  test('task, subject and settings survive a complete Hive restart', () async {
    final directory =
        await Directory.systemTemp.createTemp('studyflow_restart_');
    final created = DateTime(2026, 7, 19, 10);
    var hive = HiveService();
    await hive.initialize(testPath: directory.path);
    await hive.subjects.put(
      'subject-1',
      Subject(
        id: 'subject-1',
        name: 'CSC2074',
        colorValue: 0xFF5B5CE2,
        createdAt: created,
        updatedAt: created,
      ),
    );
    await hive.tasks.put(
      'task-1',
      StudyTask(
        id: 'task-1',
        title: 'Persistent task',
        subjectId: 'subject-1',
        dueDateTime: created.add(const Duration(days: 1)),
        createdAt: created,
        updatedAt: created,
      ),
    );
    await hive.settings.put('themeMode', 'dark');
    await hive.close();

    hive = HiveService();
    await hive.initialize(testPath: directory.path);
    try {
      expect(hive.tasks.get('task-1')?.title, 'Persistent task');
      expect(hive.tasks.get('task-1')?.subjectId, 'subject-1');
      expect(hive.subjects.get('subject-1')?.name, 'CSC2074');
      expect(hive.settings.get('themeMode'), 'dark');
    } finally {
      await hive.close();
      await directory.delete(recursive: true);
    }
  });
}
