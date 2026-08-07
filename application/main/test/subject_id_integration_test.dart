import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:main/models/study_task.dart';
import 'package:main/models/subject.dart';
import 'package:main/providers/subject_provider.dart';
import 'package:main/repositories/subject_repository.dart';
import 'package:main/screens/task_form_screen.dart';
import 'package:main/services/hive_service.dart';
import 'package:main/services/subject_service.dart';
import 'package:main/services/task_service.dart';
import 'package:provider/provider.dart';

void main() {
  late SubjectProvider subjects;

  setUp(() {
    subjects = _FakeSubjectProvider();
  });

  tearDown(() {
    subjects.dispose();
  });

  testWidgets('task form stores the selected Subject id, not its name', (
    tester,
  ) async {
    (subjects as _FakeSubjectProvider).values = [
      Subject(
        id: 'subject-1',
        name: 'CSC2074',
        colorValue: 0xFF5B5CE2,
        createdAt: DateTime(2026, 7, 20),
        updatedAt: DateTime(2026, 7, 20),
      ),
    ];
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
    await tester.pump(const Duration(seconds: 1));
    await tester.tap(find.text('CSC2074').last);
    await tester.pump(const Duration(seconds: 1));
    await tester.tap(find.text('Save'));
    await tester.pump(const Duration(seconds: 1));

    expect(result, isNotNull);
    expect(result!.subjectId, subjects.subjects.single.id);
    expect(result!.subjectId, isNot('CSC2074'));
  });

  testWidgets('task form offers None and saves without any subjects', (
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
    await tester.enterText(find.byType(TextFormField).first, 'No subject task');
    await tester.tap(find.byType(DropdownButtonFormField<String>));
    await tester.pump(const Duration(seconds: 1));

    expect(find.text('None'), findsWidgets);
    await tester.tap(find.text('None').last);
    await tester.pump(const Duration(seconds: 1));
    await tester.tap(find.text('Save'));
    await tester.pump(const Duration(seconds: 1));

    expect(result, isNotNull);
    expect(result!.subjectId, isNull);
  });
}

class _FakeSubjectProvider extends SubjectProvider {
  _FakeSubjectProvider()
      : super(
          SubjectRepository(
            SubjectService(HiveService()),
            TaskService(HiveService()),
          ),
        );

  List<Subject> values = [];

  @override
  List<Subject> get subjects => List.unmodifiable(values);
}
