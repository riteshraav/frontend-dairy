import 'dart:collection';

import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:pdf/widgets.dart';
import '../model/Customer.dart';
import '../model/cattleFeedSell.dart';
import '../model/deduction.dart';
import '../model/milk_collection.dart';
import '../widgets/appbar.dart';
import '../model/admin.dart';

class LedgerReportGeneration{
  Map<String,Map<String,List<CattleFeedSell>>> cattleFeedSellMap = {}; //first key is customerCode e.g. "12" and second key is monthYear e.g.  01-01-2025
  List<CattleFeedSell> cattleFeedSellList = [];
  String fromDate,toDate;
  LedgerReportGeneration(this.cattleFeedSellList,this.fromDate,this.toDate);
  var sortedMap = {};
  double currentCustomerTotalBalance = 0;
  double currentCustomerDeduction = 0;
  List<Customer> customerList = CustomWidgets.allCustomers();
  DateTime _convert(String date) {
    return DateTime.parse(
      date.replaceAllMapped(
        RegExp(r"(\d+)([a-zA-Z]+)(\d+)"),
            (m) => "${m[3]}-${_month(m[2]!)}-${m[1]!.padLeft(2, '0')}",
      ),
    );
  }


  String _month(String shortMonth) {
    const months = {
      "jan": "01", "feb": "02", "mar": "03", "apr": "04",
      "may": "05", "jun": "06", "jul": "07", "aug": "08",
      "sep": "09", "oct": "10", "nov": "11", "dec": "12"
    };
    return months[shortMonth.toLowerCase()]!;
  }
  String generateMonthKey(String isoDate) {
    DateTime date = DateTime.parse(isoDate);
    return "${_twoDigits(1)}-${_twoDigits(date.month)}-${date.year}"; // "01-01-2025"
  }
  String? findCustomerName(String customerId) {
    String? name = customerList.any((customer) => customer.code == customerId)
        ? customerList.firstWhere((customer) => customer.code == customerId).name
        : "";
    return name;
  }
  String _twoDigits(int n) => n.toString().padLeft(2, '0');
  DateTime getDateFromKey(String key) {
    // Key is in format "01-01-2025"
    List<String> parts = key.split("-");
    int day = int.parse(parts[0]);
    int month = int.parse(parts[1]);
    int year = int.parse(parts[2]);
    return DateTime(year, month, day); // returns DateTime(2025, 1, 1)
  }
  void forMatData(){
    for(CattleFeedSell cattleFeedSell in cattleFeedSellList){
      cattleFeedSellMap.putIfAbsent(cattleFeedSell.customerId!, ()=>{});
      String dateKey = generateMonthKey(cattleFeedSell.date!);
      cattleFeedSellMap[cattleFeedSell.customerId!]!.putIfAbsent(dateKey, ()=>[]);
      cattleFeedSellMap[cattleFeedSell.customerId!]![dateKey]!.add(cattleFeedSell);
    }
    for(String customerId in cattleFeedSellMap.keys)
    {
      for(String dateKey in cattleFeedSellMap[customerId]!.keys)
      {
        cattleFeedSellMap[customerId]![dateKey]!.sort((a,b)=> DateTime.parse(a.date!).compareTo(DateTime.parse(b.date!)));
      }
      final sortedInnerMap = SplayTreeMap<String, List<CattleFeedSell>>(
            (a, b) => getDateFromKey(a).compareTo(getDateFromKey(b)),
      );

      sortedInnerMap.addAll(cattleFeedSellMap[customerId]!);
      cattleFeedSellMap[customerId]!.clear();
      cattleFeedSellMap[customerId]!.addAll(sortedInnerMap);
    }
    final sortedMap = SplayTreeMap<String, Map<String,List<CattleFeedSell>>>.from(
      cattleFeedSellMap,
          (a, b) => int.parse(a).compareTo(int.parse(b)), // ascending
    );
    cattleFeedSellMap.clear();
    cattleFeedSellMap.addAll(sortedMap);
    printFormattedData();
  }
  void printFormattedData() {
    for (var customerId in cattleFeedSellMap.keys) {
      print("Customer ID: $customerId");
      for (var dateKey in cattleFeedSellMap[customerId]!.keys) {
        print("  Month Key: $dateKey");
        for (var sell in cattleFeedSellMap[customerId]![dateKey]!) {
          print("    Sell Date: ${sell.date} | Quantity: ${sell.quantity}"); // adjust fields as needed
        }
      }
    }
  }

