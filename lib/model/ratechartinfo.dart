import 'package:hive/hive.dart';
@HiveType(typeId: 9)  // Unique typeId for this model
class RateChartInfo {
  @HiveField(0)
  String note;

  @HiveField(1)
  List<List<String>> rateChart;
  @HiveField(2)
  int row;

  @HiveField(3)
  int col;

  @HiveField(4)
  String date;
  RateChartInfo({required this.note, required this.rateChart, required this.row, required this.col,required this.date});
}
