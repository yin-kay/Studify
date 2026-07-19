import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:main/models/study_task.dart';
import 'package:main/models/subject.dart';
import 'package:main/services/hive_service.dart';

void main() {
  test('250 tasks and 25 subjects survive repeated database restarts',
      () async {
    final directory =
        await Directory.systemTemp.createTemp('studyflow_stress_');
    final base = DateTime(2026, 7, 19, 9);
    var hive = HiveService();

    try {
      await hive.initialize(testPath: directory.path);
      for (var i = 0; i < 25; i++) {
        await hive.subjects.put(
          'subject-$i',
          Subject(
            id: 'subject-$i',
            name: 'COURSE$i',
            colorValue: 0xFF5B5CE2 + i,
            createdAt: base,
            updatedAt: base,
          ),
        );
      }
      for (var i = 0; i < 250; i++) {
        final status = TaskStatus.values[i % TaskStatus.values.length];
        await hive.tasks.put(
          'task-$i',
          StudyTask(
            id: 'task-$i',
            title: 'Stress task $i',
            subjectId: 'subject-${i % 25}',
            dueDateTime: base.add(Duration(hours: i)),
            priority: TaskPriority.values[i % TaskPriority.values.length],
            status: status,
            completed: status == TaskStatus.done,
            completedAt: status == TaskStatus.done ? base : null,
            createdAt: base,
            updatedAt: base,
          ),
        );
      }
      await hive.close();

      for (var restart = 0; restart < 3; restart++) {
        hive = HiveService();
        await hive.initialize(testPath: directory.path);
        expect(hive.tasks.length, 250);
        expect(hive.subjects.length, 25);
        expect(hive.tasks.get('task-249')?.title, 'Stress task 249');
        expect(hive.tasks.get('task-249')?.subjectId, 'subject-24');
        expect(hive.subjects.get('subject-24')?.name, 'COURSE24');
        await hive.close();
      }
    } finally {
      await hive.close();
      if (await directory.exists()) await directory.delete(recursive: true);
    }
  });
}
