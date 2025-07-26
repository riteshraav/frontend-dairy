import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:excel/excel.dart';
import 'package:hive/hive.dart';

import '../model/admin.dart';
import '../model/buffalo_rate_data.dart';
import '../model/ratechartinfo.dart';
import '../widgets/appbar.dart';

class BuffaloRatechartProvider extends ChangeNotifier {
  List<List<String>> excelData = [];

  bool filePicked = false;

  List<RateChartInfo> rateChartHistory = [];
  double _morningBuffaloQuantity = 0;

  double get morningBuffaloQuantity => _morningBuffaloQuantity;

  set morningBuffaloQuantity(double value) {
    _morningBuffaloQuantity = value;
    Admin admin = CustomWidgets().currentAdminNonStatic();
    var buffaloBox = Hive.box<BuffaloRateData>('buffaloBox');
    BuffaloRateData buffaloRateData  = buffaloBox.get('buffaloRateData_${admin.id}')??BuffaloRateData();
    buffaloRateData.morningQuantity = value;
    buffaloBox.put('buffaloRateData_${admin.id}', buffaloRateData);
    notifyListeners();
  }

  double _eveningBuffaloQuantity = 0;
  int? row;

  int? col;

  String name = "";

  double? minimumBuffaloFat ;

  double? minimumBuffaloSNF;

  double? minimumBuffaloRate;

  double? maximumBuffaloFat;

  double? maximumBuffaloSNF;

  double? maximumBuffaloRate;

  double localMilkSaleBuffalo = 0;

  // Constructor
  BuffaloRatechartProvider({
    this.row,
    this.col,
    this.name = "",
    this.minimumBuffaloFat,
    this.minimumBuffaloSNF,
    this.minimumBuffaloRate,
    this.maximumBuffaloFat,
    this.maximumBuffaloSNF,
    this.maximumBuffaloRate,
    this.localMilkSaleBuffalo = 0,
  });
  void updateAll(BuffaloRateData rateData){
    excelData = rateData.excelData;
    rateChartHistory= rateData.rateChartHistory ?? [];
    filePicked = rateData.filePicked;
    name = rateData.name;
    maximumBuffaloFat = rateData.maximumBuffaloFat;
    maximumBuffaloSNF = rateData.maximumBuffaloSNF;
    maximumBuffaloRate = rateData.maximumBuffaloRate;
    minimumBuffaloFat = rateData.minimumBuffaloFat;
    minimumBuffaloSNF = rateData.minimumBuffaloSNF;
    minimumBuffaloRate = rateData.minimumBuffaloRate;
    localMilkSaleBuffalo = rateData.localMilkSaleBuffalo!;
    col = rateData.col;
    row = rateData.row;
    morningBuffaloQuantity = rateData.morningQuantity;
    eveningBuffaloQuantity = rateData.eveningQuantity;
    notifyListeners();
  }

