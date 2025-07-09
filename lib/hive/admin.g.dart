// GENERATED CODE - DO NOT MODIFY BY HAND

part of '../model/admin.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class AdminAdapter extends TypeAdapter<Admin> {
  @override
  final int typeId = 0;

  @override
  Admin read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Admin(
      code: fields[0] as int?,
      name: fields[1] as String?,
      password: fields[2] as String?,
      id: fields[3] as String?,
      dairyName: fields[4] as String?,
      city: fields[5] as String?,
      subDistrict: fields[6] as String?,
      district: fields[7] as String?,
      state: fields[8] as String?,
      customerSequence: fields[9] as int?,
      supplierSequence: fields[10] as int?,
      currentBalance: fields[11] as double?,
    );
  }

  @override
  void write(BinaryWriter writer, Admin obj) {
    writer
      ..writeByte(12)
      ..writeByte(0)
      ..write(obj.code)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.password)
      ..writeByte(3)
      ..write(obj.id)
      ..writeByte(4)
      ..write(obj.dairyName)
      ..writeByte(5)
      ..write(obj.city)
      ..writeByte(6)
      ..write(obj.subDistrict)
      ..writeByte(7)
      ..write(obj.district)
      ..writeByte(8)
      ..write(obj.state)
      ..writeByte(9)
      ..write(obj.customerSequence)
      ..writeByte(10)
      ..write(obj.supplierSequence)
      ..writeByte(11)
      ..write(obj.currentBalance);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AdminAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
