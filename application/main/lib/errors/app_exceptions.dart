class AppDatabaseException implements Exception {
  const AppDatabaseException(this.message);
  final String message;
  @override
  String toString() => message;
}

class TaskNotFoundException implements Exception {
  const TaskNotFoundException();
}

class SubjectNotFoundException implements Exception {
  const SubjectNotFoundException();
}

class ValidationException implements Exception {
  const ValidationException(this.message);
  final String message;
  @override
  String toString() => message;
}

class DuplicateSubjectException implements Exception {
  const DuplicateSubjectException(this.message);
  final String message;
  @override
  String toString() => message;
}
