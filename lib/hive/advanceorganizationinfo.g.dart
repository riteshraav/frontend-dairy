// GENERATED CODE - DO NOT MODIFY BY HAND

part of '../model/advanceorganizationinfo.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class AdvanceOrganizationAdapter extends TypeAdapter<AdvanceOrganization> {
  @override
  final int typeId = 6 ;

  @override
  AdvanceOrganization read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return AdvanceOrganization(
      date: fields[0] as String,
      previousBalance: fields[1] as double,
      addAmount: fields[2] as double,
      totalBalance: fields[3] as double,
      adminId: fields[4] as String,
    );
  }

  @override
  void write(BinaryWriter writer, AdvanceOrganization obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.date)
      ..writeByte(1)
      ..write(obj.previousBalance)
      ..writeByte(2)
      ..write(obj.addAmount)
      ..writeByte(3)
      ..write(obj.totalBalance)
      ..writeByte(4)
      ..write(obj.adminId);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AdvanceOrganizationAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
