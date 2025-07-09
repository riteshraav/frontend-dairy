import 'package:hive/hive.dart';
import 'package:take8/model/ratechartinfo.dart';

class BuffaloRateData{
  List<List<String>> excelData = [];

  bool filePicked = false;

  List<RateChartInfo>? rateChartHistory ;
  String name = "";

  double? minimumBuffaloFat;

  double? minimumBuffaloSNF;

  double? minimumBuffaloRate;

  double? maximumBuffaloFat;

  double? maximumBuffaloSNF;

  double? maximumBuffaloRate;

  double? localMilkSaleBuffalo = 0;

  // Constructor
  BuffaloRateData({
    this.name = '',
    this.minimumBuffaloFat,
    this.minimumBuffaloSNF,
    this.minimumBuffaloRate,
    this.maximumBuffaloFat,
    this.maximumBuffaloSNF,
    this.maximumBuffaloRate,
    this.localMilkSaleBuffalo = 0,
  });
}