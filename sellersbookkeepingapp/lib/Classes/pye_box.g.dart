// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'pye_box.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class PyeBoxAdapter extends TypeAdapter<PyeBox> {
  @override
  final int typeId = 1;

  @override
  PyeBox read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return PyeBox(
      id: fields[0] as int,
      totalPaidPrice: fields[3] as double,
      date: fields[1] as DateTime,
      items: (fields[2] as List).cast<Item>(),
    );
  }

  @override
  void write(BinaryWriter writer, PyeBox obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.date)
      ..writeByte(2)
      ..write(obj.items)
      ..writeByte(3)
      ..write(obj.totalPaidPrice);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PyeBoxAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
