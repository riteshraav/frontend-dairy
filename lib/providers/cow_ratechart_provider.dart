import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:excel/excel.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:hive/hive.dart';
import 'package:take8/model/admin.dart';
import 'package:take8/model/cow_rate_data.dart';
import 'package:take8/widgets/appbar.dart';
import '../model/ratechartinfo.dart';

@HiveType(typeId: 11)
class CowRateChartProvider extends ChangeNotifier {

  List<List<String>> excelData = [];
  bool filePicked = false;
  List<RateChartInfo> rateChartHistory  = [];
  int? row;
  int? col;
  String name = "";
  double? minimumCowFat ;
  double? minimumCowSNF ;
  double? minimumCowRate;
  double? maximumCowFat;
  double? maximumCowSNF;
  double? maximumCowRate;
  double localMilkSaleCow=0;

  // Constructor
  CowRateChartProvider({
    this.row,
    this.col,
    this.name = "",
    this.minimumCowFat,
    this.minimumCowSNF,
    this.minimumCowRate,
    this.maximumCowFat,
    this.maximumCowSNF,
    this.maximumCowRate,
    this.localMilkSaleCow = 0,
  });
  void setValues(
   var minimumCowFat,
   var minimumCowSNF,
   var minimumCowRate,
   var maximumCowFat,
   var maximumCowSNF,
   var maximumCowRate,
      )async {
    this.minimumCowFat = minimumCowFat;
    this.minimumCowSNF = minimumCowSNF;
    this.minimumCowRate = minimumCowRate;
    this.maximumCowFat = maximumCowFat;
    this.maximumCowSNF=maximumCowSNF;
    this.maximumCowRate=maximumCowRate;
    notifyListeners();
  }
  List<dynamic> getCowValues()
  {
    List<dynamic> list = [];
    list.add(minimumCowFat ?? "");
    list.add(minimumCowSNF?? "");
    list.add(minimumCowRate?? "");
    list.add(maximumCowFat?? "");
    list.add(maximumCowSNF?? "");
    list.add(maximumCowRate?? "");
    return list;
  }
  void updateAll(CowRateData cowRateData){
    excelData = cowRateData.excelData;
    rateChartHistory = cowRateData.rateChartHistory ?? [];
    filePicked = cowRateData.filePicked;
    name = cowRateData.name;
    maximumCowFat = cowRateData.maximumCowFat;
    maximumCowSNF = cowRateData.maximumCowSNF;
    maximumCowRate = cowRateData.maximumCowRate;
    minimumCowFat = cowRateData.minimumCowFat;
    minimumCowSNF = cowRateData.minimumCowSNF;
    minimumCowRate = cowRateData.minimumCowRate;
    localMilkSaleCow = cowRateData.morningQuantity;
    notifyListeners();

  }
  void updateExcelData(List<List<String>> updatedExcelData,int row, int col)async{
    excelData = updatedExcelData.map((row) => List<String>.from(row)).toList();
    RateChartInfo  rateChartInfo = RateChartInfo( note: 'Updated Rate chart', rateChart: updatedExcelData, row: row, col: col,date: DateTime.now().toIso8601String());
    rateChartHistory.add(rateChartInfo);
    print("notified all about update of the exceldata");

    if(rateChartHistory.length > 20)
      {
        List<String> keys =  rateChartHistory.map((rateChart)=>rateChart.date).toList();
        keys.sort((a,b)=>DateTime.parse(a).compareTo(DateTime.parse(b)));
          rateChartHistory.remove(keys.first);
      }
    notifyListeners();
  }
  void retrieveFromRateChartHistory(String date)
  {
   excelData =  rateChartHistory.where((rateChart)=>rateChart.date == date).first.rateChart;

  }
  /// Function to pick an Excel file and convert it to List<List<String>>
  Future<void> pickExcelFile() async {

      // Pick an Excel file
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['xlsx'], // Allow only Excel files
      );

      if (result != null && result.files.single.path != null) {
        String filePath = result.files.single.path!;

        // Read the Excel file
        var bytes = File(filePath).readAsBytesSync();
        var excel = Excel.decodeBytes(bytes);
         name =  result.files.single.name;
        // Convert Excel data to List<List<String>>
        //List<List<String>> data = [];
        excelData = [];
        for (var sheetName in excel.tables.keys) {
          var sheet = excel.tables[sheetName];
          if (sheet != null) {
            for (var row in sheet.rows) {
              excelData.add(row.map((cell) => cell?.value?.toString() ?? '').toList());
            }
          }
        }
        if(searchValue("2.00")) {
          print('row is $row col is $col');
        filePicked = true;
          RateChartInfo  rateChartInfo = RateChartInfo(note:  'New Rate chart', rateChart: excelData, row: row!, col: col!,date: DateTime.now().toIso8601String());
          rateChartHistory.add(rateChartInfo);

        }
        print("notified all about picked in exceldata");
        notifyListeners();
      }
    }

  /// Function to search for the first occurrence of 2.00
  bool searchValue(String searchValue) {
      for (int rowIndex = 0; rowIndex < excelData.length; rowIndex++) {
        for (int colIndex = 0; colIndex < excelData[rowIndex].length; colIndex++) {
          if (excelData[rowIndex][colIndex] == searchValue) {
            {
              row = rowIndex;
              col = colIndex;
              return true;
            }

          }
        }
      }
      print("2.00 not found in cow rate chart");
      return false;
  }
  double findRate(double fat,double snf){
    if((minimumCowFat != null && minimumCowSNF != null) && fat < minimumCowFat! || snf < minimumCowSNF!)
      {
        return minimumCowRate!;
      }
    else if( (maximumCowFat != null && maximumCowSNF != null ) && fat > maximumCowFat! || snf > maximumCowSNF!)
      {
        return maximumCowRate!;
      }
    else{
      print("row = $row fat = ${fat}  col = ${col}  snf = ${snf}");
      int excelRow = (row! + ((fat - 2)*10).round());
      int excelCol = ((1+col!+ (snf-7.5)*10).round());
      print("excel row $excelRow  excel col $excelCol" );
      print("snf is ${excelData[excelRow][col!]}");
      print("fat is ${excelData[row!][excelCol]}");
      return double.parse(excelData[excelRow][excelCol]);
    }
  }
}
