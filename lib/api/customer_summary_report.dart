
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:pdf/widgets.dart';
import '../model/deduction.dart';
import '../model/milk_collection.dart';
import '../widgets/appbar.dart';
import '../model/Customer.dart';
import '../model/admin.dart';

class CustomerInfo{
  double totalMilk=0;
  double totalValue=0;
  Deduction? deduction;
}
class CustomerSummaryReport {
  Admin admin = CustomWidgets.currentAdmin();
  List<Customer>selectedCustomer =[];
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
  List<Customer> customerList = CustomWidgets.allCustomers();
  List<Deduction> deductionList;
  DateTime fromDate;
  DateTime toDate;
  bool buffalo,cow;

  CustomerSummaryReport(this.milkCollectionList,this.deductionList,this.fromDate,this.toDate,this.buffalo,this.cow,this.selectedCustomer);
  Map<String,CustomerInfo> customerMap = {};
  String? findCustomerName(String customerId) {
    String? name = customerList.any((customer) => customer.code == customerId)
        ? customerList.firstWhere((customer) => customer.code == customerId).name
        : "";
    return name;
  }

  void formatLists()
  {
      for(Customer c in selectedCustomer)
        {
          customerMap[c.code!] = CustomerInfo();
        }
    milkCollectionList.forEach((collection){
      CustomerInfo entry = CustomerInfo() ;

      if(customerMap.containsKey(collection.customerId))
              {
                  entry = customerMap[collection.customerId]!;
              }
            entry.totalMilk += collection.quantity!;
            entry.totalValue += collection.totalValue!;
            customerMap.putIfAbsent(collection.customerId!,()=>entry);
    });
    for (var deduction in deductionList) {
      CustomerInfo customerInfo = customerMap[deduction.customerId] ?? CustomerInfo();

      Deduction currentDeduction = customerInfo.deduction ?? Deduction(adminId: admin.id!, customerId: deduction.customerId);
      Map<String, dynamic> map = currentDeduction.toJson();

      for (var entry in deduction.toJson().entries) {
        if (!["adminId", "customerId", "date"].contains(entry.key)) {
          map[entry.key] = (map[entry.key] ?? 0) + (entry.value ?? 0);
        }
      }

      customerInfo.deduction = Deduction.fromJson(map);
      customerMap[deduction.customerId] = customerInfo;  // Ensures updating instead of putIfAbsent
    }

    var sortedEntries = customerMap.entries.toList()
      ..sort((a, b) => int.parse(a.key).compareTo(int.parse(b.key)));

    // Convert back to map
    Map<String, CustomerInfo> sortedMap = Map.fromEntries(sortedEntries);
    customerMap = sortedMap;
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
                    "${admin.dairyName} Customer Summary Report",
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
              pw.Text("${(buffalo)?"Buffalo ":""} ${ (buffalo && cow)? "and":""} ${(cow)?"Cow":""}"),
              pw.Text("Period : ${extractDate(fromDate)} - ${extractDate(toDate)}"),
              pw.Text("Date : ${extractDate(DateTime.now())}"),
            ]),
        pw.SizedBox(height: 10,),
          buildTableHeader(),


      ]),

    ));

    return widgets;
  }

  pw.Widget buildTableHeader() {
    List<pw.TableRow> listTableRows = [];

    listTableRows.add(     pw.TableRow(
      decoration: pw.BoxDecoration(color: PdfColors.grey300),
      children: [
        pw.Container(
          padding: pw.EdgeInsets.all(5),
          alignment: pw.Alignment.center,
          child: pw.Text("Code",
              style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
        ),
        pw.Container(
          padding: pw.EdgeInsets.all(5),
          alignment: pw.Alignment.center,
          child: pw.Text("Name",
              style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
        ),
        pw.Container(
          padding: pw.EdgeInsets.all(5),
          alignment: pw.Alignment.center,
          child: pw.Text("Total Milk",
              style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
        ),
        pw.Container(
          padding: pw.EdgeInsets.all(5),
          alignment: pw.Alignment.center,
          child: pw.Text("Total Value",
              style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
        ),
        pw.Container(
          padding: pw.EdgeInsets.all(5),
          alignment: pw.Alignment.center,
          child: pw.Text("Deduction",
              style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
        ),
        pw.Container(
          padding: pw.EdgeInsets.all(5),
          alignment: pw.Alignment.center,
          child: pw.Text("Net Payment",
              style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
        ),
        pw.Container(
          padding: pw.EdgeInsets.all(5),
          alignment: pw.Alignment.center,
          child: pw.Text("Signature",
              style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
        ),
      ],
    ),);


    for(var entry in customerMap.entries)
      {
          listTableRows.add(
          pw.TableRow(
            children: [
              pw.Container(
                padding: pw.EdgeInsets.all(5),
                alignment: pw.Alignment.center,
                child: pw.Text(entry.key,
                    style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
              ),
              pw.Container(
                padding: pw.EdgeInsets.all(5),
                alignment: pw.Alignment.center,
                child: pw.Text(findCustomerName(entry.key)!,
                    style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
              ),
              pw.Container(
                padding: pw.EdgeInsets.all(5),
                alignment: pw.Alignment.center,
                child: pw.Text((entry.value.totalMilk).toStringAsFixed(2),
                    style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
              ),
              pw.Container(
                padding: pw.EdgeInsets.all(5),
                alignment: pw.Alignment.center,
                child: pw.Text((entry.value.totalValue).toStringAsFixed(2),
                    style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
              ),
              pw.Container(
                padding: pw.EdgeInsets.all(5),
                alignment: pw.Alignment.center,
                child: pw.Text((entry.value.deduction?.total ?? 0).toStringAsFixed(2),
                    style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
              ),
              pw.Container(
                padding: pw.EdgeInsets.all(5),
                alignment: pw.Alignment.center,
                child: pw.Text(((entry.value.totalValue) - (entry.value.deduction?.total ?? 0)).toStringAsFixed(2),
                    style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
              ),


            ],
          ),
          );
          Deduction deduction = entry.value.deduction ?? Deduction(adminId: admin.id!, customerId: entry.key);

          Map<String,dynamic> map = deduction.toJson();
          listTableRows.add(pw.TableRow(
            children: [
              for(var field in map.entries)
                if(!(["adminId","customerId","date","total","totalCattleFeedBalance"].contains(field.key)) )
                pw.Column(
                  children: [
                    pw.Container(
                      padding: pw.EdgeInsets.all(5),
                      alignment: pw.Alignment.center,
                      child: pw.Text(deductionField[field.key]!,)
                    ),
                    pw.Container(
                      padding: pw.EdgeInsets.all(5),
                      alignment: pw.Alignment.center,
                      child: pw.Text((field.value??0).toString(),
                          style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                    ),
                  ]
                )

            ]
          ));
      }
    return pw.Table(
      border: pw.TableBorder.all(),
      columnWidths: {
        0: pw.FixedColumnWidth(40),
        1:pw.FixedColumnWidth(100),
        2:pw.FixedColumnWidth(60),
        3:pw.FixedColumnWidth(60),
        4:pw.FixedColumnWidth(60),
        5:pw.FixedColumnWidth(60),
        6:pw.FixedColumnWidth(60),
      },
      children: listTableRows,
    );
  }







}
