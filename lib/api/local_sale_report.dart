
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:pdf/widgets.dart';

import '../model/localsale.dart';
import '../model/admin.dart';
import '../widgets/appbar.dart';


class LocalSaleReport {
  final List<LocalMilkSale> localMilkSaleList;
  final DateTime fromDate;
  final DateTime toDate;
  final bool buffalo;
  final bool cow;
  Admin admin = CustomWidgets.currentAdmin();
  LocalSaleReport(this.localMilkSaleList, this.fromDate,this.toDate, this.buffalo,this.cow);
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
List<LocalMilkSale> formatData(List<LocalMilkSale> list)
{
  list.sort((a, b) => DateTime.parse(a.date).compareTo(DateTime.parse(b.date)));
  return list;
}

String findTime(String date)
{
  if(DateTime.parse(date).hour < 12)
    {
        return 'M';
    }
  else{
    return 'E';
  }
}

  Future<Document> generate() async {
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
          child: pw.Text(
            "${admin.dairyName} Local Milk Sale Report ",
            style: pw.TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
          ),
        ),
        build: (context) => buildTable(formatData(localMilkSaleList)),
      ),
    );
    return pdf;
  }

  List<pw.Widget> buildTable(List<LocalMilkSale> list) {
    List<pw.Widget> widgets = [];
    widgets.addAll([SizedBox(height:10),Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          Text("Period : ${extractDate(fromDate)} - ${extractDate(toDate)}"),
          Text("Date : ${extractDate(DateTime.now())}"),
        ]
    ),SizedBox(height:10)]);
    widgets.add(buildTableHeader());
    print('here we starting adding list');

    for (var sale in list) {
      print('sale is : ${sale.id}');
      widgets.add(buildInvoice(sale));
    }
    print('end of while loop');

    return widgets;
  }

  pw.Widget buildTableHeader() {
    return pw.Table(
      border: pw.TableBorder.all(),
      columnWidths: {
        0: pw.FixedColumnWidth(1), // Customer Info (Fixed width)
        1: pw.FixedColumnWidth(1), // Morning (Fixed width)
        2: pw.FixedColumnWidth(1), // Evening (Fixed width)
        3: pw.FixedColumnWidth(1), // Evening (Fixed width)
        4: pw.FixedColumnWidth(1), // Evening (Fixed width)
        5: pw.FixedColumnWidth(1), // Evening (Fixed width)
        6: pw.FixedColumnWidth(1), // Evening (Fixed width)
        7: pw.FixedColumnWidth(1), // Evening (Fixed width)
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
              child: pw.Text('Code',
                  style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
            ),
            pw.Container(
              padding: pw.EdgeInsets.all(5),
              alignment: pw.Alignment.center,
              child: pw.Text('Milk type',
                  style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
            ),
            pw.Container(
              padding: pw.EdgeInsets.all(5),
              alignment: pw.Alignment.center,
              child: pw.Text('Time',
                  style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
            ),
            pw.Container(
              padding: pw.EdgeInsets.all(5),
              alignment: pw.Alignment.center,
              child: pw.Text('Payment Type',
                  style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
            ),pw.Container(
              padding: pw.EdgeInsets.all(5),
              alignment: pw.Alignment.center,
              child: pw.Text('Qty',
                  style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
            ),
            pw.Container(
              padding: pw.EdgeInsets.all(5),
              alignment: pw.Alignment.center,
              child: pw.Text('Rate',
                  style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
            ),
            pw.Container(
              padding: pw.EdgeInsets.all(5),
              alignment: pw.Alignment.center,
              child: pw.Text('Amount',
                  style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
            ),
          ],
        ),

      ],
    );
  }

  /// Build the invoice table
  pw.Widget buildInvoice(LocalMilkSale sale) {
    return pw.Table(
      border: pw.TableBorder.all(),
      columnWidths: {
        0: pw.FixedColumnWidth(1), // Customer Info
        1: pw.FixedColumnWidth(1), // Morning
        2: pw.FixedColumnWidth(1), // Evening
        3: pw.FixedColumnWidth(1), // Evening
        4: pw.FixedColumnWidth(1), // Evening
        5: pw.FixedColumnWidth(1), // Evening
        6: pw.FixedColumnWidth(1), // Evening
        7: pw.FixedColumnWidth(1), // Evening
      },
      children: [
        pw.TableRow(
          children:[
            pw.Container(
              height: 20,
              alignment: pw.Alignment.center,
              child: pw.Text((extractDate(sale.date)??'-').toString(), style: pw.TextStyle(fontSize: 9)),
            ),
            pw.Container(
              height: 20,
              alignment: pw.Alignment.center,
              child: pw.Text((sale.customerId??'-').toString(), style: pw.TextStyle(fontSize: 9)),
            ),
            pw.Container(
              height: 20,
              alignment: pw.Alignment.center,
              child: pw.Text((sale.milkType??'-').toString(), style: pw.TextStyle(fontSize: 9)),
            ),
            pw.Container(
              height: 20,
              alignment: pw.Alignment.center,
              child: pw.Text((findTime(sale.date)??'-').toString(), style: pw.TextStyle(fontSize: 9)),
            ),
            pw.Container(
              height: 20,
              alignment: pw.Alignment.center,
              child: pw.Text((sale.paymentType??'-').toString(), style: pw.TextStyle(fontSize: 9)),
            ),
            pw.Container(
              height: 20,
              alignment: pw.Alignment.center,
              child: pw.Text((sale.quantity??'-').toString(), style: pw.TextStyle(fontSize: 9)),
            ),
            pw.Container(
              height: 20,
              alignment: pw.Alignment.center,
              child: pw.Text((sale.rate??'-').toString(), style: pw.TextStyle(fontSize: 9)),
            ),
            pw.Container(
              height: 20,
              alignment: pw.Alignment.center,
              child: pw.Text((sale.totalValue??'-').toString(), style: pw.TextStyle(fontSize: 9)),
            ),
          ],
        ),
      ],
    );
  }
}
