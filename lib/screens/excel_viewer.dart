import 'package:DairySpace/model/buffalo_rate_data.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:provider/provider.dart';
import '../../widgets/appbar.dart';
import '../model/admin.dart';
import '../model/cow_rate_data.dart';
import '../model/ratechartinfo.dart';
import '../providers/buffalo_ratechart_provider.dart';
import '../providers/cow_ratechart_provider.dart';

class ExcelViewer extends StatefulWidget {
  final String excelType;
  ExcelViewer(this.excelType);

  @override
  _ExcelViewerState createState() => _ExcelViewerState();
}

class _ExcelViewerState extends State<ExcelViewer> {
  List<List<String>> originalExcel = [];
  List<List<String>> excel= [];
  late int curRow;
  late int originalRow;
  late int originalCol;
  late int curCol;
  bool isLoading = false;
  bool _excelData = false;
  bool _hasChanges = false;
  bool isAdjusting = false;
  TextEditingController _adjustController = TextEditingController();
  int? _selectedColumnIndex;
  int? _selectedRowIndex;
  bool? _isChangeEntire;
  final Map<String, List<List<String>>> _rateHistory = {};
  bool fromHistory = false;
  Admin admin = CustomWidgets.currentAdmin();
  @override
  void initState() {
    super.initState();
    setState(() {
      isLoading = true;
    });
    _initializeExcelData();
    setState(() {
      isLoading = false;
    });
  }

