// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'tax.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class TaxAdapter extends TypeAdapter<Tax> {
  @override
  final int typeId = 4;

  @override
  Tax read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Tax(
      fields[0] as String,
      fields[1] as double,
      fields[2] as double,
      fields[3] as double?,
    );
  }

  @override
  void write(BinaryWriter writer, Tax obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.name)
      ..writeByte(1)
      ..write(obj.rate)
      ..writeByte(2)
      ..write(obj.minimumIncomeRequired)
      ..writeByte(3)
      ..write(obj.maxTaxedincome);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TaxAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
