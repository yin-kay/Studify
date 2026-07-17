import 'package:flutter_test/flutter_test.dart';
import 'package:main/errors/app_exceptions.dart';
import 'package:main/utils/validators.dart';

void main() {
  group('Validators', () {
    test('trims a valid task title',
        () => expect(Validators.taskTitle('  Read  '), 'Read'));
    test('rejects empty and whitespace-only titles', () {
      expect(
          () => Validators.taskTitle(''), throwsA(isA<ValidationException>()));
      expect(() => Validators.taskTitle('   '),
          throwsA(isA<ValidationException>()));
    });
    test('rejects long titles and descriptions', () {
      expect(() => Validators.taskTitle(List.filled(101, 'a').join()),
          throwsA(isA<ValidationException>()));
      expect(() => Validators.description(List.filled(1001, 'a').join()),
          throwsA(isA<ValidationException>()));
    });
    test('validates subject names', () {
      expect(Validators.subjectName(' CSC2074 '), 'CSC2074');
      expect(() => Validators.subjectName(' '),
          throwsA(isA<ValidationException>()));
    });
  });
}
