import 'package:hive/hive.dart';

class Subject {
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
    final fields = <int, dynamic>{
      for (var i = 0; i < reader.readByte(); i++)
        reader.readByte(): reader.read()
    };
    return Subject(
        id: fields[0] as String,
        name: fields[1] as String,
        colorValue: fields[2] as int,
        createdAt: fields[3] as DateTime,
        updatedAt: fields[4] as DateTime);
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
