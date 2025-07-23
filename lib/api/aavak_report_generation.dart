import 'dart:collection';
//import 'dart:ffi';
import 'dart:io';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:pdf/widgets.dart';
import '../model/milk_collection.dart';
import '../model/Customer.dart';
import '../model/admin.dart';
import '../widgets/appbar.dart';

class Combination {
  List<double> totals = [0, 0, 0, 0, 0, 0];
  Map<String, List<MilkCollection>> customerData = {};
}

class PdfInvoiceApi {
  final List<MilkCollection> milkCollectionList;
  Admin admin;
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
  PdfInvoiceApi(this.milkCollectionList, this.admin);
  List<Customer> customers = CustomWidgets.allCustomers();
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
    String? name = customers.any((customer) => customer.code == customerId)
        ? customers.firstWhere((customer) => customer.code == customerId).name
        : "";
    return name;
  }


  Map<String, Map<String, Combination>> groupByDate(
      List<MilkCollection> milkCollections) {
    Map<String, Map<String, Combination>> dateSeparation = {};

    for (var milk in milkCollections) {
      String date = extractDate(milk.date!);

      // Ensure the date key exists
      dateSeparation.putIfAbsent(date, () => {});
      var milkTypeMap = dateSeparation[date]!;

      // Ensure the milk type key exists
      milkTypeMap.putIfAbsent(milk.milkType!, () => Combination());
      var combination = milkTypeMap[milk.milkType!]!;

      // Update totals
      combination.totals[0] += milk.quantity!;
      combination.totals[1] += milk.totalValue!;

      // Group customer data
      combination.customerData.putIfAbsent(milk.customerId!, () => []);
      combination.customerData[milk.customerId]!.add(milk);
    }

    // Pretty-print the grouped data
    print("\n📊 Milk Collection Data Grouped by Date:\n");
    for (var date in dateSeparation.keys) {
      print("📅 Date: $date");
      for (var milkType in dateSeparation[date]!.keys) {
        var combination = dateSeparation[date]![milkType]!;

        print("  🥛 Milk Type: $milkType");
        print(
            "    📊 Totals -> Quantity: ${combination.totals[0]}, Fat: ${combination.totals[1]}, SNF: ${combination.totals[2]}, Total Value: ${combination.totals[3]}, Entries: ${combination.totals[4]}");

        for (var customerId in combination.customerData.keys) {
          print("    👤 Customer ID: $customerId");
          print("      📌 Detailed Entries:");
          for (var entry in combination.customerData[customerId]!) {
            print("        - ${entry.toString()}");
          }
        }
      }
    }
    final sortedEntries = dateSeparation.entries.toList()
      ..sort((a, b) {
        try {
          final dateFormat = DateFormat('dd/MM/yyyy');
          final dateA = dateFormat.parse(a.key);
          final dateB = dateFormat.parse(b.key);
          return dateA.compareTo(dateB);
        } catch (e) {
          return 0; // or handle the error as appropriate for your case
        }
      });
    return Map.fromEntries(sortedEntries);
  }

  Future<Document> generate() async {
    final pdf = Document();
    final data = groupByDate(milkCollectionList);

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a3.applyMargin(
          left: 0,
          right: 0,
          top: 0,
          bottom: 0,
        ),
        header: (context) => pw.Center(
          child: pw.Text(
            "${admin.dairyName} Milk Collection Report ",
            style: pw.TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
          ),
        ),
        build: (context) => buildTable(data),
      ),
    );
    return pdf;
  }

  List<pw.Widget> buildTable(
      Map<String, Map<String, Combination>> list) {
    List<pw.Widget> widgets = [];
    list.entries.forEach((entry) {
      entry.value.entries.forEach((customerCollection) {
        widgets.add(pw.SizedBox(height: 10));
        widgets.add(pw.Center(
          child: pw.Column(children: [
            pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceAround,
                children: [
                  pw.Text("${entry.key}   ${customerCollection.key}",
                      style: pw.TextStyle(fontWeight: FontWeight.bold, fontSize: 18))
                ]),
            pw.SizedBox(height: 10,),
            pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceAround,
                children: [
                  pw.Text("Total Milk : ${customerCollection.value.totals[0].toStringAsFixed(2)}"),
                  pw.Text("Total Amount : ${customerCollection.value.totals[1].toStringAsFixed(2)}")
                ]),
            pw.SizedBox(height: 10,),

          ]),

        ));
        widgets.add(buildTableHeader());
        customerCollection.value.customerData.entries.forEach((customerCollection){
          widgets.add(buildInvoice(customerCollection));
        });
        widgets.add(pw.NewPage());
      });
    });

    return widgets;
  }

  pw.Widget buildTableHeader() {
    return pw.Table(
      border: pw.TableBorder.all(),
      columnWidths: {
        0: pw.FixedColumnWidth(160), // Customer Info (Fixed width)
        1: pw.FixedColumnWidth(110), // Morning (Fixed width)
        2: pw.FixedColumnWidth(110), // Evening (Fixed width)
      },
      children: [
        // Main Header Row
        pw.TableRow(
          decoration: pw.BoxDecoration(color: PdfColors.grey300),
          children: [
            pw.Container(
              padding: pw.EdgeInsets.all(5),
              alignment: pw.Alignment.center,
              child: pw.Text('Customer Info',
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
          ],
        ),

        // Sub Header Row
        pw.TableRow(
          children: [
            pw.Table(
              columnWidths: {
                0: pw.FixedColumnWidth(20), // Code
                1: pw.FixedColumnWidth(90), // Name
              },
              border: pw.TableBorder.all(),
              children: [
                pw.TableRow(children: [
                  pw.Container(
                    height: 22,
                    alignment: pw.Alignment.center,
                    child: pw.Text('Code',
                        style: pw.TextStyle(
                            fontSize: 7, fontWeight: pw.FontWeight.bold)),
                  ),
                  pw.Container(
                    padding: pw.EdgeInsets.all(5),
                    height: 22,
                    alignment: pw.Alignment.center,
                    child: pw.Text('Name',
                        style: pw.TextStyle(
                            fontSize: 10, fontWeight: pw.FontWeight.bold)),
                  ),
                ]),
              ],
            ),

            // Morning Section (4 Subheaders)
            pw.Table(
              columnWidths: {
                0: pw.FixedColumnWidth(21), // Fat
                1: pw.FixedColumnWidth(21), // SNF
                2: pw.FixedColumnWidth(21), // Rate
                3: pw.FixedColumnWidth(21),
                4: pw.FixedColumnWidth(30) // Total
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
                0: pw.FixedColumnWidth(21), // Fat
                1: pw.FixedColumnWidth(21), // SNF
                2: pw.FixedColumnWidth(21), // Rate
                3: pw.FixedColumnWidth(21),
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
          ],
        ),
      ],
    );
  }

  /// Build the invoice table
  pw.Widget buildInvoice(MapEntry<String, List<MilkCollection>> resolvedData) {
    // Extract unique dates
    LinkedHashSet<String> dateSet = LinkedHashSet();
    for (var milk in resolvedData.value) {
      dateSet.add(extractDate(milk.date));
    }

    return pw.Table(
      border: pw.TableBorder.all(),
      columnWidths: {
        0: pw.FixedColumnWidth(80), // Customer Info
        1: pw.FixedColumnWidth(110), // Morning
        2: pw.FixedColumnWidth(110), // Evening
      },
      children: [
        // Main Header Row
        pw.TableRow(
          children: [
            // Customer Info Data
            pw.Table(
              defaultVerticalAlignment: pw.TableCellVerticalAlignment.middle,
              border: pw.TableBorder.all(),
              columnWidths: {
                0: pw.FixedColumnWidth(20), // Code
                1: pw.FixedColumnWidth(90), // Name
              },
              children: [
                pw.TableRow(children: [
                  pw.Container(
                    alignment: pw.Alignment.center,
                    padding: pw.EdgeInsets.all(3),
                    child: pw.Text(resolvedData.key!), // Code
                  ),
                  pw.Container(
                    alignment: pw.Alignment.center,
                    padding: pw.EdgeInsets.all(3),
                    child: pw.Text(findCustomerName(resolvedData.key)!), // Name
                  ),
                ]),
              ],
            ),

            // Data Table (Morning + Evening)
            pw.Table(
              border: pw.TableBorder.all(),
              columnWidths: {
                0: pw.FixedColumnWidth(42), // Morning Quantity
                1: pw.FixedColumnWidth(42), // Morning Fat
                2: pw.FixedColumnWidth(42), // Morning SNF
                3: pw.FixedColumnWidth(42), // Morning Rate
                4: pw.FixedColumnWidth(60), // Morning Total
                5: pw.FixedColumnWidth(42), // Evening Quantity
                6: pw.FixedColumnWidth(42), // Evening Fat
                7: pw.FixedColumnWidth(42), // Evening SNF
                8: pw.FixedColumnWidth(42), // Evening Rate
                9: pw.FixedColumnWidth(60), // Evening Total
              },
              children: [
                for (var date in dateSet)
                  pw.TableRow(
                    children: [
                      for (var time in ["Morning", "Evening"])
                        (() {
                          var milk = resolvedData.value.firstWhere(
                                (m) => extractDate(m.date) == date && m.time == time,
                            orElse: () => MilkCollection(),
                          );
                          return [
                            pw.Container(
                              height: 20,
                              alignment: pw.Alignment.center,
                              child: pw.Text((milk.quantity??'-').toString(), style: pw.TextStyle(fontSize: 9)),
                            ),
                            pw.Container(
                              height: 20,
                              alignment: pw.Alignment.center,
                              child: pw.Text((milk.fat??'-').toString(), style: pw.TextStyle(fontSize: 9)),
                            ),
                            pw.Container(
                              height: 20,
                              alignment: pw.Alignment.center,
                              child: pw.Text((milk.snf??'-').toString(), style: pw.TextStyle(fontSize: 9)),
                            ),
                            pw.Container(
                              height: 20,
                              alignment: pw.Alignment.center,
                              child: pw.Text((milk.rate??'-').toString(), style: pw.TextStyle(fontSize: 9)),
                            ),
                            pw.Container(
                              height: 20,
                              alignment: pw.Alignment.center,
                              child: pw.Text((milk.totalValue??'-').toString(), style: pw.TextStyle(fontSize: 9)),
                            ),
                          ];
                        })()
                    ].expand((e) => e).toList(),
                  ),
              ],
            ),
          ],
        ),
      ],
    );
  }
}
