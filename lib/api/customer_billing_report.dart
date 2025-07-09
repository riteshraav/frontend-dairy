import 'dart:collection';
//import 'dart:ffi';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;

import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:pdf/widgets.dart';
import '../model/deduction.dart';
import '../model/milk_collection.dart';
import '../model/CustomerBalance.dart';
import '../model/Customer.dart';
import '../model/admin.dart';

class Combination {
  List<double> totals = [0.0, 0.0, 0.0, 0.0, 0.0]; // [Quantity, Fat, SNF, Total Value, Entries]
  // Morning & Evening Data
  int morningEntries = 0;
  int eveningEntries = 0;
  double morningQuantity = 0.0;
  double eveningQuantity = 0.0;
  double morningTotalValue = 0.0;
  double eveningTotalValue = 0.0;

  // Morning & Evening Averages
  double morningFatSum = 0.0, eveningFatSum = 0.0;
  double morningSnfSum = 0.0, eveningSnfSum = 0.0;
  double morningRateSum = 0.0, eveningRateSum = 0.0;

  // Overall Averages
  double get avgMorningFat => morningEntries == 0 ? 0.0 : morningFatSum / morningEntries;
  double get avgEveningFat => eveningEntries == 0 ? 0.0 : eveningFatSum / eveningEntries;
  double get avgMorningSnf => morningEntries == 0 ? 0.0 : morningSnfSum / morningEntries;
  double get avgEveningSnf => eveningEntries == 0 ? 0.0 : eveningSnfSum / eveningEntries;
  double get avgMorningRate => morningEntries == 0 ? 0.0 : morningRateSum / morningEntries;
  double get avgEveningRate => eveningEntries == 0 ? 0.0 : eveningRateSum / eveningEntries;

  double get avgFat => (morningEntries + eveningEntries) == 0
      ? 0.0
      : (morningFatSum + eveningFatSum) / (morningEntries + eveningEntries);
  double get avgSnf => (morningEntries + eveningEntries) == 0
      ? 0.0
      : (morningSnfSum + eveningSnfSum) / (morningEntries + eveningEntries);
  double get avgRate => (morningEntries + eveningEntries) == 0
      ? 0.0
      : (morningRateSum + eveningRateSum) / (morningEntries + eveningEntries);

  Map<String, List<MilkCollection>> customerData = {}; // Date-wise collection
}

class CustomerBillingReport
{
  final List<MilkCollection> milkCollectionList;
  Admin admin;
  List<Customer> customerList;
  DateTime fromDate;
  DateTime toDate;
  List<Deduction> deductionList;
  List<CustomerBalance> customerBalanceList;
  Map<String,Map<String,Map<String,String>>> dateMap = {};
  double totalBuffaloQuantity = 0;
  double totalBuffaloFat = 0;
  double totalBuffaloSNF = 0;
  double totalBuffaloAmount = 0;
  double totalBuffaloCustomer = 0;
  double totalCowQuantity = 0;
  double totalCowFat = 0;
  double totalCowSNF = 0;
  double totalCowAmount = 0;
  double totalCowCustomer = 0;
  double totalAmount = 0;
  double totalQuantity = 0;
  Map<String,dynamic> customerBalanceMapSingle ={};
  var customerDeduction = Deduction(adminId:"", customerId:"");
  CustomerBillingReport(this.milkCollectionList, this.admin, this.customerList,this.fromDate, this.toDate,this.deductionList,this.customerBalanceList);
  Map<String,String> deductionField ={
    "cattleFeed":"Cattle Feed",
    'advance': "Advance",
    'creditMilk': "Credit Milk",
    'loan': "Loan",
    'otherExpense': "Other Expense",
    'doctorVisitFees': "Doctor Visit Fees",
    'expense': "Expense",
    'Total':"Total"

  };
  CustomerBalance currentCustomerBalance = CustomerBalance(adminId: "dummy", customerId: "dummy") ;
  Map<String,dynamic> currentCustomerBalanceMap = {};
  Map<String,String> customerBalanceFields ={
    "cattleFeed":"balanceCattleFeed",
    'advance': "balanceAdvance",
    'creditMilk': "balanceCreditMilk",
    'loan': "balanceLoan",
    'otherExpense': "balanceOtherExpense",
    'doctorVisitFees': "balanceDoctorVisitingFees",
    'expense': "balanceExpense",
    'total':'totalBalance'
  };
  Map<String,Map<String,dynamic>> customerBalanceMap = {};
  Map<String,Deduction> deductionMap = {};
  var customerDeductionMap = {};
  List<String> fieldList = [];
  int i = 0;

