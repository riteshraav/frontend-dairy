// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'cow_rate_data.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class CowRateDataAdapter extends TypeAdapter<CowRateData> {
  @override
  final int typeId = 7;

  @override
  CowRateData read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return CowRateData(
      rateChartHistory: (fields[2] as List?)?.cast<RateChartInfo>(),
      name: fields[3] as String,
      minimumCowFat: fields[4] as double?,
      minimumCowSNF: fields[5] as double?,
      minimumCowRate: fields[6] as double?,
      maximumCowFat: fields[7] as double?,
      maximumCowSNF: fields[8] as double?,
      maximumCowRate: fields[9] as double?,
      morningQuantity: fields[10] as double,
      eveningQuantity: fields[11] as double,
      row: fields[12] as int,
      col: fields[13] as int,
    )
      ..excelData = (fields[0] as List)
          .map((dynamic e) => (e as List).cast<String>())
          .toList()
      ..filePicked = fields[1] as bool
      ..localMilkSaleBuffalo = fields[14] as double?;
  }

  @override
  void write(BinaryWriter writer, CowRateData obj) {
    writer
      ..writeByte(15)
      ..writeByte(0)
      ..write(obj.excelData)
      ..writeByte(1)
      ..write(obj.filePicked)
      ..writeByte(2)
      ..write(obj.rateChartHistory)
      ..writeByte(3)
      ..write(obj.name)
      ..writeByte(4)
      ..write(obj.minimumCowFat)
      ..writeByte(5)
      ..write(obj.minimumCowSNF)
      ..writeByte(6)
      ..write(obj.minimumCowRate)
      ..writeByte(7)
      ..write(obj.maximumCowFat)
      ..writeByte(8)
      ..write(obj.maximumCowSNF)
      ..writeByte(9)
      ..write(obj.maximumCowRate)
      ..writeByte(10)
      ..write(obj.morningQuantity)
      ..writeByte(11)
      ..write(obj.eveningQuantity)
      ..writeByte(12)
      ..write(obj.row)
      ..writeByte(13)
      ..write(obj.col)
      ..writeByte(14)
      ..write(obj.localMilkSaleBuffalo);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CowRateDataAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
