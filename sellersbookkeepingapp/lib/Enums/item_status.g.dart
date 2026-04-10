// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'item_status.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ItemStatusAdapter extends TypeAdapter<ItemStatus> {
  @override
  final int typeId = 2;

  @override
  ItemStatus read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return ItemStatus.listed;
      case 1:
        return ItemStatus.sold;
      case 2:
        return ItemStatus.lost;
      default:
        return ItemStatus.listed;
    }
  }

  @override
  void write(BinaryWriter writer, ItemStatus obj) {
    switch (obj) {
      case ItemStatus.listed:
        writer.writeByte(0);
        break;
      case ItemStatus.sold:
        writer.writeByte(1);
        break;
      case ItemStatus.lost:
        writer.writeByte(2);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ItemStatusAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
