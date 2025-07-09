// GENERATED CODE - DO NOT MODIFY BY HAND

part of '../model/advancecustomerinfo.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class AdvanceEntryAdapter extends TypeAdapter<AdvanceEntry> {
  @override
  final int typeId = 5;

  @override
  AdvanceEntry read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return AdvanceEntry(
    date: fields[0] as String,
      code: fields[1] as String,
      name: fields[2] as String,
      advanceAmount: fields[3] as double,
      note: fields[4] as String,
      interestRate: fields[5] as double,
      paymentMethod: fields[6] as String,
      adminId: fields[7] as String,
      remainingInterest: fields[8] as double,
        recentDeduction: fields[9]as String,
        id: fields[10]as String
    );
  }

  @override
  void write(BinaryWriter writer, AdvanceEntry obj) {
    writer
      ..writeByte(10)
      ..writeByte(0)
      ..write(obj.date)
      ..writeByte(1)
      ..write(obj.code)
      ..writeByte(2)
      ..write(obj.name)
      ..writeByte(3)
      ..write(obj.advanceAmount)
      ..writeByte(4)
      ..write(obj.note)
      ..writeByte(5)
      ..write(obj.interestRate)
      ..writeByte(6)
      ..write(obj.paymentMethod)
      ..writeByte(7)
      ..write(obj.adminId)
      ..writeByte(8)
      ..write(obj.remainingInterest)
      ..writeByte(9)
      ..write(obj.recentDeduction)
      ..writeByte(10)
      ..write(obj.id);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AdvanceEntryAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