  void clearAllData() {
    print("Clearing all BuffaloRatechartProvider data...");

    excelData = [];
    filePicked = false;
    rateChartHistory = [];

    row = null;
    col = null;

    name = "";

    minimumBuffaloFat = null;
    minimumBuffaloSNF = null;
    minimumBuffaloRate = null;
    maximumBuffaloFat = null;
    maximumBuffaloSNF = null;
    maximumBuffaloRate = null;

    localMilkSaleBuffalo = 0;

    notifyListeners();
    print("BuffaloRatechartProvider data cleared.");
  }
  Future<void> setValues(
      var minimumBuffaloFat,
      double minimumBuffaloSNF,
      double minimumBuffaloRate,
      double maximumBuffaloFat,
      double maximumBuffaloSNF,
      double maximumBuffaloRate
      )async {
    Admin admin = CustomWidgets.currentAdmin();

    this.minimumBuffaloFat=minimumBuffaloFat;
    this.minimumBuffaloSNF=minimumBuffaloSNF;
    this.minimumBuffaloRate=minimumBuffaloRate;
    this.maximumBuffaloFat=maximumBuffaloFat;
    this.maximumBuffaloSNF=maximumBuffaloSNF;
    this.maximumBuffaloRate=maximumBuffaloRate;
    var buffaloBox =  Hive.box<BuffaloRateData>('buffaloBox');
    BuffaloRateData buffaloRateData = buffaloBox.get('buffaloRateData_${admin.id}') ?? BuffaloRateData();
    buffaloRateData.minimumBuffaloFat=minimumBuffaloFat;
    buffaloRateData.minimumBuffaloSNF=minimumBuffaloSNF;
    buffaloRateData.minimumBuffaloRate=minimumBuffaloRate;
    buffaloRateData.maximumBuffaloFat=maximumBuffaloFat;
    buffaloRateData.maximumBuffaloSNF=maximumBuffaloSNF;
    buffaloRateData.maximumBuffaloRate=maximumBuffaloRate;
    buffaloBox.put('buffaloRateData_${admin.id}', buffaloRateData);
    notifyListeners();
  }
  List<dynamic> getBuffaloValues()
   {
    List<dynamic> list = [];
    list.add(minimumBuffaloFat ??"");
    list.add(minimumBuffaloSNF??"");
    list.add(minimumBuffaloRate ??"");
    list.add(maximumBuffaloFat ??"");
    list.add(maximumBuffaloSNF??"");
    list.add(maximumBuffaloRate ??"");
    return list;
  }
  void updateExcelData(List<List<String>> updatedExcelData,int row, int col)async{
    excelData = updatedExcelData.map((row) => List<String>.from(row)).toList();
    RateChartInfo  rateChartInfo = RateChartInfo(note: 'Updated Rate chart', rateChart: updatedExcelData, row: row, col: col,date: DateTime.now().toIso8601String());
    rateChartHistory.add(rateChartInfo);
    print("notified all about update of the exceldata");

    if(rateChartHistory.length > 20)
    {
      List<String> dates =  rateChartHistory.map((rateChart) => rateChart.date).toList();
      dates.sort((a,b)=>DateTime.parse(a).compareTo(DateTime.parse(b)));
      rateChartHistory.remove(dates.first);
    }
    notifyListeners();
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
       Admin admin = CustomWidgets().currentAdminNonStatic();
       var buffaloBox = Hive.box<BuffaloRateData>('buffaloBox');
       BuffaloRateData buffaloRateData  = buffaloBox.get('buffaloRateData_${admin.id}')??BuffaloRateData();

      if(searchValue("3.00")) {
        buffaloRateData.excelData = excelData;
        filePicked = true;
        buffaloRateData.filePicked = true;
        RateChartInfo  rateChartInfo = RateChartInfo(note:  'New Rate chart', rateChart: excelData, row: row!, col: col!,date: DateTime.now().toIso8601String());
        rateChartHistory.add( rateChartInfo);

        // buffaloRateData.rateChartHistory = rateChartHistory;
        buffaloRateData.row = row;
        buffaloRateData.col = col;
         buffaloRateData.name = name;
      }
      buffaloBox.put('buffaloRateData_${admin.id}', buffaloRateData);
      notifyListeners();
    }
  }

  /// Function to search for the first occurrence of 3.00
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

    // If the value is not found
    print("Value '$searchValue' not found.");
    print("3.00 not found in cow rate chart");
    return false;

  }
  double findRate(double fat, double snf) {
    // Case 1: Minimum bounds check
    if ((minimumBuffaloFat != null && minimumBuffaloSNF != null) &&
        (fat < minimumBuffaloFat! || snf < minimumBuffaloSNF!)) {
      return minimumBuffaloRate!;
    }

    // Case 2: Maximum bounds check
    else if ((maximumBuffaloFat != null && maximumBuffaloSNF != null) &&
        (fat > maximumBuffaloFat! || snf > maximumBuffaloSNF!)) {
      return maximumBuffaloRate!;
    }


    // Case 3: Default when no bounds or within range
    else {
      print("row = $row fat = $fat  col = $col  snf = $snf");

      int excelRow = row! + ((fat - 3) * 10).round();
      int excelCol = 1 + col! + ((snf - 8) * 10).round();

      print("excel row $excelRow  excel col $excelCol");
      print("snf is ${excelData[excelRow][col!]}");
      print("fat is ${excelData[row!][excelCol]}");

      return double.parse(excelData[excelRow][excelCol]);
    }
  }

  double get eveningBuffaloQuantity => _eveningBuffaloQuantity;

  set eveningBuffaloQuantity(double value) {
    _eveningBuffaloQuantity = value;
    Admin admin = CustomWidgets().currentAdminNonStatic();
    var buffaloBox = Hive.box<BuffaloRateData>('buffaloBox');
    BuffaloRateData buffaloRateData  = buffaloBox.get('buffaloRateData_${admin.id}')??BuffaloRateData();
    buffaloRateData.eveningQuantity = value;
    buffaloBox.put('buffaloRateData_${admin.id}', buffaloRateData);
    notifyListeners();
  }
}
