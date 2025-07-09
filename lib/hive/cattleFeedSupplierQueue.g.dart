// GENERATED CODE - DO NOT MODIFY BY HAND

part of '../model/cattleFeedSupplierQueue.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class CattleFeedSupplierQueueAdapter
    extends TypeAdapter<CattleFeedSupplierQueue> {
  @override
  final int typeId = 4;

  @override
  CattleFeedSupplierQueue read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return CattleFeedSupplierQueue(
      id: fields[0] as String,
      cattleFeedSupplier: (fields[1] as List).cast<dynamic>(),
    );
  }

  @override
  void write(BinaryWriter writer, CattleFeedSupplierQueue obj) {
    writer
      ..writeByte(2)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.cattleFeedSupplier);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CattleFeedSupplierQueueAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
