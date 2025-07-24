import 'package:hive/hive.dart';
import 'package:DairySpace/model/ratechartinfo.dart';

part 'buffalo_rate_data.g.dart'; // Required for Hive code generation

@HiveType(typeId: 10)
class BuffaloRateData extends HiveObject {
  @HiveField(0)
  List<List<String>> excelData = [];

  @HiveField(1)
  bool filePicked = false;

  @HiveField(2)
  List<RateChartInfo>? rateChartHistory;

  @HiveField(3)
  String name = "";

  @HiveField(4)
  double? minimumBuffaloFat;

  @HiveField(5)
  double? minimumBuffaloSNF;

  @HiveField(6)
  double? minimumBuffaloRate;

  @HiveField(7)
  double? maximumBuffaloFat;

  @HiveField(8)
  double? maximumBuffaloSNF;

  @HiveField(9)
  double? maximumBuffaloRate;

  @HiveField(10)
  double? localMilkSaleBuffalo = 0;

  @HiveField(11)
  int? col = 0;

  @HiveField(12)
  int? row = 0;
  @HiveField(13)
  double morningQuantity = 0;

  @HiveField(14)
  double eveningQuantity = 0;

  BuffaloRateData({
    this.rateChartHistory,
    this.name = '',
    this.minimumBuffaloFat,
    this.minimumBuffaloSNF,
    this.minimumBuffaloRate,
    this.maximumBuffaloFat,
    this.maximumBuffaloSNF,
    this.maximumBuffaloRate,
    this.localMilkSaleBuffalo = 0,
    this.col,
    this.row,
  });
}
