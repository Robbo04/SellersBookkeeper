// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'item.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ItemAdapter extends TypeAdapter<Item> {
  @override
  final int typeId = 0;

  @override
  Item read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Item(
      name: fields[0] as String,
      boughtFrom: fields[1] as String,
      sellingPrice: fields[4] as double,
      retailPrice: fields[5] as double,
      costPrice: fields[6] as double,
      soldPrice: fields[7] as double,
      boughtDate: fields[2] as DateTime,
      soldDate: fields[8] as DateTime?,
    )
      ..isSold = fields[3] as bool
      ..daysToSell = fields[9] as int?;
  }

  @override
  void write(BinaryWriter writer, Item obj) {
    writer
      ..writeByte(10)
      ..writeByte(0)
      ..write(obj.name)
      ..writeByte(1)
      ..write(obj.boughtFrom)
      ..writeByte(2)
      ..write(obj.boughtDate)
      ..writeByte(3)
      ..write(obj.isSold)
      ..writeByte(4)
      ..write(obj.sellingPrice)
      ..writeByte(5)
      ..write(obj.retailPrice)
      ..writeByte(6)
      ..write(obj.costPrice)
      ..writeByte(7)
      ..write(obj.soldPrice)
      ..writeByte(8)
      ..write(obj.soldDate)
      ..writeByte(9)
      ..write(obj.daysToSell);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ItemAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
