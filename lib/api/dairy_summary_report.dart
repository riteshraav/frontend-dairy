
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:pdf/widgets.dart';
import '../model/deduction.dart';
import '../model/milk_collection.dart';
import '../widgets/appbar.dart';
import '../model/admin.dart';


class DairySummaryReport {
  Admin admin = CustomWidgets.currentAdmin();
  List<MilkCollection> milkCollectionList;
  Map<String,String> deductionField ={
    "cattleFeed":"Cattle Feed",
    'advance': "Advance",
    'creditMilk': "Credit Milk",
    'loan': "Loan",
    'otherExpense': "Other Expense",
    'doctorVisitFees': "Doctor Visit Fees",
    'expense': "Expense",
    'total': "Total",

  };
  List<Deduction> deductionList;
  DateTime fromDate;
  DateTime toDate;
  bool buffalo,cow;

  DairySummaryReport(this.milkCollectionList,this.deductionList,this.fromDate,this.toDate,this.buffalo,this.cow);
  List<double> cowInfo = [0,0,0,0];//0 morning quantity 1 morning value 2 evening quantity 3 evening value
  List<double> buffaloInfo = [0,0,0,0];
  Map<String ,double> deductionMap = {};
  void formatLists()
  {
      milkCollectionList.forEach((collection){
        if(collection.milkType == "cow")
          {
              if(collection.time == "Morning")
                {
                    cowInfo[0] += collection.quantity!;
                    cowInfo[1] += collection.totalValue!;

                }
              else{
                cowInfo[2] += collection.quantity!;
                cowInfo[3] += collection.totalValue!;
              }
          }
        else{
          if(collection.time == "Morning")
          {
            buffaloInfo[0] += collection.quantity!;
            buffaloInfo[1] += collection.totalValue!;

          }
          else{
            buffaloInfo[2] += collection.quantity!;
            buffaloInfo[3] += collection.totalValue!;
          }
        }

      });
      if(deductionList.isEmpty)
        {
            Deduction d = Deduction(adminId: "dummy", customerId: "dummy");
            for (var entry in d.toJson().entries) {
              if (!(["adminId", "customerId", "date","totalCattleFeedBalance"].contains(entry.key))) {
                deductionMap.update(
                    entry.key, (existingValue) => existingValue + entry.value,
                    ifAbsent: () => entry.value??0.0);
              }
            }
        }
      else {
        for (var deduction in deductionList) {
          for (var entry in deduction.toJson().entries) {
            if (!(["adminId", "customerId", "date","totalCattleFeedBalance"].contains(entry.key))) {
              deductionMap.update(
                  entry.key, (existingValue) => existingValue + entry.value,
                  ifAbsent: () => entry.value);
            }
          }
        }
      }
  }
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


  // String? findCustomerCode(String customerId) {
  //   String? code = customerList.any((customer) => customer.code == customerId)
  //       ? customerList.firstWhere((customer) => customer.id == customerId).code
  //       : "";
  //   return code;
  // }