  /// Extracts and formats a date.
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

  String? findCustomerName(String customerId) {
    String? name = customerList.any((customer) => customer.code == customerId)
        ? customerList.firstWhere((customer) => customer.code == customerId).name
        : "";
    return name;
  }

  void formatData(){
    for(CustomerBalance c in customerBalanceList)
      {
        customerBalanceMap[c.customerId] = c.toJson();
      }
    var d = Deduction(adminId: admin.id!, customerId: "");

    for(var field in d.toJson().keys)
    {
      if(!['adminId', 'customerId', 'date','total'].contains(field))
        fieldList.add(field);

    }
    for(var deduction in deductionList)
    {
      var prevDeduction = Deduction(adminId: admin.id!, customerId: deduction.customerId);
      bool isContains = deductionMap.containsKey(deduction.customerId);
      if(isContains)
      {
        prevDeduction = deductionMap[deduction.customerId]??Deduction(adminId: admin.id!, customerId: deduction.customerId);
      }
      Map<String,dynamic> map = prevDeduction.toJson();
      for(var entry in deduction.toJson().entries)
      {
        if(!(["adminId","customerId","date"].contains(entry.key)))
        {
          map[entry.key] = map[entry.key]??0 + entry.value??0;
        }

      }
      var updatedDeduction = Deduction.fromJson(map);
      deductionMap[deduction.customerId] = updatedDeduction;

    }
  }
  Map<String, Map<String, Combination>> groupByDate(List<MilkCollection> milkCollections) {

    Map<String, Map<String, Combination>> customerSeparation = {};

    for (var milk in milkCollections) {
      // Ensure customer exists in map
      customerSeparation.putIfAbsent(milk.customerId!, () => {});
      var milkTypeMap = customerSeparation[milk.customerId!]!;

      // Ensure milk type exists
      milkTypeMap.putIfAbsent(milk.milkType!, () => Combination());
      var combination = milkTypeMap[milk.milkType!]!;

      // Extract Date & Shift (Assuming shift is stored in milk.shift or inferred from time)
      String date = extractDate(milk.date);
      bool isMorning = milk.time == "Morning"; // Replace with actual logic

      // Update totals
      combination.totals[0] += milk.quantity!;
      combination.totals[3] += milk.totalValue!;

      // Update shift-based values
      if (isMorning) {
        combination.morningEntries++;
        combination.morningQuantity += milk.quantity!;
        combination.morningTotalValue += milk.totalValue!;
        combination.morningFatSum += milk.fat!;
        combination.morningSnfSum += milk.snf!;
        combination.morningRateSum += milk.rate!;
      } else {
        combination.eveningEntries++;
        combination.eveningQuantity += milk.quantity!;
        combination.eveningTotalValue += milk.totalValue!;
        combination.eveningFatSum += milk.fat!;
        combination.eveningSnfSum += milk.snf!;
        combination.eveningRateSum += milk.rate!;
      }

      // Store date-wise collection
      combination.customerData.putIfAbsent(date, () => []);
      combination.customerData[date]!.add(milk);
    }

    // Print Data
    for (var customer in customerSeparation.keys) {
      print("Customer: $customer");
      for (var milkType in customerSeparation[customer]!.keys) {
        var combination = customerSeparation[customer]![milkType]!;

        print("  🥛 Milk Type: $milkType");
        print("    📊 Morning -> Entries: ${combination.morningEntries}, Quantity: ${combination.morningQuantity}, Total Value: ${combination.morningTotalValue}");
        print("    📊 Evening -> Entries: ${combination.eveningEntries}, Quantity: ${combination.eveningQuantity}, Total Value: ${combination.eveningTotalValue}");

        print("    🔢 Averages:");
        print("      - Morning Fat: ${combination.avgMorningFat}, SNF: ${combination.avgMorningSnf}, Rate: ${combination.avgMorningRate}");
        print("      - Evening Fat: ${combination.avgEveningFat}, SNF: ${combination.avgEveningSnf}, Rate: ${combination.avgEveningRate}");
        print("      - Overall Fat: ${combination.avgFat}, SNF: ${combination.avgSnf}, Rate: ${combination.avgRate}");

        print("    📅 Daily Breakdown:");
        for (var date in combination.customerData.keys) {
          print("      - Date: $date");
          for (var entry in combination.customerData[date]!) {
            print("        - ${entry.toString()}");
          }
        }
      }
    }
    var sortedEntries = customerSeparation.entries.toList()
      ..sort((a, b) => int.parse(a.key).compareTo(int.parse(b.key)));

    // Rebuild sorted map
    Map<String, Map<String, Combination>> sortedMap = Map.fromEntries(sortedEntries);
    return sortedMap;
  }



