import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:hive/src/binary/binary_reader_impl.dart';
import 'package:hive/src/binary/binary_writer_impl.dart';
import 'package:hive/src/registry/type_registry_impl.dart';
import 'package:main/models/subject.dart';
import 'package:main/services/hive_service.dart';
import 'package:main/services/subject_service.dart';

void main() {
  test('recovers a legacy subject with null required fields', () {
    final writer = BinaryWriterImpl(TypeRegistryImpl.nullImpl)
      ..writeByte(5)
      ..writeByte(0)
      ..write(null)
      ..writeByte(1)
      ..write(null)
      ..writeByte(2)
      ..write(null)
      ..writeByte(3)
      ..write(null)
      ..writeByte(4)
      ..write(null);
    final reader = BinaryReaderImpl(
      writer.toBytes(),
      TypeRegistryImpl.nullImpl,
    );

    final subject = SubjectAdapter().read(reader);

    expect(subject.id, Subject.recoveredId);
    expect(subject.name, 'Recovered subject');
    expect(subject.colorValue, 0xFF5B5CE2);
    expect(subject.createdAt, DateTime.fromMillisecondsSinceEpoch(0));
    expect(subject.updatedAt, DateTime.fromMillisecondsSinceEpoch(0));
  });

  test('rekeys a recovered subject using its Hive record key', () async {
    final directory =
        await Directory.systemTemp.createTemp('studyflow_subject_recovery_');
    final hive = HiveService();
    await hive.initialize(testPath: directory.path);
    try {
      final epoch = DateTime.fromMillisecondsSinceEpoch(0);
      await hive.subjects.put(
        9,
        Subject(
          id: Subject.recoveredId,
          name: 'Recovered subject',
          colorValue: 0xFF5B5CE2,
          createdAt: epoch,
          updatedAt: epoch,
        ),
      );

      final subjects = await SubjectService(hive).getAll();

      expect(subjects.single.id, '9');
      expect(hive.subjects.containsKey(9), isFalse);
      expect(hive.subjects.get('9')?.id, '9');
    } finally {
      await hive.close();
      await directory.delete(recursive: true);
    }
  });
}