  Future<Document> generate() async {
    formatLists();
    final pdf = Document();

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
                    "${admin.dairyName} Summary Report",
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
    widgets.add(pw.Center(
      child: pw.Column(children: [
        pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceAround,
            children: [
              pw.Text("${(cow)?"Cow":""} ${ (buffalo && cow)? "and":""}  ${(buffalo)?"Buffalo ":""}  "),
              pw.Text("Period : ${extractDate(fromDate)} - ${extractDate(toDate)}"),
              pw.Text("Date : ${extractDate(DateTime.now())}"),
            ]),
        pw.SizedBox(height: 10,),
        pw.Row(
          children:[
            pw.Table(
              columnWidths: {
                0: pw.FixedColumnWidth(60),
              },
              border: pw.TableBorder.all(),
              children: [
                pw.TableRow(children: [
                pw.Column(
                  children: [
                    pw.SizedBox(height: 49),
                    pw.Container(
                      padding: pw.EdgeInsets.all(5),
                      alignment: pw.Alignment.center,
                      child: pw.Text("Quantity",
                          style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                    ),
                    pw.Container(
                      padding: pw.EdgeInsets.all(5),
                      alignment: pw.Alignment.center,
                      child: pw.Text("Value",
                          style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                    ),
                  ]
                )

                ]),
              ],
            ),
            if(cow)
              buildTableHeader("Cow"),
            if(buffalo)
            buildTableHeader("Buffalo"),

          ]
        ),
        pw.Row(
          children:
            [
             // SizedBox(width: (buffalo && cow)? 360:60),
              pw.Table(
                border: pw.TableBorder.all(),
                columnWidths: {
                  0: FixedColumnWidth(360)
                },
                children: [
                  pw.TableRow(children: [
                    pw.SizedBox(height: 295,width: 360)
                  ])
                ]
              ),
              buildDeductionArea(),
            ]
        ),
        pw.Row(
          children: [
            buildFooter()
          ]
        )
      ]),

    ));
    //  widgets.add(buildTableHeader(customerCollection.key));

    return widgets;
  }

  pw.Widget buildTableHeader(String milkType) {
    List<double> currentList = (milkType == "cow")? cowInfo:buffaloInfo;
    return pw.Table(
      border: pw.TableBorder.all(),
      columnWidths: {
        0: pw.FixedColumnWidth(300),
      },
      children: [
        // Main Header Row
        pw.TableRow(
          decoration: pw.BoxDecoration(color: PdfColors.grey300),
          children: [

            pw.Container(
              padding: pw.EdgeInsets.all(5),
              alignment: pw.Alignment.center,
              child: pw.Text(milkType,
                  style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
            ),
          ],
        ),

        // Sub Header Row

        pw.TableRow(
          children: [
            pw.Column(
                children: [
                  pw.Table(
                    columnWidths: {
                      0: pw.FixedColumnWidth(21),
                      1:pw.FixedColumnWidth(21),
                      2:pw.FixedColumnWidth(21)
                    },
                    border: pw.TableBorder.all(),
                    children: [
                      pw.TableRow(children: [
                        pw.Container(
                          padding: pw.EdgeInsets.all(5),
                          alignment: pw.Alignment.center,
                          child: pw.Text("Morning",
                              style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                        ),
                        pw.Container(
                          padding: pw.EdgeInsets.all(5),
                          alignment: pw.Alignment.center,
                          child: pw.Text("Evening",
                              style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                        ),
                        pw.Container(
                          padding: pw.EdgeInsets.all(5),
                          alignment: pw.Alignment.center,
                          child: pw.Text("Total",
                              style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                        ),
                      ]),
                    ],
                  ),
                  pw.Table(
                    columnWidths: {
                      0: pw.FixedColumnWidth(21),
                      1:pw.FixedColumnWidth(21),
                      2:pw.FixedColumnWidth(21)
                    },
                    border: pw.TableBorder.all(),
                    children: [
                      pw.TableRow(children: [
                        pw.Container(
                          padding: pw.EdgeInsets.all(5),
                          alignment: pw.Alignment.center,
                          child: pw.Text(currentList[0].toStringAsFixed(2),
                              style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                        ),
                        pw.Container(
                          padding: pw.EdgeInsets.all(5),
                          alignment: pw.Alignment.center,
                          child: pw.Text(currentList[2].toStringAsFixed(2),
                              style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                        ),
                        pw.Container(
                          padding: pw.EdgeInsets.all(5),
                          alignment: pw.Alignment.center,
                          child: pw.Text((currentList[0] + currentList[2]).toStringAsFixed(2),
                              style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                        ),
                      ]),
                    ],
                  ),
                  pw.Table(
                    columnWidths: {
                      0: pw.FixedColumnWidth(21),
                      1:pw.FixedColumnWidth(21),
                      2:pw.FixedColumnWidth(21)
                    },
                    border: pw.TableBorder.all(),
                    children: [
                      pw.TableRow(children: [
                        pw.Container(
                          padding: pw.EdgeInsets.all(5),
                          alignment: pw.Alignment.center,
                          child: pw.Text(currentList[1].toStringAsFixed(2),
                              style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                        ),
                        pw.Container(
                          padding: pw.EdgeInsets.all(5),
                          alignment: pw.Alignment.center,
                          child: pw.Text(currentList[3].toStringAsFixed(2),
                              style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                        ),
                        pw.Container(
                          padding: pw.EdgeInsets.all(5),
                          alignment: pw.Alignment.center,
                          child: pw.Text((currentList[1] + currentList[1]).toStringAsFixed(2),
                              style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                        ),
                      ]),
                    ],
                  ),

                ]
            )

          ],
        ),
      ],
    );
  }


  pw.Widget buildFooter() {
    return pw.Table(
      border: pw.TableBorder.all(),
      columnWidths: {
        0: pw.FixedColumnWidth(260),
        1:pw.FixedColumnWidth(100),
        2:pw.FixedColumnWidth(120),
        3:pw.FixedColumnWidth(180)
      },
      children: [
        // Main Header Row
        pw.TableRow(
          children: [

              pw.Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  pw.Row(
                      children:
                      [
                        pw.Container(
                          padding: pw.EdgeInsets.all(5),
                          alignment: pw.Alignment.center,
                          child: pw.Text("${(buffalo)?"Buffalo":""} ${(buffalo && cow)? "+":""} ${(cow)?"Cow":""}",
                              style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                        ),
                        pw.Container(
                          padding: pw.EdgeInsets.all(5),
                          alignment: pw.Alignment.center,
                          child: pw.Text("Total Quantity",
                              style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                        ),
                      ]
                  ),
                  pw.Row(
                      children:
                      [
                        pw.Container(
                          padding: pw.EdgeInsets.all(5),
                          alignment: pw.Alignment.center,
                          child: pw.Text("${(buffalo)?"Buffalo":""} ${(buffalo && cow)? "+":""} ${(cow)?"Cow":""}",
                              style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                        ),
                        pw.Container(
                          padding: pw.EdgeInsets.all(5),
                          alignment: pw.Alignment.center,
                          child: pw.Text("Total Value",
                              style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                        ),
                      ]
                  ),

                ]
              ),
                pw.Column(
                    children:
                    [
                      pw.Row(
                          children:
                          [
                            pw.Container(
                              padding: pw.EdgeInsets.all(5),
                              alignment: pw.Alignment.center,
                              child: pw.Text((cowInfo[0] + cowInfo[2] + buffaloInfo[0] + buffaloInfo[2]).toStringAsFixed(2),
                                  style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                            ),

                          ]
                      ),
                      pw.Row(
                          children:
                          [
                            pw.Container(
                              padding: pw.EdgeInsets.all(5),
                              alignment: pw.Alignment.center,
                              child: pw.Text((cowInfo[1] + cowInfo[3] + buffaloInfo[1] + buffaloInfo[3]).toStringAsFixed(2),
                                  style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                            ),
                          ]
                      )
                    ]
                ),
            pw.Column(
                children: [
                  pw.Row(
                      children:
                      [
                        pw.Container(
                          padding: pw.EdgeInsets.all(5),
                          alignment: pw.Alignment.center,
                          child: pw.Text("Net Payment",
                              style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                        ),

                      ]
                  ),
                ]
            ),

            pw.Column(
                children: [
                  pw.Row(
                      children:
                      [
                        pw.Container(
                          padding: pw.EdgeInsets.all(5),
                          alignment: pw.Alignment.center,
                          child: pw.Text(( cowInfo[1] + cowInfo[3] + buffaloInfo[1] + buffaloInfo[3] - deductionMap["total"]!).toStringAsFixed(2),
                              style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                        ),

                      ]
                  ),
                ]
            )





          ],
        ),



      ],
    );
  }

  pw.Widget buildDeductionArea() {

    return pw.Table(
      border: pw.TableBorder.all(),

      columnWidths: {
        0: pw.FixedColumnWidth(300),
      },
      children: [
        // Main Header Row
        pw.TableRow(
          decoration: pw.BoxDecoration(color: PdfColors.grey300),
          children: [
            pw.Container(
              padding: pw.EdgeInsets.all(5),
              alignment: pw.Alignment.center,
              child: pw.Text("Deduction Information",
                  style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
            ),
          ],
        ),

        pw.TableRow(
          children: [
            pw.Column(
                children: [
                  pw.Table(
                    columnWidths: {
                      0: pw.FixedColumnWidth(40),
                      1:pw.FixedColumnWidth(60),

                    },
                    border: pw.TableBorder.all(),
                    children: [
                      for(var entry in deductionMap.entries)
                        pw.TableRow(children: [
                          pw.Padding(
                            padding: pw.EdgeInsets.all(10),
                            child:  pw.Text(deductionField[entry.key]!,),
                          ),
                          pw.Padding(
                              padding: pw.EdgeInsets.all(10),
                              child:  pw.Text(entry.value.toStringAsFixed(2))
                          )
                        ])
                    ],
                  ),

                ]
            )
          ],
        ),

      ],
    );
  }


}
