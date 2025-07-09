// GENERATED CODE - DO NOT MODIFY BY HAND

part of '../model/cattleFeedSupplier.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class CattleFeedSupplierAdapter extends TypeAdapter<CattleFeedSupplier> {
  @override
  final int typeId = 3;

  @override
  CattleFeedSupplier read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return CattleFeedSupplier(
      code: fields[0] as String?,
      name: fields[1] as String?,
      gender: fields[2] as String?,
      phoneNo: fields[3] as String?,
      alternatePhoneNo: fields[4] as String?,
      email: fields[5] as String?,
      accountNo: fields[6] as String?,
      bankCode: fields[7] as String?,
      sabhasadNo: fields[8] as String?,
      bankBranchName: fields[9] as String?,
      bankAccountNo: fields[10] as String?,
      ifscCode: fields[11] as String?,
      adharNo: fields[12] as String?,
      panNo: fields[13] as String?,
      adminId: fields[14] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, CattleFeedSupplier obj) {
    writer
      ..writeByte(15)
      ..writeByte(0)
      ..write(obj.code)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.gender)
      ..writeByte(3)
      ..write(obj.phoneNo)
      ..writeByte(4)
      ..write(obj.alternatePhoneNo)
      ..writeByte(5)
      ..write(obj.email)
      ..writeByte(6)
      ..write(obj.accountNo)
      ..writeByte(7)
      ..write(obj.bankCode)
      ..writeByte(8)
      ..write(obj.sabhasadNo)
      ..writeByte(9)
      ..write(obj.bankBranchName)
      ..writeByte(10)
      ..write(obj.bankAccountNo)
      ..writeByte(11)
      ..write(obj.ifscCode)
      ..writeByte(12)
      ..write(obj.adharNo)
      ..writeByte(13)
      ..write(obj.panNo)
      ..writeByte(14)
      ..write(obj.adminId);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CattleFeedSupplierAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
