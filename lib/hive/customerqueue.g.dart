// GENERATED CODE - DO NOT MODIFY BY HAND

part of '../model/customerqueue.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class CustomerQueueAdapter extends TypeAdapter<CustomerQueue> {
  @override
  final int typeId = 2;

  @override
  CustomerQueue read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return CustomerQueue(
      id: fields[0] as String,
      customer: (fields[1] as List).cast<dynamic>(),
    );
  }

  @override
  void write(BinaryWriter writer, CustomerQueue obj) {
    writer
      ..writeByte(2)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.customer);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CustomerQueueAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
