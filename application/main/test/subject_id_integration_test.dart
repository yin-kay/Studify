import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:main/models/study_task.dart';
import 'package:main/providers/subject_provider.dart';
import 'package:main/repositories/subject_repository.dart';
import 'package:main/screens/task_form_screen.dart';
import 'package:main/services/hive_service.dart';
import 'package:main/services/subject_service.dart';
import 'package:main/services/task_service.dart';
import 'package:provider/provider.dart';

void main() {
  late Directory directory;
  late HiveService hive;
  late SubjectProvider subjects;

  setUp(() async {
    directory = await Directory.systemTemp.createTemp('studyflow_subject_id_');
    hive = HiveService();
    await hive.initialize(testPath: directory.path);
    subjects = SubjectProvider(
      SubjectRepository(SubjectService(hive), TaskService(hive)),
    );
    await subjects.addSubject(name: 'CSC2074');
  });

  tearDown(() async {
    subjects.dispose();
    await hive.close();
    await directory.delete(recursive: true);
  });

  testWidgets('task form stores the selected Subject id, not its name', (
    tester,
  ) async {
    StudyTask? result;
    await tester.pumpWidget(
      ChangeNotifierProvider.value(
        value: subjects,
        child: MaterialApp(
          home: Builder(
            builder: (context) => Scaffold(
              body: FilledButton(
                onPressed: () async {
                  result = await Navigator.push<StudyTask>(
                    context,
                    MaterialPageRoute(builder: (_) => const TaskFormScreen()),
                  );
                },
                child: const Text('Open form'),
              ),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Open form'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextFormField).first, 'Submit report');
    await tester.tap(find.byType(DropdownButtonFormField<String>));
    await tester.pumpAndSettle();
    await tester.tap(find.text('CSC2074').last);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();

    expect(result, isNotNull);
    expect(result!.subjectId, subjects.subjects.single.id);
    expect(result!.subjectId, isNot('CSC2074'));
  });
}
