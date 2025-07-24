import 'package:hive/hive.dart';
import 'ratechartinfo.dart'; // Ensure this is Hive-annotated too

part 'cow_rate_data.g.dart'; // Generated file

@HiveType(typeId: 7)
class CowRateData extends HiveObject {
  @HiveField(0)
  List<List<String>> excelData = [];

  @HiveField(1)
  bool filePicked = false;

  @HiveField(2)
  List<RateChartInfo>? rateChartHistory;

  @HiveField(3)
  String name = "";

  @HiveField(4)
  double? minimumCowFat;

  @HiveField(5)
  double? minimumCowSNF;

  @HiveField(6)
  double? minimumCowRate;

  @HiveField(7)
  double? maximumCowFat;

  @HiveField(8)
  double? maximumCowSNF;

  @HiveField(9)
  double? maximumCowRate;

  @HiveField(10)
  double morningQuantity = 0;

  @HiveField(11)
  double eveningQuantity = 0;
  @HiveField(12)
  int row = 0;
  @HiveField(13)
  int col = 0;
  @HiveField(14)
  double? localMilkSaleBuffalo = 0;


  CowRateData({
    this.rateChartHistory,
    this.name = "",
    this.minimumCowFat,
    this.minimumCowSNF,
    this.minimumCowRate,
    this.maximumCowFat,
    this.maximumCowSNF,
    this.maximumCowRate,
    this.morningQuantity = 0,
    this.eveningQuantity = 0,
    this.row = 0,
    this.col = 0
  });
}
