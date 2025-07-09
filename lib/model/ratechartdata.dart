import 'package:hive/hive.dart';
class Ratechartdata {
  @HiveField(0)
  String note;

  @HiveField(1)
  List<List<String>> rateChart;

  @HiveField(2)
  int row;

  @HiveField(3)
  int col;

  Ratechartdata({required this.note, required this.rateChart, required this.row, required this.col});
}
