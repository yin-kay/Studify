import '../errors/app_exceptions.dart';

class Validators {
  const Validators._();
  static String taskTitle(String value) => _required(value, 'Task title', 100);
  static String subjectName(String value) =>
      _required(value, 'Subject name', 40);
  static String description(String value) {
    if (value.length > 1000)
      throw const ValidationException(
          'Description must be 1000 characters or fewer.');
    return value;
  }

  static String _required(String value, String label, int maximum) {
    final trimmed = value.trim();
    if (trimmed.isEmpty) throw ValidationException('$label is required.');
    if (trimmed.length > maximum)
      throw ValidationException('$label must be $maximum characters or fewer.');
    return trimmed;
  }
}
