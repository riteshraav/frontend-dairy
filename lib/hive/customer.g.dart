// GENERATED CODE - DO NOT MODIFY BY HAND

part of '../model/Customer.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************


class CustomerAdapter extends TypeAdapter<Customer> {
  @override
  final int typeId = 1;

  @override
  Customer read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Customer(
      code: fields[0] as String?,
      name: fields[1] as String?,
      phone: fields[2] as String?,
      buffalo: fields[3] as bool?,
      cow: fields[4] as bool?,
      adminId: fields[5] as String?,
      classType: fields[6] as String?,
      branchName: fields[7] as String?,
      gender: fields[8] as String?,
      caste: fields[9] as String?,
      alternateNumber: fields[10] as String?,
      email: fields[11] as String?,
      accountNo: fields[12] as String?,
      bankCode: fields[13] as String?,
      sabhasadNo: fields[14] as String?,
      bankBranchName: fields[15] as String?,
      ifscNo: fields[16] as String?,
      aadharNo: fields[17] as String?,
      panNo: fields[18] as String?,
      animalCount: fields[19] as int?,
      averageMilk: fields[20] as double?,
    );
  }

  @override
  void write(BinaryWriter writer, Customer obj) {
    writer
      ..writeByte(21)
      ..writeByte(0)
      ..write(obj.code)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.phone)
      ..writeByte(3)
      ..write(obj.buffalo)
      ..writeByte(4)
      ..write(obj.cow)
      ..writeByte(5)
      ..write(obj.adminId)
      ..writeByte(6)
      ..write(obj.classType)
      ..writeByte(7)
      ..write(obj.branchName)
      ..writeByte(8)
      ..write(obj.gender)
      ..writeByte(9)
      ..write(obj.caste)
      ..writeByte(10)
      ..write(obj.alternateNumber)
      ..writeByte(11)
      ..write(obj.email)
      ..writeByte(12)
      ..write(obj.accountNo)
      ..writeByte(13)
      ..write(obj.bankCode)
      ..writeByte(14)
      ..write(obj.sabhasadNo)
      ..writeByte(15)
      ..write(obj.bankBranchName)
      ..writeByte(16)
      ..write(obj.ifscNo)
      ..writeByte(17)
      ..write(obj.aadharNo)
      ..writeByte(18)
      ..write(obj.panNo)
      ..writeByte(19)
      ..write(obj.animalCount)
      ..writeByte(20)
      ..write(obj.averageMilk);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          other is CustomerAdapter &&
              runtimeType == other.runtimeType &&
              typeId == other.typeId;
}