  String extractDate(dynamic date) {
    try {
      DateTime dateTime;
      if (date is String) {
        // Parse the string and handle invalid formats
        dateTime = DateTime.parse(date);
      } else if (date is DateTime) {
        dateTime = date;
      } else {
        throw FormatException("Unsupported date format");
      }
      // Format the date as day/month/year
      return '${dateTime.day.toString().padLeft(2, '0')}/'
          '${dateTime.month.toString().padLeft(2, '0')}/'
          '${dateTime.year}';
    } catch (e) {
      return "Invalid Date";
    }
  }
  Admin admin = CustomWidgets.currentAdmin();
  Future<Document> generate() async {
    final pdf = Document();
    forMatData();
    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a3.applyMargin(
          left: 0,
          right: 0,
          top: 0,
          bottom: 0,
        ),
        header: (context) => pw.Center(
            child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children:
                [
                  pw.Text(
                    "${admin.dairyName} Ledger Report",
                    style: pw.TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                  ),
                ]
            )
        ),
        build: (context) => buildTable(),
      ),
    );
    return pdf;
  }

  List<pw.Widget> buildTable() {
    List<pw.Widget> widgets = [];
    widgets.add(pw.SizedBox(height: 10));
    for(String customerId in cattleFeedSellMap.keys)
    {
      final customerMap = cattleFeedSellMap[customerId]!;
      widgets.add(pw.Center(
        child: pw.Column(children: [
          pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceAround,
              children: [
                pw.Text("Name : $customerId-${findCustomerName(customerId)}",),
                pw.Text("Period : ${extractDate(fromDate)} - ${extractDate(toDate)}"),
                pw.Text('Date : ${extractDate(DateTime.now())}')
              ]),
          pw.SizedBox(height: 10,),
        ]),

      ));
      widgets.add(buildTableHeader());
      for(String dateKey in customerMap.keys)
      {
        widgets.addAll(buildMonthTotals(customerMap[dateKey]!));
      }
      widgets.addAll(buildFooter(currentCustomerDeduction,currentCustomerTotalBalance));
    }
    return widgets;
  }

  pw.Widget buildTableHeader()
  {
    return pw.Table(
      border: pw.TableBorder.all(),
      columnWidths: {
        0: pw.FixedColumnWidth(20),
        1: pw.FixedColumnWidth(80), // Customer Info (Fixed width)
        2: pw.FixedColumnWidth(30), // Morning (Fixed width)
        3: pw.FixedColumnWidth(30), // Evening (Fixed width)
        4: pw.FixedColumnWidth(30), // Evening (Fixed width)
      },
      children: [
        // Main Header Row
        pw.TableRow(
          decoration: pw.BoxDecoration(color: PdfColors.grey300),
          children: [
            pw.Container(
              padding: pw.EdgeInsets.all(5),
              alignment: pw.Alignment.center,
              child: pw.Text('Date',
                  style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
            ),
            pw.Container(
              padding: pw.EdgeInsets.all(5),
              alignment: pw.Alignment.center,
              child: pw.Text('Information',
                  style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
            ),
            pw.Container(
              padding: pw.EdgeInsets.all(5),
              alignment: pw.Alignment.center,
              child: pw.Text('Deduction',
                  style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
            ),
            pw.Container(
              padding: pw.EdgeInsets.all(5),
              alignment: pw.Alignment.center,
              child: pw.Text('Balance',
                  style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
            ),
            pw.Container(
              padding: pw.EdgeInsets.all(5),
              alignment: pw.Alignment.center,
              child: pw.Text('Total Balance',
                  style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
            ),

          ],
        ),

      ],
    );
  }



  List<pw.Widget> buildMonthTotals(List<CattleFeedSell> cattleFeedSellList)
  {
    List<pw.Widget> list = [];
    double totalDeductionForMonth = 0;
    double totalBalanceForMonth = 0;
    for(CattleFeedSell c in cattleFeedSellList)
    {
      totalBalanceForMonth += c.totalAmount!;
      totalDeductionForMonth += c.deduction!;
      list.add( pw.Table(
        border: pw.TableBorder(
            left: pw.BorderSide(),
            right: pw.BorderSide(),
            verticalInside: pw.BorderSide()
        ),

        columnWidths: {
          0: pw.FixedColumnWidth(20),
          1: pw.FixedColumnWidth(80), // Customer Info (Fixed width)
          2: pw.FixedColumnWidth(30), // Morning (Fixed width)
          3: pw.FixedColumnWidth(30), // Evening (Fixed width)
          4: pw.FixedColumnWidth(30), // Evening (Fixed width)
        },
        children: [
          // Main Header Row
          pw.TableRow(
            children: [
              pw.Container(
                padding: pw.EdgeInsets.all(5),
                alignment: pw.Alignment.center,
                child: pw.Text(extractDate(c.date!),
                    style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
              ),
              pw.Container(
                padding: pw.EdgeInsets.all(5),
                alignment: pw.Alignment.center,
                child: pw.Text((c.modeOfPayback == "Deduction")?"":"${c.feedName}-${c.quantity}",
                    style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
              ),
              pw.Container(
                padding: pw.EdgeInsets.all(5),
                alignment: pw.Alignment.center,
                child: pw.Text(c.deduction == 0 ? "":c.deduction.toString(),
                    style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
              ),
              pw.Container(
                padding: pw.EdgeInsets.all(5),
                alignment: pw.Alignment.center,
                child: pw.Text(c.totalAmount == 0?"":c.totalAmount.toString(),
                    style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
              ),
              pw.Container(
                padding: pw.EdgeInsets.all(5),
                alignment: pw.Alignment.center,
                child: pw.Text(c.totalCattleFeedBalance.toString(),
                    style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
              ),

            ],
          ),

        ],
      ));
    }
    list.add(pw.Table(
      border: pw.TableBorder.all(),
      columnWidths: {
        0: pw.FixedColumnWidth(20),
        1: pw.FixedColumnWidth(80), // Customer Info (Fixed width)
        2: pw.FixedColumnWidth(30), // Morning (Fixed width)
        3: pw.FixedColumnWidth(30), // Evening (Fixed width)
        4: pw.FixedColumnWidth(30), // Evening (Fixed width)
      },
      children: [
        // Main Header Row
        pw.TableRow(
          children: [
            pw.Container(
              padding: pw.EdgeInsets.all(5),
              alignment: pw.Alignment.center,
              child: pw.Text("",
                  style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
            ),
            pw.Container(
              padding: pw.EdgeInsets.all(5),
              alignment: pw.Alignment.center,
              child: pw.Text("${DateFormat.MMMM().format(DateTime.parse(cattleFeedSellList[0].date!))}",

                  style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
            ),
            pw.Container(
              padding: pw.EdgeInsets.all(5),
              alignment: pw.Alignment.center,
              child: pw.Text("$totalDeductionForMonth",
                  style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
            ),
            pw.Container(
              padding: pw.EdgeInsets.all(5),
              alignment: pw.Alignment.center,
              child: pw.Text("$totalBalanceForMonth",
                  style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
            ),
            pw.Container(
              padding: pw.EdgeInsets.all(5),
              alignment: pw.Alignment.center,
              child: pw.Text("",
                  style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
            ),

          ],
        ),

      ],
    ));
    currentCustomerDeduction += totalDeductionForMonth;
    currentCustomerTotalBalance += totalBalanceForMonth;

    return list;
  }
}
List<pw.Widget> buildFooter(double deduction,double customerBalance){
  List<Widget> list = [];
  list.add(pw.Table(
    border: pw.TableBorder.all(),
    columnWidths: {
      0: pw.FixedColumnWidth(20),
      1: pw.FixedColumnWidth(80), // Customer Info (Fixed width)
      2: pw.FixedColumnWidth(30), // Morning (Fixed width)
      3: pw.FixedColumnWidth(30), // Evening (Fixed width)
      4: pw.FixedColumnWidth(30), // Evening (Fixed width)
    },
    children: [
      // Main Header Row
      pw.TableRow(
        children: [
          pw.Container(
            padding: pw.EdgeInsets.all(5),
            alignment: pw.Alignment.center,
            child: pw.Text("",
                style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
          ),
          pw.Container(
            padding: pw.EdgeInsets.all(5),
            alignment: pw.Alignment.center,
            child: pw.Text("",

                style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
          ),
          pw.Container(
            padding: pw.EdgeInsets.all(5),
            alignment: pw.Alignment.center,
            child: pw.Text(deduction.toString(),
                style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
          ),
          pw.Container(
            padding: pw.EdgeInsets.all(5),
            alignment: pw.Alignment.center,
            child: pw.Text(customerBalance.toString(),
                style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
          ),
          pw.Container(
            padding: pw.EdgeInsets.all(5),
            alignment: pw.Alignment.center,
            child: pw.Text("",
                style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
          ),

        ],
      ),

    ],
  ));

  return list;
}