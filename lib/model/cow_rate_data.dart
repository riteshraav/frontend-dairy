import 'package:hive/hive.dart';
import 'package:take8/model/ratechartinfo.dart';

class CowRateData{

  List<List<String>> excelData = [];

  bool filePicked = false;

  List<RateChartInfo>? rateChartHistory ;

  String name = "";

  double? minimumCowFat ;

  double? minimumCowSNF ;

  double? minimumCowRate;

  double? maximumCowFat;

  double? maximumCowSNF;


  double? maximumCowRate;

  double morningQuantity=0;
  double eveningQuantity=0;


  // Constructor
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

  });
}