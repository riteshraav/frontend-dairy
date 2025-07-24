// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'buffalo_rate_data.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class BuffaloRateDataAdapter extends TypeAdapter<BuffaloRateData> {
  @override
  final int typeId = 10;

  @override
  BuffaloRateData read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return BuffaloRateData(
      rateChartHistory: (fields[2] as List?)?.cast<RateChartInfo>(),
      name: fields[3] as String,
      minimumBuffaloFat: fields[4] as double?,
      minimumBuffaloSNF: fields[5] as double?,
      minimumBuffaloRate: fields[6] as double?,
      maximumBuffaloFat: fields[7] as double?,
      maximumBuffaloSNF: fields[8] as double?,
      maximumBuffaloRate: fields[9] as double?,
      localMilkSaleBuffalo: fields[10] as double?,
      col: fields[11] as int?,
      row: fields[12] as int?,
    )
      ..excelData = (fields[0] as List)
          .map((dynamic e) => (e as List).cast<String>())
          .toList()
      ..filePicked = fields[1] as bool
      ..morningQuantity = fields[13] as double
      ..eveningQuantity = fields[14] as double;
  }

  @override
  void write(BinaryWriter writer, BuffaloRateData obj) {
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
      ..write(obj.minimumBuffaloFat)
      ..writeByte(5)
      ..write(obj.minimumBuffaloSNF)
      ..writeByte(6)
      ..write(obj.minimumBuffaloRate)
      ..writeByte(7)
      ..write(obj.maximumBuffaloFat)
      ..writeByte(8)
      ..write(obj.maximumBuffaloSNF)
      ..writeByte(9)
      ..write(obj.maximumBuffaloRate)
      ..writeByte(10)
      ..write(obj.localMilkSaleBuffalo)
      ..writeByte(11)
      ..write(obj.col)
      ..writeByte(12)
      ..write(obj.row)
      ..writeByte(13)
      ..write(obj.morningQuantity)
      ..writeByte(14)
      ..write(obj.eveningQuantity);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BuffaloRateDataAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
