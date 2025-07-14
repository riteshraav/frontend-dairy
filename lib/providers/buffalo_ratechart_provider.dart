import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:excel/excel.dart';
import 'package:hive/hive.dart';
import 'package:take8/model/buffalo_rate_data.dart';
import '../model/admin.dart';
import '../model/ratechartinfo.dart';
import '../widgets/appbar.dart';
import 'cow_ratechart_provider.dart';

/// BuffaloRatechartProvider
/// ------------------------
/// Holds the entire state of the buffalo‑rate chart including the
/// uploaded Excel table and the six limit values (min/max fat, SNF, rate).
///
/// *Default limits* are now hard‑coded as requested:
///   * *Minimum*  – Fat *3.0, SNF **8.0, Rate **39.80*
///   * *Maximum*  – Fat *14.90, SNF **10.0, Rate **81.75*
///
/// You can still override them at runtime with setValues().
class BuffaloRatechartProvider extends ChangeNotifier {
  // ────────────────────────────────────────────────────────────────────────
  // Excel data & meta
  List<List<String>> excelData = [];
  bool filePicked = false;
  List<RateChartInfo> rateChartHistory = [];

  int? row;
  int? col;
  String name = "";

  // ────────────────────────────────────────────────────────────────────────
  // Limit values (INITIALISED with requested defaults)
  double? minimumBuffaloFat   = 3.0;
  double? minimumBuffaloSNF   = 8.0;
  double? minimumBuffaloRate  = 39.80;

  double? maximumBuffaloFat   = 14.90;
  double? maximumBuffaloSNF   = 10.0;
  double? maximumBuffaloRate  = 81.75;

  double localMilkSaleBuffalo = 0;

  // ────────────────────────────────────────────────────────────────────────
  // Constructor – optional, you can override defaults here if needed.
  BuffaloRatechartProvider({
    this.row,
    this.col,
    this.name = "",
    double? minimumBuffaloFat,
    double? minimumBuffaloSNF,
    double? minimumBuffaloRate,
    double? maximumBuffaloFat,
    double? maximumBuffaloSNF,
    double? maximumBuffaloRate,
    this.localMilkSaleBuffalo = 0,
  }) {
    // If custom values supplied, use them instead of defaults
    if (minimumBuffaloFat != null) this.minimumBuffaloFat = minimumBuffaloFat;
    if (minimumBuffaloSNF != null) this.minimumBuffaloSNF = minimumBuffaloSNF;
    if (minimumBuffaloRate != null) this.minimumBuffaloRate = minimumBuffaloRate;
    if (maximumBuffaloFat != null) this.maximumBuffaloFat = maximumBuffaloFat;
    if (maximumBuffaloSNF != null) this.maximumBuffaloSNF = maximumBuffaloSNF;
    if (maximumBuffaloRate != null) this.maximumBuffaloRate = maximumBuffaloRate;
  }

  // ────────────────────────────────────────────────────────────────────────
  // Update whole object from persisted Hive model
  void updateAll(BuffaloRateData rateData) {
    excelData              = rateData.excelData;
    rateChartHistory       = rateData.rateChartHistory ?? [];
    filePicked             = rateData.filePicked;
    name                   = rateData.name;
    maximumBuffaloFat      = rateData.maximumBuffaloFat;
    maximumBuffaloSNF      = rateData.maximumBuffaloSNF;
    maximumBuffaloRate     = rateData.maximumBuffaloRate;
    minimumBuffaloFat      = rateData.minimumBuffaloFat;
    minimumBuffaloSNF      = rateData.minimumBuffaloSNF;
    minimumBuffaloRate     = rateData.minimumBuffaloRate;
    localMilkSaleBuffalo   = rateData.localMilkSaleBuffalo ?? 0;
    notifyListeners();
  }

  // Persist current provider state into a BuffaloRateData instance
  BuffaloRateData toBuffaloRateData() {
    return BuffaloRateData()
      ..excelData            = excelData
      ..rateChartHistory     = rateChartHistory
      ..filePicked           = filePicked
      ..name                 = name
      ..maximumBuffaloFat    = maximumBuffaloFat
      ..maximumBuffaloSNF    = maximumBuffaloSNF
      ..maximumBuffaloRate   = maximumBuffaloRate
      ..minimumBuffaloFat    = minimumBuffaloFat
      ..minimumBuffaloSNF    = minimumBuffaloSNF
      ..minimumBuffaloRate   = minimumBuffaloRate
      ..localMilkSaleBuffalo = localMilkSaleBuffalo;
  }