  Future<Document> generate() async {

    final pdf = Document();
    final data = groupByDate(milkCollectionList);
    formatData();
    print("${customerBalanceList.length}//////////////////////////////////////");
    for(var c in customerBalanceList)
      {
        print(c.toJson());
      }
    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a3.applyMargin(
          left: 0,
          right: 0,
          top: 0,
          bottom: 0,
        ),
        header: (context) => pw.Center(
            child: pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.center,
                children:
                [
                  pw.Text(
                    "${admin.dairyName} Milk Collection Report",
                    style: pw.TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                  ),
                  pw.SizedBox(height: 10)
                ]
            )
        ),
        build: (context) => buildTable(data),
      ),
    );
    return pdf;
  }

  List<pw.Widget> buildTable(
      Map<String, Map<String, Combination>> list) {
    List<pw.Widget> widgets = [];
    for (var entry in list.entries) {
      currentCustomerBalance = CustomerBalance.formJson(customerBalanceMap[entry.key] ?? customerBalanceMapSingle);
      currentCustomerBalanceMap = currentCustomerBalance.toJson();
       customerDeduction = deductionMap[entry.key] ?? Deduction(adminId: admin.id!, customerId: entry.key);
      customerDeductionMap = customerDeduction.toJson();
      i = 0;
      entry.value.entries.forEach((customerCollection) {
        widgets.add(pw.SizedBox(height: 10));
        widgets.add(pw.Center(
          child: pw.Column(children: [
            pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceAround,
                children: [
                  pw.Text("Name : ${entry.key}-${findCustomerName(entry.key)}",),
                  pw.Text("Type : ${customerCollection.key}"),
                  pw.Text("Period : ${extractDate(fromDate)} - ${extractDate(toDate)}"),

                ]),
            pw.SizedBox(height: 10,),
          ]),

        ));
        widgets.add(buildTableHeader(customerCollection.key));

        for (var collection in customerCollection.value.customerData.entries) {
          widgets.add(buildInvoice(collection,entry.key, customerCollection.key,i));
          if(dateMap[entry.key] != null) {
            dateMap[entry.key]![customerCollection.key]?.remove(dateMap[entry.key]![customerCollection.key]!.keys.first);
          }
          print('in loop i is $i');
          i = i + 1;
        }
        print('out of loop i is $i' );
        i = i +1;
        widgets.add(buildFirstFooter(customerCollection.value));
        widgets.add(buildSecondFooter(customerCollection.value,entry.key));
        widgets.add(pw.NewPage());
      });
    }

    return widgets;
  }

  pw.Widget buildTableHeader(String milkType) {
    return pw.Table(
      border: pw.TableBorder.all(),
      columnWidths: {
        0: pw.FixedColumnWidth(15),
        1: pw.FixedColumnWidth(110), // Customer Info (Fixed width)
        2: pw.FixedColumnWidth(110), // Morning (Fixed width)
        3: pw.FixedColumnWidth(160), // Evening (Fixed width)
      },
      children: [
        // Main Header Row
        pw.TableRow(
          decoration: pw.BoxDecoration(color: PdfColors.grey300),
          children: [
            pw.Container(
              padding: pw.EdgeInsets.all(5),
              alignment: pw.Alignment.center,
              child: pw.Text('D',
                  style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
            ),
            pw.Container(
              padding: pw.EdgeInsets.all(5),
              alignment: pw.Alignment.center,
              child: pw.Text('Morning',
                  style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
            ),
            pw.Container(
              padding: pw.EdgeInsets.all(5),
              alignment: pw.Alignment.center,
              child: pw.Text('Evening',
                  style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
            ),
            pw.Container(
              padding: pw.EdgeInsets.all(5),
              alignment: pw.Alignment.center,
              child: pw.Text('Deduction Information',
                  style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
            ),

          ],
        ),

        // Sub Header Row

        pw.TableRow(
          children: [
            pw.Table(
              columnWidths: {
                0: pw.FixedColumnWidth(21),
              },
              border: pw.TableBorder.all(),
              children: [
                pw.TableRow(children: [

                ]),
              ],
            ),            pw.Table(
              columnWidths: {
                0: pw.FixedColumnWidth(20), // Fat
                1: pw.FixedColumnWidth(20), // SNF
                2: pw.FixedColumnWidth(20), // Rate
                3: pw.FixedColumnWidth(20),
                4: pw.FixedColumnWidth(30), // Total
              },
              border: pw.TableBorder.all(),
              children: [
                pw.TableRow(children: [
                  for (var header in ['Qty', 'Fat', 'SNF', 'Rate', 'Total'])
                    pw.Container(
                      height: 22,
                      alignment: pw.Alignment.center,
                      child: pw.Text(header,
                          style: pw.TextStyle(
                              fontSize: 9, fontWeight: pw.FontWeight.bold)),
                    ),
                ]),
              ],
            ),

            // Evening Section (4 Subheaders)
            pw.Table(
              columnWidths: {
                0: pw.FixedColumnWidth(20), // Fat
                1: pw.FixedColumnWidth(20), // SNF
                2: pw.FixedColumnWidth(20), // Rate
                3: pw.FixedColumnWidth(20),
                4: pw.FixedColumnWidth(30) // Total
              },
              border: pw.TableBorder.all(),
              children: [
                pw.TableRow(
                    verticalAlignment: pw.TableCellVerticalAlignment.middle,
                    children: [
                      for (var header in ['Qty', 'Fat', 'SNF', 'Rate', 'Total'])
                        pw.Container(
                          height: 22,
                          alignment: pw.Alignment.center,
                          child: pw.Text(header,
                              style: pw.TextStyle(
                                  fontSize: 9, fontWeight: pw.FontWeight.bold)),
                        ),
                    ]),
              ],
            ),
            pw.Table(
              columnWidths: {
                0: pw.FixedColumnWidth(50),
                1: pw.FixedColumnWidth(30),
                2: pw.FixedColumnWidth(25),
                3: pw.FixedColumnWidth(25),
                4: pw.FixedColumnWidth(30)
              },
              border: pw.TableBorder.all(),
              children: [
                pw.TableRow(

                    verticalAlignment: pw.TableCellVerticalAlignment.middle,
                    children: [
                      for (var header in ['Type','Pre Bal','Deduct','Current','Balance'])
                        pw.Container(
                          height: 22,
                          alignment: pw.Alignment.center,
                          child: pw.Text(header,
                              style: pw.TextStyle(
                                  fontSize: 9, fontWeight: pw.FontWeight.bold)),
                        ),
                    ]),
              ],
            ),

          ],
        ),
      ],
    );
  }

  /// Build the invoice table
  pw.Widget buildInvoice(MapEntry<String, List<MilkCollection>> resolvedData, String code, String milkType,int i) {
    LinkedHashSet<String> dateSet = LinkedHashSet();
    // Collect unique dates
    for (var milk in resolvedData.value) {
      dateSet.add(extractDate(milk.date));
    }
    return pw.Table(
        border: pw.TableBorder.all(),
        columnWidths: {
          0: pw.FixedColumnWidth(15),  // Date Column
          1: pw.FixedColumnWidth(20),  // Morning Quantity
          2: pw.FixedColumnWidth(20),  // Morning Fat
          3: pw.FixedColumnWidth(20),  // Morning SNF
          4: pw.FixedColumnWidth(20),  // Morning Rate
          5: pw.FixedColumnWidth(30),  // Morning Total
          6: pw.FixedColumnWidth(20),  // Evening Quantity
          7: pw.FixedColumnWidth(20),  // Evening Fat
          8: pw.FixedColumnWidth(20),  // Evening SNF
          9: pw.FixedColumnWidth(20),  // Evening Rate
          10: pw.FixedColumnWidth(30), // Evening Total
          11: pw.FixedColumnWidth(50), // Code
          12: pw.FixedColumnWidth(30), // Name
          13: pw.FixedColumnWidth(25), // Name
          14: pw.FixedColumnWidth(25), // Name
          15: pw.FixedColumnWidth(30), // Name
        },
        children: [
          for (var date in dateSet)
            pw.TableRow(
              children: [
                // Date Column
                pw.Container(
                  height: 20,
                  alignment: pw.Alignment.center,
                  child: pw.Text(date.substring(0, 2), style: pw.TextStyle(fontSize: 9)),
                ),

                // Morning Data
                ...buildMilkData(resolvedData.value, date, "Morning"),

                // Evening Data
                ...buildMilkData(resolvedData.value, date, "Evening"),

                  ...buildDeductionField(i)
              ],
            )

        ]
    );

  }

// Function to build morning/evening data row with placeholders
  List<pw.Widget> buildMilkData(List<MilkCollection> milkData, String date, String time,) {
    var milk = milkData.firstWhere(
          (m) => extractDate(m.date) == date && m.time == time,
      orElse: () => MilkCollection(), // Returns an empty object if no data exists
    );

    List<pw.Widget> list = [
      pw.Container(
        height: 20,
        alignment: pw.Alignment.center,
        child: milk.customerId == null ? pw.Text("-", style: pw.TextStyle(fontSize: 9)) : pw.Text(milk.quantity.toString(), style: pw.TextStyle(fontSize: 9)),
      ),
      pw.Container(
        height: 20,
        alignment: pw.Alignment.center,
        child: milk.customerId == null ? pw.Text("-", style: pw.TextStyle(fontSize: 9)) : pw.Text(milk.fat.toString(), style: pw.TextStyle(fontSize: 9)),
      ),
      pw.Container(
        height: 20,
        alignment: pw.Alignment.center,
        child: milk.customerId == null? pw.Text("-", style: pw.TextStyle(fontSize: 9)) : pw.Text(milk.snf.toString(), style: pw.TextStyle(fontSize: 9)),
      ),
      pw.Container(
        height: 20,
        alignment: pw.Alignment.center,
        child: milk.customerId == null ? pw.Text("-", style: pw.TextStyle(fontSize: 9)) : pw.Text(milk.rate.toString(), style: pw.TextStyle(fontSize: 9)),
      ),
      pw.Container(
        height: 20,
        alignment: pw.Alignment.center,
        child: milk.customerId == null ? pw.Text("-", style: pw.TextStyle(fontSize: 9)) : pw.Text(milk.totalValue.toString(), style: pw.TextStyle(fontSize: 9)),
      ),

    ];
    return list;
  }
  List<pw.Widget> buildDeductionField(int i) {
    print('called build deduction for ${currentCustomerBalance.customerId}');
    String key = "";
    if(i < fieldList.length)
    {
      key = fieldList[i];
    }

    var prevBalance = (key != "")
        ? (
        ((currentCustomerBalanceMap[customerBalanceFields[key]] ?? 0) as num) +
            ((customerDeductionMap[key] == null) ? 0.0 : customerDeductionMap[key] as num)
    ).toString()
        : "";
    // Build PDF widgets from current iterator position
    return [
      pw.Container(
          height: 20,
          alignment: pw.Alignment.center,
          child:pw.Text((key != "") ? deductionField[key]??"":"", style: pw.TextStyle(fontSize: 9))),
      pw.Container(
          height: 20,
          alignment: pw.Alignment.center,
          child:pw.Text(prevBalance, style: pw.TextStyle(fontSize: 9))),
      pw.Container(
          height: 20,
          alignment: pw.Alignment.center,
          child:pw.Text((key != "") ? (customerDeductionMap[key]??0.0).toString():"", style: pw.TextStyle(fontSize: 9))),

      pw.Container(
          height: 20,
          alignment: pw.Alignment.center,
          child:pw.Text("", style: pw.TextStyle(fontSize: 9))),

      pw.Container(
          height: 20,
          alignment: pw.Alignment.center,
          child:pw.Text((key != "") ? (currentCustomerBalanceMap[customerBalanceFields[key]]??0.0).toString():"", style: pw.TextStyle(fontSize: 9))),
    ];
  }


  pw.Widget buildFirstFooter(Combination combo) {
    bool printDeduction = true;
    if(i >= fieldList.length + 1)
    {
      printDeduction = false;
    }
    return pw.Table(
      border: pw.TableBorder.all(),
      columnWidths: {
        0: pw.FixedColumnWidth(15),
        1: pw.FixedColumnWidth(110), // Customer Info (Fixed width)
        2: pw.FixedColumnWidth(110), // Morning (Fixed width)
        3: pw.FixedColumnWidth(160), // Evening (Fixed width)
        // Evening Total Value
      },
      children: [
        // Data Row

        pw.TableRow(
          children: [
            pw.Container(
              padding: pw.EdgeInsets.only(top: 1),
              alignment: pw.Alignment.center,
              child: pw.Text('T',
                  style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
            ),
            pw.Table(
              border: pw.TableBorder.all(),
              columnWidths: {
                0: pw.FixedColumnWidth(20),
                1: pw.FixedColumnWidth(20),
                2: pw.FixedColumnWidth(20),
                3: pw.FixedColumnWidth(20),
                4: pw.FixedColumnWidth(30),
              },
              children: [

                pw.TableRow(
                  children: [

                    pw.Container(
                      height: 20,
                      alignment: pw.Alignment.center,
                      child: pw.Text(combo.morningQuantity.toStringAsFixed(2), style: pw.TextStyle(fontSize: 9)),
                    ),
                    pw.Container(
                      height: 20,
                      alignment: pw.Alignment.center,
                      child: pw.Text("${combo.morningEntries == 0 ? 0.0:combo.avgMorningFat.toStringAsFixed(2)}", style: pw.TextStyle(fontSize: 9)),
                    ),
                    pw.Container(
                      height: 20,
                      alignment: pw.Alignment.center,
                      child: pw.Text("${combo.morningEntries == 0 ? 0.0:combo.avgMorningSnf.toStringAsFixed(2)}", style: pw.TextStyle(fontSize: 9)),
                    ),
                    pw.Container(
                      height: 20,
                      alignment: pw.Alignment.center,
                      child: pw.Text("${combo.morningEntries == 0 ? 0.0:combo.avgMorningRate.toStringAsFixed(2)}", style: pw.TextStyle(fontSize: 9)),
                    ),
                    pw.Container(
                      height: 20,
                      alignment: pw.Alignment.center,
                      child: pw.Text(combo.morningTotalValue.toStringAsFixed(2), style: pw.TextStyle(fontSize: 9)),
                    ),
                  ],
                ),
              ],
            ),
            pw.Table(
              border: pw.TableBorder.all(),
              columnWidths: {
                0: pw.FixedColumnWidth(20),
                1: pw.FixedColumnWidth(20),
                2: pw.FixedColumnWidth(20),
                3: pw.FixedColumnWidth(20),
                4: pw.FixedColumnWidth(30),
              },
              children: [

                pw.TableRow(
                  children: [

                    pw.Container(
                      height: 20,
                      alignment: pw.Alignment.center,
                      child: pw.Text(combo.eveningQuantity.toStringAsFixed(2), style: pw.TextStyle(fontSize: 9)),
                    ),
                    pw.Container(
                      height: 20,
                      alignment: pw.Alignment.center,
                      child: pw.Text("${combo.eveningEntries == 0 ? 0.0:combo.avgEveningFat.toStringAsFixed(2)}", style: pw.TextStyle(fontSize: 9)),
                    ),
                    pw.Container(
                      height: 20,
                      alignment: pw.Alignment.center,
                      child: pw.Text("${combo.eveningEntries == 0 ? 0.0:combo.avgEveningSnf.toStringAsFixed(2)}", style: pw.TextStyle(fontSize: 9)),
                    ),
                    pw.Container(
                      height: 20,
                      alignment: pw.Alignment.center,
                      child: pw.Text("${combo.eveningEntries == 0 ? 0.0:combo.avgEveningRate.toStringAsFixed(2)}", style: pw.TextStyle(fontSize: 9)),
                    ),
                    pw.Container(
                      height: 20,
                      alignment: pw.Alignment.center,
                      child: pw.Text(combo.eveningTotalValue.toStringAsFixed(2), style: pw.TextStyle(fontSize: 9)),
                    ),
                  ],
                ),
              ],
            ),
            pw.Table(
              defaultVerticalAlignment: pw.TableCellVerticalAlignment.middle,
              border: pw.TableBorder.all(),
              columnWidths: {
                0: pw.FixedColumnWidth(50), // Code
                1: pw.FixedColumnWidth(30), // Code
                2: pw.FixedColumnWidth(25), // Code
                3: pw.FixedColumnWidth(25), // Code
                4: pw.FixedColumnWidth(30), // Code
              },
              children: [
                pw.TableRow(children: [
                  pw.Container(
                    alignment: pw.Alignment.center,
                    padding: pw.EdgeInsets.all(3),
                    child: pw.Text("Total"), // Code
                  ),
                  pw.Container(
                    alignment: pw.Alignment.center,
                    padding: pw.EdgeInsets.all(3),
                    child: pw.Text(printDeduction?"${(currentCustomerBalance.totalBalance ?? 0) + (customerDeduction.total ?? 0)}":""),
                  ),
                  pw.Container(
                    alignment: pw.Alignment.center,
                    padding: pw.EdgeInsets.all(3),
                    child: pw.Text(printDeduction?(customerDeduction.total ?? 0).toStringAsFixed(2):""), // Code
                  ),
                  pw.Container(
                    alignment: pw.Alignment.center,
                    padding: pw.EdgeInsets.all(3),
                    child: pw.Text(""), // Code
                  ),
                  pw.Container(
                    alignment: pw.Alignment.center,
                    padding: pw.EdgeInsets.all(3),
                    child: pw.Text(printDeduction? "${currentCustomerBalance.totalBalance??0.0}":""), // Code
                  ),

                ]),
              ],
            ),
          ],
        ),
      ],
    );
  }

  pw.Widget buildSecondFooter(Combination combo,String code)
  {
    bool printDeduction = true;
    if(i >= fieldList.length+1)
    {
      printDeduction = false;
    }
    return pw.Table(
      border: pw.TableBorder.all(),
      columnWidths: {
        0: pw.FixedColumnWidth(100), // Customer Info (Fixed width)
      },
      children: [
        pw.TableRow(
          children: [
            pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Column(
                      mainAxisAlignment: pw.MainAxisAlignment.start,
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Container(
                          padding: pw.EdgeInsets.all(5),
                          height: 20,
                          alignment: pw.Alignment.center,
                          child:   pw.Text("Total Quantity : ${combo.totals[0].toStringAsFixed(2)}"),
                        ),
                        pw.Container(
                            height: 20,
                            padding: pw.EdgeInsets.all(5),
                            alignment: pw.Alignment.center,
                            child: pw.Text("Total Amount : ${(combo.morningTotalValue + combo.eveningTotalValue).toStringAsFixed(2)}")
                        ),


                      ]
                  ),
                  pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      mainAxisAlignment: pw.MainAxisAlignment.start,
                      children: [
                        pw.Container(
                          height: 20,
                          padding: pw.EdgeInsets.all(5),
                          alignment: pw.Alignment.center,
                          child:   pw.Text("Total Deduction : ${printDeduction?customerDeduction.total??0.0 : ""}"),
                        ),
                        pw.Container(
                            height: 20,
                            padding: pw.EdgeInsets.all(5),
                            alignment: pw.Alignment.center,
                          child: pw.Text("Total Payable Amount : ${((combo.morningTotalValue ?? 0) + (combo.eveningTotalValue ?? 0) - (printDeduction?(customerDeduction.total ?? 0):0)).toStringAsFixed(2)}"),
                        ),
                      ]
                  )
                ]
            )
          ],
        ),
      ],
    );
  }
}

