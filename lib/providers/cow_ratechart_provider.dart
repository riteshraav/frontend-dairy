import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:excel/excel.dart';
import 'package:hive/hive.dart';
import 'package:take8/model/cow_rate_data.dart';
import '../model/ratechartinfo.dart';

/// CowRateChartProvider
/// --------------------
/// Maintains the cow‑rate chart, its Excel grid, and the six limit values
/// (min/max fat, SNF, and fallback rate).
///
/// *Default limits baked into the code as requested:*
///   * Minimum – Fat *2.0, SNF **7.50, Rate **20.30*
///   * Maximum – Fat *5.0, SNF **9.0,  Rate **33.80*
///
/// The limits can still be overridden at runtime with setValues().
@HiveType(typeId: 11)
class CowRateChartProvider extends ChangeNotifier {
  // ────────────────────────────────────────────────────────────────────────
  // Excel data & meta
  List<List<String>> excelData = [];
  bool filePicked = false;
  List<RateChartInfo> rateChartHistory = [];

  int? row;
  int? col;
  String name = "";

  // ────────────────────────────────────────────────────────────────────────
  // Limit values (defaults)
  double? minimumCowFat   = 2.0;
  double? minimumCowSNF   = 7.50;
  double? minimumCowRate  = 20.30;

  double? maximumCowFat   = 5.0;
  double? maximumCowSNF   = 9.0;
  double? maximumCowRate  = 33.80;

  double localMilkSaleCow = 0;

  // ────────────────────────────────────────────────────────────────────────
  // Constructor – lets you override defaults if needed
  CowRateChartProvider({
    this.row,
    this.col,
    this.name = "",
    double? minimumCowFat,
    double? minimumCowSNF,
    double? minimumCowRate,
    double? maximumCowFat,
    double? maximumCowSNF,
    double? maximumCowRate,
    this.localMilkSaleCow = 0,
  }) {
    if (minimumCowFat   != null) this.minimumCowFat   = minimumCowFat;
    if (minimumCowSNF   != null) this.minimumCowSNF   = minimumCowSNF;
    if (minimumCowRate  != null) this.minimumCowRate  = minimumCowRate;
    if (maximumCowFat   != null) this.maximumCowFat   = maximumCowFat;
    if (maximumCowSNF   != null) this.maximumCowSNF   = maximumCowSNF;
    if (maximumCowRate  != null) this.maximumCowRate  = maximumCowRate;
  }

  // ────────────────────────────────────────────────────────────────────────
  // Manually override limits at runtime
  Future<void> setValues(
      double minimumCowFat,
      double minimumCowSNF,
      double minimumCowRate,
      double maximumCowFat,
      double maximumCowSNF,
      double maximumCowRate,
      ) async {
    this.minimumCowFat   = minimumCowFat;
    this.minimumCowSNF   = minimumCowSNF;
    this.minimumCowRate  = minimumCowRate;

    this.maximumCowFat   = maximumCowFat;
    this.maximumCowSNF   = maximumCowSNF;
    this.maximumCowRate  = maximumCowRate;
    notifyListeners();
  }

  // Convenience getter for UI forms
  List<dynamic> getCowValues() => [
    minimumCowFat ?? "",
    minimumCowSNF ?? "",
    minimumCowRate ?? "",
    maximumCowFat ?? "",
    maximumCowSNF ?? "",
    maximumCowRate ?? "",
  ];

  // ────────────────────────────────────────────────────────────────────────
  // Hydrate provider from Hive model
  void updateAll(CowRateData data) {
    excelData            = data.excelData;
    rateChartHistory     = data.rateChartHistory ?? [];
    filePicked           = data.filePicked;
    name                 = data.name;

    minimumCowFat        = data.minimumCowFat;
    minimumCowSNF        = data.minimumCowSNF;
    minimumCowRate       = data.minimumCowRate;
    maximumCowFat        = data.maximumCowFat;
    maximumCowSNF        = data.maximumCowSNF;
    maximumCowRate       = data.maximumCowRate;

    localMilkSaleCow     = data.morningQuantity;
    notifyListeners();
  }

  // Convert current state to a CowRateData object
  CowRateData toCowRateData() {
    return CowRateData()
      ..excelData          = excelData
      ..rateChartHistory   = rateChartHistory
      ..filePicked         = filePicked
      ..name               = name
      ..minimumCowFat      = minimumCowFat
      ..minimumCowSNF      = minimumCowSNF
      ..minimumCowRate     = minimumCowRate
      ..maximumCowFat      = maximumCowFat
      ..maximumCowSNF      = maximumCowSNF
      ..maximumCowRate     = maximumCowRate
      ..morningQuantity    = localMilkSaleCow;
  }

  // ────────────────────────────────────────────────────────────────────────
  // Update Excel grid & take a snapshot
  void updateExcelData(List<List<String>> updated, int row, int col) {
    excelData = updated.map((r) => List<String>.from(r)).toList();
    rateChartHistory.add(
      RateChartInfo(
        note: 'Updated Rate chart',
        rateChart: updated,
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

  // Retrieve a specific snapshot (by ISO date string)
  void retrieveFromRateChartHistory(String date) {
    excelData = rateChartHistory.firstWhere((e) => e.date == date).rateChart;
    notifyListeners();
  }

  // ────────────────────────────────────────────────────────────────────────
  // File picker → Excel → excelData
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

      if (searchValue("2.00")) {
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

  // Locate the first cell containing value and store row/col
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
    if ((fat < (minimumCowFat ?? 0)) || (snf < (minimumCowSNF ?? 0))) {
      return minimumCowRate!;
    }
    if ((fat > (maximumCowFat ?? double.infinity)) || (snf > (maximumCowSNF ?? double.infinity))) {
      return maximumCowRate!;
    }

    final excelRow = row! + ((fat - 2) * 10).round();
    final excelCol = col! + 1 + ((snf - 7.5) * 10).round();

    return double.parse(excelData[excelRow][excelCol]);
  }
}