  void _initializeExcelData() {

    setState(() {
      if(widget.excelType == "cow") {
        var cowBox =  Hive.box<CowRateData>('cowBox');
        CowRateData cowRateData = cowBox.get('cowRateData_${admin.id}') ?? CowRateData();
     excel = cowRateData.excelData;
        curRow =cowRateData.row;
        curCol = cowRateData.col;
        _excelData = true;
      }
      else{
        var buffaloBox =  Hive.box<BuffaloRateData>('buffaloBox');
        BuffaloRateData buffaloRateData = buffaloBox.get('buffaloRateData_${admin.id}') ?? BuffaloRateData();
        excel = buffaloRateData.excelData;
        curRow =buffaloRateData.row!;
        curCol = buffaloRateData.col!;
        _excelData = true;
      }
      originalRow = curRow;
      originalCol = curCol;
      originalExcel =  excel.map((subList) => List<String>.from(subList)).toList();

      _hasChanges = false;
      _selectedColumnIndex = null;
      _selectedRowIndex = null;
      _isChangeEntire = null;
      _rateHistory.clear();

    });

  }
  RateChartInfo? selectedRateChart;
  void _showAdjustmentOptionDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDialogState) {
          bool tempChoice = true;
          return AlertDialog(
            title: Text("Select Adjustment Mode"),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                RadioListTile(
                  title: Text("Change Entire Rate Table"),
                  value: true,
                  groupValue: tempChoice,
                  onChanged: (value) => setDialogState(() => tempChoice = value!),
                ),
                RadioListTile(
                  title: Text("Change Specific Rate Only"),
                  value: false,
                  groupValue: tempChoice,
                  onChanged: (value) => setDialogState(() => tempChoice = value!),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(),
                child: Text("Cancel"),
              ),
              CustomWidgets.customButton(
                text: "Ok",
                onPressed: () {
                  setState(() {
                    _isChangeEntire = tempChoice;
                    isAdjusting = true;
                  });
                  Navigator.of(ctx).pop();
                },
              ),
            ],
          );
        },
      ),
    );
  }
  void _applyAdjustment(int row, int col,List<List<String>> excelToBeUpdated) {
    if ( _adjustController.text.trim().isEmpty) return;
      double? adjustment = double.tryParse(_adjustController.text.trim());
    if (adjustment == null) return;
    for (int i = 0; i < excelToBeUpdated.length; i++) {
      if(i == row)continue;
      for (int j = 0; j < excelToBeUpdated[i].length; j++) {
        if(col == j)
        {
          continue;
        }
        bool shouldAdjust = false;

        if (_isChangeEntire == true) {
          shouldAdjust = true;
        } else {
          if (_selectedColumnIndex != null && j == _selectedColumnIndex) {
            shouldAdjust = true;
          }
          if (_selectedRowIndex != null && i == _selectedRowIndex) {
            shouldAdjust = true;
          }
        }

        if (shouldAdjust) {
          String cellValue = excelToBeUpdated[i][j].trim().replaceAll(RegExp(r'[^\d\.\-]'), '');
          double? original = double.tryParse(cellValue);
          if (original != null) {
            double adjusted = original + adjustment;
            excelToBeUpdated[i][j] = adjusted.toStringAsFixed(2);
          }
        }
        setState(() {
          _adjustController.clear();
          _hasChanges = true;
          fromHistory = false;
        });
      }
    }


    setState(() {
      excel = excelToBeUpdated;
      _hasChanges = true;
      _isChangeEntire = false;
      isAdjusting = false;
    });
    return;
  }
  Future<void> _handleManualBack(BuildContext context) async {
    if(!_hasChanges) {
      Navigator.pop(context);
      return;
    }
    bool? shouldPop = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Are you sure?'),
        content: Text('Save changes?'),
        actions: [
         Row(
           mainAxisAlignment: MainAxisAlignment.spaceAround,
           children: [
             TextButton(
               onPressed: () => Navigator.of(context).pop(false),
               child: Text('Cancel'),
             ),
             SizedBox(width: 10),
             CustomWidgets.customButton(text: "Discard",onPressed: (){
               Navigator.of(context).pop(true);
             },buttonBackgroundColor: Colors.redAccent ),
             SizedBox(width: 10),
             CustomWidgets.customButton(text: "Save",onPressed: (){
               saveChanges();
               Navigator.of(context).pop(true);
             },),
           ],

         )
        ],
      ),
    );

    if (shouldPop == true) {
      Navigator.of(context).pop(); // Pop with or without result
    }
  }
  void _showHistoryDialog() {
    List<RateChartInfo> rateChartHistory = [];
    if (widget.excelType == 'cow') {
      rateChartHistory = Provider.of<CowRateChartProvider>(context, listen: false)
          .rateChartHistory;
    } else {
      rateChartHistory = Provider.of<BuffaloRatechartProvider>(context, listen: false)
          .rateChartHistory;
    }

    // Sort history by date (newest first)
    rateChartHistory.sort((a, b) => b.date.compareTo(a.date));

    showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text("View History"),
              content: rateChartHistory.isNotEmpty
                  ? SizedBox(
                height: 300,
                width: double.maxFinite,
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: rateChartHistory.length,
                  itemBuilder: (context, index) {
                    final rateChart = rateChartHistory[index];
                    final isSelected = rateChart == selectedRateChart;
                    return ListTile(
                      title: Text(
                        "${CustomWidgets.extractDate(rateChart.date)} - ${rateChart.note}",
                        style: TextStyle(
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                        ),
                      ),
                      tileColor: isSelected ? Colors.blue.shade100 : null,
                      onTap: () {
                        setState(() {
                          selectedRateChart = rateChart;
                        });
                      },
                    );
                  },
                ),
              )
                  : Text("No history available."),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(ctx).pop(),
                  child: Text("Close"),
                ),
                CustomWidgets.customButton(
                  text: "Select",
                  onPressed: selectedRateChart == null
                      ? () {}
                      : () {
                    // Update the excel data with the selected historical data
                    setState(() {
                      excel = selectedRateChart!.rateChart
                          .map((row) => List<String>.from(row))
                          .toList();
                      curRow = selectedRateChart!.row;
                      curCol = selectedRateChart!.col;
                      _hasChanges = true;
                      fromHistory = true;
                    });
                    Navigator.of(ctx).pop();
                  },
                ),
              ],
            );
          },
        );
      },
    );
  }
  void _saveChangesDialog() {
    if (!_hasChanges) return;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text("Save Confirmation"),
        content: Text("Are you sure you want to save the changes?"),
        actions: [
          TextButton(onPressed: () => Navigator.of(ctx).pop(), child: Text("Cancel")),
          // ElevatedButton(
          //   onPressed: () {
          //     Navigator.of(ctx).pop();
          //     saveChanges();
          //     ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Changes saved!")));
          //   },
          //
          //   child: Text("Save"),
          // )
          CustomWidgets.customButton(text: "save", onPressed: (){
            Navigator.of(ctx).pop();
            saveChanges();
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Changes Saved !")));
          },

          )
        ],
      ),
    );
  }
  void saveChanges(){
    if(widget.excelType == 'cow'){
      Provider.of<CowRateChartProvider>(context,listen: false).updateExcelData(excel,curRow,curCol);
    }
    else{
      Provider.of<BuffaloRatechartProvider>(context,listen: false).updateExcelData(excel,curRow,curCol);
    }
    setState(() {
      _hasChanges = false;
    });
  }
  Widget _buildRateTable(List<List<String>> excelData) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: Table(
          border: TableBorder.all(color: Colors.black12),
          defaultColumnWidth: IntrinsicColumnWidth(),
          children: excelData.asMap().entries.map((entry) {
            final rowIndex = entry.key;
            final row = entry.value;
            return TableRow(
              children: row.asMap().entries.map((cell) {
                final colIndex = cell.key;
                final isHeader = rowIndex == 0;
                final isSelected =
                    (isHeader && colIndex == _selectedColumnIndex) || (!isHeader && rowIndex == _selectedRowIndex);
                final isFatColumn = colIndex == 0;

                return GestureDetector(
                  onTap: () => setState(() {
                    _selectedColumnIndex = isHeader ? colIndex : null;
                    _selectedRowIndex = isHeader ? null : rowIndex;
                  }),
                  child: Container(
                    padding: EdgeInsets.all(8),
                    color: isHeader
                        ? (isSelected ? Colors.orange[200] : Color(0xFFe3f3fb))
                        : (isFatColumn
                        ? Colors.yellow[100]
                        : (isSelected ? Colors.lightBlue[50] : Colors.white)),
                    alignment: Alignment.center,
                    child: Text(
                      cell.value,
                      style: TextStyle(fontWeight: isHeader ? FontWeight.bold : FontWeight.normal),
                    ),
                  ),
                );
              }).toList(),
            );
          }).toList(),
        ),
      ),
    );
  }
  Widget cowExcelProvider(){

    return Consumer<CowRateChartProvider>(
        builder:(context,proider,child){
          return (_excelData )?Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(10),
                child: isAdjusting
                    ? Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _adjustController,
                        keyboardType: TextInputType.numberWithOptions(decimal: true),
                        decoration: InputDecoration(
                          labelText: 'Adjustment (+/-)',
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                    SizedBox(width: 10),
                    CustomWidgets.customButton(text: "Apply", onPressed:()=> _applyAdjustment(curRow-1,curCol,excel)),
                  ],
                )
                    : CustomWidgets.customButton(
                    text: 'Adjust Rate', onPressed: (){
                      setState(() {
                        _isChangeEntire = true;
                        isAdjusting = true;
                      });
                }),
              ),
              SizedBox(height: 10),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("File: ${proider.name}", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
                      SizedBox(height: 10),
                      Expanded(
                        child: Container(
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.black26),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: _buildRateTable(excel),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ):
          Center(child: Text("Rate chart is not uploaded ",
          style: TextStyle(fontWeight: FontWeight.bold),
          ));
        }
    );
  }
  Widget buffaloExcelProvider(){
    return Consumer<BuffaloRatechartProvider>(
        builder:(context,proider,child){
          return (proider.filePicked )?Column(
            children: [

              Padding(
                padding: const EdgeInsets.all(10),
                child: isAdjusting
                    ? Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _adjustController,
                        keyboardType: TextInputType.numberWithOptions(decimal: true),
                        decoration: InputDecoration(
                          labelText: 'Adjustment (+/-)',
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                    SizedBox(width: 10),
                    CustomWidgets.customButton(text: "Apply", onPressed:()=> _applyAdjustment(curRow-1,curCol,proider.excelData)),
                  ],
                )
                    : CustomWidgets.customButton(
                    text: 'Adjust Rate', onPressed: _showAdjustmentOptionDialog),
              ),
              SizedBox(height: 10),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("File: ${proider.name}", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
                      SizedBox(height: 10),
                      Expanded(
                        child: Container(
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.black26),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: _buildRateTable(proider.excelData),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ):
          Text("Rate chart is not uploaded ");
        }
    );
  }
  @override
  Widget build(BuildContext context) {
    return PopScope(
   canPop: false,
      onPopInvokedWithResult: (didPop,result)async{
        if (!didPop) {
         await _handleManualBack(context);
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text("Rate Viewer", style: TextStyle(color: Colors.white)),
          backgroundColor: Color(0xFF24A1DE),
          leading: IconButton(
            icon: Icon(Icons.arrow_back, color: Colors.white),
            onPressed: ()=>_handleManualBack(context),
          ),
          actions: [
            IconButton(icon: Icon(Icons.history, color: Colors.white), onPressed: _showHistoryDialog),
            if (_hasChanges) IconButton(icon: Icon(Icons.save, color: Colors.white), onPressed: _saveChangesDialog),
          ],
        ),
        body: Stack(
          children: [
            (widget.excelType == 'cow')?cowExcelProvider():buffaloExcelProvider(),
            if (isLoading)
              Positioned.fill(
                child: Container(
                  color: Colors.black.withOpacity(0.3),
                  child: Center(child: CircularProgressIndicator()),
                ),
              ),
          ],
        ),
      ),
    );
  }
}