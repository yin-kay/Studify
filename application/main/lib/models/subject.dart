import 'package:hive/hive.dart';

class Subject {
  static const String recoveredId = '__recovered_subject__';

  const Subject(
      {required this.id,
      required this.name,
      required this.colorValue,
      required this.createdAt,
      required this.updatedAt});
  final String id;
  final String name;
  final int colorValue;
  final DateTime createdAt;
  final DateTime updatedAt;

  Subject copyWith(
          {String? id,
          String? name,
          int? colorValue,
          DateTime? createdAt,
          DateTime? updatedAt}) =>
      Subject(
          id: id ?? this.id,
          name: name ?? this.name,
          colorValue: colorValue ?? this.colorValue,
          createdAt: createdAt ?? this.createdAt,
          updatedAt: updatedAt ?? this.updatedAt);

  @override
  bool operator ==(Object other) =>
      other is Subject &&
      other.id == id &&
      other.name == name &&
      other.colorValue == colorValue &&
      other.createdAt == createdAt &&
      other.updatedAt == updatedAt;
  @override
  int get hashCode => Object.hash(id, name, colorValue, createdAt, updatedAt);
}

class SubjectAdapter extends TypeAdapter<Subject> {
  @override
  final int typeId = 1;
  @override
  Subject read(BinaryReader reader) {
    final fieldCount = reader.readByte();
    final fields = <int, dynamic>{
      for (var i = 0; i < fieldCount; i++) reader.readByte(): reader.read()
    };
    final epoch = DateTime.fromMillisecondsSinceEpoch(0);
    final createdAt = fields[3] is DateTime ? fields[3] as DateTime : epoch;
    return Subject(
      id: _nonEmptyString(fields[0]) ?? Subject.recoveredId,
      name: _nonEmptyString(fields[1]) ?? 'Recovered subject',
      colorValue: fields[2] is int ? fields[2] as int : 0xFF5B5CE2,
      createdAt: createdAt,
      updatedAt: fields[4] is DateTime ? fields[4] as DateTime : createdAt,
    );
  }

  String? _nonEmptyString(Object? value) {
    final string = value is String ? value.trim() : null;
    return string == null || string.isEmpty ? null : string;
  }

  @override
  void write(BinaryWriter writer, Subject value) => writer
    ..writeByte(5)
    ..writeByte(0)
    ..write(value.id)
    ..writeByte(1)
    ..write(value.name)
    ..writeByte(2)
    ..write(value.colorValue)
    ..writeByte(3)
    ..write(value.createdAt)
    ..writeByte(4)
    ..write(value.updatedAt);
}
