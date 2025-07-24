// GENERATED CODE - DO NOT MODIFY BY HAND

part of '../model/loancustomerinfo.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class LoanEntryAdapter extends TypeAdapter<LoanEntry> {
  @override
  final int typeId = 8;

  @override
  LoanEntry read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return LoanEntry(
      date: fields[0] as String,
      customerId: fields[1] as String,
      adminId: fields[2] as String,
      loanAmount: fields[3] as double?,
      note: fields[4] as String,
      interestRate: fields[5] as double?,
      modeOfPayback: fields[6] as String,
      remainingInterest: fields[7] as double?,
      recentDeduction: fields[8] as String,
    );
  }

  @override
  void write(BinaryWriter writer, LoanEntry obj) {
    writer
      ..writeByte(9)
      ..writeByte(0)
      ..write(obj.date)
      ..writeByte(1)
      ..write(obj.customerId)
      ..writeByte(2)
      ..write(obj.adminId)
      ..writeByte(3)
      ..write(obj.loanAmount)
      ..writeByte(4)
      ..write(obj.note)
      ..writeByte(5)
      ..write(obj.interestRate)
      ..writeByte(6)
      ..write(obj.modeOfPayback)
      ..writeByte(7)
      ..write(obj.remainingInterest)
      ..writeByte(8)
      ..write(obj.recentDeduction);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is LoanEntryAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