  // ────────────────────────────────────────────────────────────────────────
  // Manually override limit values at runtime
  Future<void> setValues(
      double minimumBuffaloFat,
      double minimumBuffaloSNF,
      double minimumBuffaloRate,
      double maximumBuffaloFat,
      double maximumBuffaloSNF,
      double maximumBuffaloRate,
      ) async {
    this.minimumBuffaloFat  = minimumBuffaloFat;
    this.minimumBuffaloSNF  = minimumBuffaloSNF;
    this.minimumBuffaloRate = minimumBuffaloRate;

    this.maximumBuffaloFat  = maximumBuffaloFat;
    this.maximumBuffaloSNF  = maximumBuffaloSNF;
    this.maximumBuffaloRate = maximumBuffaloRate;
    notifyListeners();
  }

  // Convenience getter for UI forms
  List<dynamic> getBuffaloValues() => [
    minimumBuffaloFat ?? "",
    minimumBuffaloSNF ?? "",
    minimumBuffaloRate ?? "",
    maximumBuffaloFat ?? "",
    maximumBuffaloSNF ?? "",
    maximumBuffaloRate ?? "",
  ];

  // Update Excel grid & history (called by UI when a cell is edited)
  void updateExcelData(List<List<String>> updatedExcelData, int row, int col) {
    excelData = updatedExcelData.map((r) => List<String>.from(r)).toList();
    rateChartHistory.add(
      RateChartInfo(
        note: 'Updated Rate chart',
        rateChart: updatedExcelData,
        row: row,
        col: col,
        date: DateTime.now().toIso8601String(),
      ),
    );

    // Keep only the latest 20 snapshots
    if (rateChartHistory.length > 20) {
      rateChartHistory.sort((a, b) => DateTime.parse(a.date).compareTo(DateTime.parse(b.date)));
      rateChartHistory.removeAt(0);
    }
    notifyListeners();
  }

  // ────────────────────────────────────────────────────────────────────────
  // Pick an Excel file and convert it to excelData
  Future<void> pickExcelFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['xlsx'],
    );

    if (result != null && result.files.single.path != null) {
      final filePath = result.files.single.path!;
      final bytes    = File(filePath).readAsBytesSync();
      final excel    = Excel.decodeBytes(bytes);

      name = result.files.single.name;
      excelData = [];
      for (final sheet in excel.tables.values) {
        for (final row in sheet!.rows) {
          excelData.add(row.map((c) => c?.value?.toString() ?? '').toList());
        }
      }

      if (searchValue("3.00")) {
        filePicked = true;
        rateChartHistory.add(
          RateChartInfo(
            note: 'New Rate chart',
            rateChart: excelData,
            row: row!,
            col: col!,
            date: DateTime.now().toIso8601String(),
          ),
        );
      }
      notifyListeners();
    }
  }

  // Search excelData for value, record row/col if found
  bool searchValue(String value) {
    for (int r = 0; r < excelData.length; r++) {
      for (int c = 0; c < excelData[r].length; c++) {
        if (excelData[r][c] == value) {
          row = r;
          col = c;
          return true;
        }
      }
    }
    return false;
  }

  // ────────────────────────────────────────────────────────────────────────
  // Calculate rate for given fat & snf
  double findRate(double fat, double snf) {
    if ((minimumBuffaloFat != null && minimumBuffaloSNF != null) &&
        (fat < minimumBuffaloFat! || snf < minimumBuffaloSNF!)) {
      return minimumBuffaloRate!;
    }
    if ((maximumBuffaloFat != null && maximumBuffaloSNF != null) &&
        (fat > maximumBuffaloFat! || snf > maximumBuffaloSNF!)) {
      return maximumBuffaloRate!;
    }

    // Offset calculation relative to the position where 3.00 fat / 8.00 SNF was found
    final excelRow = row! + ((fat - 3) * 10).round();
    final excelCol = col! + 1 + ((snf - 8) * 10).round();

    return double.parse(excelData[excelRow][excelCol]);
  }
}