import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:hive/src/binary/binary_reader_impl.dart';
import 'package:hive/src/binary/binary_writer_impl.dart';
import 'package:hive/src/registry/type_registry_impl.dart';
import 'package:main/models/study_task.dart';
import 'package:main/services/hive_service.dart';
import 'package:main/services/task_service.dart';

void main() {
  test('recovers a legacy task with null required fields', () {
    final writer = BinaryWriterImpl(TypeRegistryImpl.nullImpl)
      ..writeByte(9)
      ..writeByte(0)
      ..write(null)
      ..writeByte(1)
      ..write(null)
      ..writeByte(2)
      ..write(null)
      ..writeByte(4)
      ..write(null)
      ..writeByte(5)
      ..write(null)
      ..writeByte(6)
      ..write(null)
      ..writeByte(7)
      ..write(null)
      ..writeByte(8)
      ..write(null)
      ..writeByte(9)
      ..write(null);
    final reader = BinaryReaderImpl(
      writer.toBytes(),
      TypeRegistryImpl.nullImpl,
    );

    final task = StudyTaskAdapter().read(reader);

    expect(task.id, isNotEmpty);
    expect(task.title, 'Untitled task');
    expect(task.dueDateTime, DateTime.fromMillisecondsSinceEpoch(0));
    expect(task.createdAt, DateTime.fromMillisecondsSinceEpoch(0));
    expect(task.updatedAt, DateTime.fromMillisecondsSinceEpoch(0));
    expect(task.priority, TaskPriority.medium);
    expect(task.status, TaskStatus.toDo);
  });

  test('rekeys a recovered task using its Hive record key', () async {
    final directory =
        await Directory.systemTemp.createTemp('studyflow_recovery_');
    final hive = HiveService();
    await hive.initialize(testPath: directory.path);
    try {
      await hive.tasks.put(
        7,
        StudyTask(
          id: StudyTask.recoveredId,
          title: 'Untitled task',
          dueDateTime: DateTime.fromMillisecondsSinceEpoch(0),
        ),
      );

      final tasks = await TaskService(hive).getAll();

      expect(tasks.single.id, '7');
      expect(hive.tasks.containsKey(7), isFalse);
      expect(hive.tasks.get('7')?.id, '7');
    } finally {
      await hive.close();
      await directory.delete(recursive: true);
    }
  });
}
