import 'package:hive/hive.dart';

enum TaskPriority { high, medium, low }

enum TaskStatus { toDo, inProgress, done }

class StudyTask {
  static const String recoveredId = '__recovered_task__';

  StudyTask({
    String? id,
    required String title,
    String? subjectId,
    String? course,
    String? due,
    this.category = '',
    this.priority = TaskPriority.medium,
    DateTime? dueDateTime,
    DateTime? dueDate,
    String description = '',
    this.status = TaskStatus.toDo,
    bool? completed,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? completedAt,
  })  : id = id ?? '',
        title = title.trim(),
        subjectId = subjectId ?? course,
        dueLabel = due ?? '',
        dueDateTime = dueDateTime ?? dueDate ?? DateTime.now(),
        description = description,
        createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? createdAt ?? DateTime.now(),
        completedAt = completedAt,
        completed = completed ?? status == TaskStatus.done;

  final String id;
  final String title;
  final String? subjectId;
  final String dueLabel;
  final String category;
  final TaskPriority priority;
  final DateTime dueDateTime;
  final String description;
  final TaskStatus status;
  final bool completed;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? completedAt;

  String get course => subjectId ?? 'None';
  String get due => dueLabel;
  DateTime get dueDate => dueDateTime;

  StudyTask copyWith({
    String? id,
    String? title,
    String? subjectId,
    bool clearSubject = false,
    String? dueLabel,
    String? category,
    TaskPriority? priority,
    DateTime? dueDateTime,
    String? description,
    TaskStatus? status,
    bool? completed,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? completedAt,
    bool clearCompletedAt = false,
  }) {
    return StudyTask(
      id: id ?? this.id,
      title: title ?? this.title,
      subjectId: clearSubject ? null : subjectId ?? this.subjectId,
      due: dueLabel ?? this.dueLabel,
      category: category ?? this.category,
      priority: priority ?? this.priority,
      dueDateTime: dueDateTime ?? this.dueDateTime,
      description: description ?? this.description,
      status: status ?? this.status,
      completed: completed ?? this.completed,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      completedAt: clearCompletedAt ? null : completedAt ?? this.completedAt,
    );
  }

  @override
  bool operator ==(Object other) =>
      other is StudyTask &&
      other.id == id &&
      other.title == title &&
      other.subjectId == subjectId &&
      other.description == description &&
      other.dueDateTime == dueDateTime &&
      other.priority == priority &&
      other.status == status &&
      other.createdAt == createdAt &&
      other.updatedAt == updatedAt &&
      other.completedAt == completedAt;

  @override
  int get hashCode => Object.hash(id, title, subjectId, description,
      dueDateTime, priority, status, createdAt, updatedAt, completedAt);
}

class StudyTaskAdapter extends TypeAdapter<StudyTask> {
  @override
  final int typeId = 0;

  @override
  StudyTask read(BinaryReader reader) {
    final fieldCount = reader.readByte();
    final fields = <int, dynamic>{
      for (var i = 0; i < fieldCount; i++) reader.readByte(): reader.read(),
    };
    final epoch = DateTime.fromMillisecondsSinceEpoch(0);
    final createdAt = _date(fields[7]) ?? epoch;
    return StudyTask(
      id: _nonEmptyString(fields[0]) ?? StudyTask.recoveredId,
      title: _nonEmptyString(fields[1]) ?? 'Untitled task',
      subjectId: _nonEmptyString(fields[2]),
      description: _string(fields[3]) ?? '',
      dueDateTime: _date(fields[4]) ?? epoch,
      priority: _priorityFrom(fields[5]),
      status: _statusFrom(fields[6]),
      createdAt: createdAt,
      updatedAt: _date(fields[8]) ?? createdAt,
      completedAt: _date(fields[9]),
      category: _string(fields[10]) ?? '',
      due: _string(fields[11]) ?? '',
    );
  }

  @override
  void write(BinaryWriter writer, StudyTask task) {
    writer
      ..writeByte(12)
      ..writeByte(0)
      ..write(task.id)
      ..writeByte(1)
      ..write(task.title)
      ..writeByte(2)
      ..write(task.subjectId)
      ..writeByte(3)
      ..write(task.description)
      ..writeByte(4)
      ..write(task.dueDateTime)
      ..writeByte(5)
      ..write(task.priority.name)
      ..writeByte(6)
      ..write(task.status.name)
      ..writeByte(7)
      ..write(task.createdAt)
      ..writeByte(8)
      ..write(task.updatedAt)
      ..writeByte(9)
      ..write(task.completedAt)
      ..writeByte(10)
      ..write(task.category)
      ..writeByte(11)
      ..write(task.dueLabel);
  }

  String? _string(Object? value) => value is String ? value : null;

  String? _nonEmptyString(Object? value) {
    final string = _string(value)?.trim();
    return string == null || string.isEmpty ? null : string;
  }

  DateTime? _date(Object? value) => value is DateTime ? value : null;

  TaskPriority _priorityFrom(Object? value) =>
      TaskPriority.values.firstWhere((item) => item.name == value,
          orElse: () => TaskPriority.medium);
  TaskStatus _statusFrom(Object? value) => TaskStatus.values
      .firstWhere((item) => item.name == value, orElse: () => TaskStatus.toDo);
}
