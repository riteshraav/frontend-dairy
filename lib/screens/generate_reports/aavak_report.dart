import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:take8/api/ledger_report_generation.dart';
import 'package:take8/model/cattleFeedSell.dart';
import 'package:take8/service/cattleFeedSellService.dart';
import '../../api/customer_summary_report.dart';
import '../../api/dairy_summary_report.dart';
import '../../api/customer_billing_report.dart';
import '../../api/aavak_report_generation.dart';
import '../../model/CustomerBalance.dart';
import '../../model/milk_collection.dart';
import '../../screens/drawer_screens/new_custom_drawer.dart';
import '../../service/CustomerBalanceService.dart';
import '../../service/deduction_service.dart';
import '../../service/mik_collection_service.dart';
import '../../widgets/appbar.dart';
import 'package:intl/intl.dart';
import '../../api/pdf_api.dart';
import '../../model/Customer.dart';
import '../../model/admin.dart';
import '../../model/deduction.dart';
import '../auth_screens/login_screen.dart';

class ReportSpecificationsPage extends StatefulWidget {
   Admin admin = CustomWidgets.currentAdmin();
   String title;
   List<Customer> customerList;
  ReportSpecificationsPage({required this.customerList, required this.title});
  @override
  _ReportSpecificationsPageState createState() => _ReportSpecificationsPageState();
}

class _ReportSpecificationsPageState extends State<ReportSpecificationsPage> {
  bool isCowSelected = false;
  bool isBuffaloSelected = false;
  DateTime? fromDate;
  DateTime? toDate;
  double totalAmount = 0;
  double totalQuantity = 0;
  List<String> customerCodeList = [];
  String period ="";

  @override
  void initState()   {
    // TODO: implement initState
    super.initState();
    if(  ["Aavak Report" , "Summary Report"].contains(widget.title))
      {
        widget.customerList =CustomWidgets.allCustomers();

      }
    if(widget.title == "Customer Bill" || widget.title == "Ledger Report")
      {
        isBuffaloSelected = true;
        isCowSelected = true;
      }
    for(Customer c in widget.customerList)
    {
      customerCodeList.add(c.code!);
    }
  }
  String extractDate(String date) {
    DateTime dateTime = DateTime.parse(date);
    return '${dateTime.day.toString().padLeft(2, '0')}/${dateTime.month.toString().padLeft(2, '0')}/${dateTime.year}';
  }

  void pickDate(BuildContext context, bool isFrom) async {
    DateTime? selectedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: isFrom
          ? DateTime(2000)
          : (fromDate ?? DateTime(2000)), // Ensure To Date can't be before From Date
      lastDate: DateTime.now(),
    );
    if (selectedDate != null) {
      setState(() {
        if (isFrom) {
          fromDate = selectedDate;
          // If To Date is set and invalid, reset it
          if (toDate != null && toDate!.isBefore(fromDate!)) {
            toDate = null;
          }
        } else {
          toDate = selectedDate;
        }
      });
    }

  }



  void generateAavakReport() async{

    List<MilkCollection> milkCollection= [];
    print(fromDate);
    if(isBuffaloSelected)
    {

     List<MilkCollection>? buffaloList = await getAllForAdminWithSpecification('buffalo',true);
    //  List<MilkCollection> list = await MilkCollectionService.getAllForAdmin(widget.admin.id!);
     if(buffaloList == null)
       {
         return null;
       }
      milkCollection.addAll(buffaloList);
    }
    if(isCowSelected)
    {

      List<MilkCollection>? cowList = await getAllForAdminWithSpecification('cow',true);
      if(cowList == null)
      {
        return null;
      }
      milkCollection.addAll(cowList);
    }
    if(milkCollection.isEmpty)
      {
        print('//////////////////////////////////it is still aavak report milkcollection empty');
      }
    else {

      print(milkCollection.first.date);
      PdfInvoiceApi pdfInvoiceApi =
          PdfInvoiceApi(milkCollection, widget.admin, widget.customerList);
      final pdfFile = await pdfInvoiceApi.generate();

      final file = await PdfApi.saveDocument(
          name: "${widget.admin.dairyName} ${DateTime.now().millisecondsSinceEpoch}",
          pdf: pdfFile);
      PdfApi.openFile(file);
    }
  }
 Future<List<MilkCollection>?> getAllForAdminWithSpecification(String milkType,
     [bool add = false])async{
    List<MilkCollection>? list = await MilkCollectionService().getAllForAdminWithSpecificationAuth(
                                fromDate!.toIso8601String(),(add)?toDate!.add(Duration(days: 1)).toIso8601String(): toDate!.toIso8601String(),
                                widget.admin.id!,milkType);
    if(list == null)
      {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => LoginPage()),
              (route) => false, // Clears entire stack
        );
      }
    return list;
  }

  void generateSummary()
  async{

    List<MilkCollection> milkCollection= [];
    print(fromDate);
    if(isBuffaloSelected)
    {

      List<MilkCollection>? buffaloList = await getAllForAdminWithSpecification('buffalo');
      if(buffaloList == null) {
        return;
      }
      milkCollection.addAll(buffaloList);
    }
    if(isCowSelected)
    {
      List<MilkCollection>? cowList = await getAllForAdminWithSpecification('cow');
      if(cowList == null) {
        return ;
      }
      milkCollection.addAll(cowList);
    }
    List<Deduction>? deductionList = await DeductionService().getDeductionForAdminBetweenPeriodAuth( fromDate!.toIso8601String(), toDate!.toIso8601String());
      if(deductionList == null)
        {
          print("existed from deduction list null here");
          CustomWidgets.logout(context);
          return;
        }
      if(deductionList.isEmpty)
        {
            print("dairy deduction list histiyr.........is empty...........");
        }
      if(widget.title == "Customer Summary Report")
        {
          CustomerSummaryReport customerSummaryReport = CustomerSummaryReport(milkCollection,deductionList,fromDate!,toDate!,isBuffaloSelected,isCowSelected,widget.customerList);

          final pdfFile = await customerSummaryReport.generate();

          final file = await PdfApi.saveDocument(name: "${widget.admin.dairyName} ${DateTime.now().millisecondsSinceEpoch}", pdf: pdfFile);

          PdfApi.openFile(file);
        }
      else{

        DairySummaryReport dairySummaryReport = DairySummaryReport(milkCollection,deductionList,fromDate!,toDate!,isBuffaloSelected,isCowSelected);

        final pdfFile = await dairySummaryReport.generate();

        final file = await PdfApi.saveDocument(name: "${widget.admin.dairyName} ${DateTime.now().millisecondsSinceEpoch}", pdf: pdfFile);

        PdfApi.openFile(file);
      }


  }

  void generateCustomerBill()async{
    List<CustomerBalance>? customerBalanceList = await CustomerBalanceService().getCustomerBalanceForCustomersAuth(widget.admin.id!,customerCodeList);

    if(customerBalanceList == null)
      {
        // CustomWidgets.logout(context);
        print("balance list is null");
        Fluttertoast.showToast(msg: "customer balance null");
        return;
      }
    List<Deduction>? deduction = await DeductionService().getDeductionForCustomersBetweenPeriodAuth(customerCodeList,widget.admin.id!, fromDate!.toIso8601String(), toDate!.toIso8601String());
    if(deduction == null)
      {
     //   CustomWidgets.logout(context);
        print("deductioin data is null");
        Fluttertoast.showToast(msg: "deduction is null");
        return;
      }
   // List<MilkCollection> milkCollectionList =await MilkCollectionService.getForCustomersWithSpecification(customerCodeList, fromDate!.toIso8601String(), toDate!.toIso8601String(), widget.admin.id!, isCowSelected, isBuffaloSelected);
    List<MilkCollection>? milkCollectionList =await MilkCollectionService().getForCustomersWithSpecificationAuth(customerCodeList, fromDate!.toIso8601String(), toDate!.toIso8601String(), widget.admin.id!, isCowSelected, isBuffaloSelected);
    if(milkCollectionList == null)
      {
    //  CustomWidgets.logout(context);
        Fluttertoast.showToast(msg: "milk collection list is null");
        print("milk collection list is null");
        return;
      }
    if(milkCollectionList.isEmpty)
      {
        print("milk collection is emepty");
        Fluttertoast.showToast(msg: "No collection for selected customer");
      }

    CustomerBillingReport pdfCustomerHistory = CustomerBillingReport(milkCollectionList, widget.admin,widget.customerList, fromDate!, toDate!,deduction,customerBalanceList! );
    final pdfFile = await pdfCustomerHistory.generate();

    final file = await PdfApi.saveDocument(name: "${widget.admin.dairyName} ${fromDate!.day} ${toDate!.day}", pdf: pdfFile);
    PdfApi.openFile(file);
  }
  void generateCustomerSummary() async{
    List<MilkCollection>? milkCollection= [];
   // milkCollection = await MilkCollectionService.getForCustomersWithSpecification(customerCodeList, fromDate!.toIso8601String(), toDate!.toIso8601String(), widget.admin.id!, isCowSelected , isBuffaloSelected);
    milkCollection = await MilkCollectionService().getForCustomersWithSpecificationAuth(customerCodeList, fromDate!.toIso8601String(), toDate!.toIso8601String(), widget.admin.id!, isCowSelected , isBuffaloSelected);
   if(milkCollection == null)

     {
       Navigator.of(context).pushAndRemoveUntil(
         MaterialPageRoute(builder: (context) => LoginPage()),
             (route) => false, // Clears entire stack
       );
       return;
     }
    List<Deduction>? deductionList = await DeductionService().getDeductionForCustomersBetweenPeriodAuth(customerCodeList,widget.admin.id!, fromDate!.toIso8601String(), toDate!.toIso8601String());
   if(deductionList == null)
     {
       print("deduction list is null in customer summary");
      CustomWidgets.logout(context);
        return;
     }

    CustomerSummaryReport customerSummaryReport =CustomerSummaryReport(milkCollection, deductionList, fromDate!, toDate!, isBuffaloSelected, isCowSelected,widget.customerList);

    if(deductionList.isEmpty)
    {
      print("//////////////////////////it is  deducton is customer summary empty");

    }
    final pdfFile = await customerSummaryReport.generate();

    final file = await PdfApi.saveDocument(name: "${widget.admin.dairyName} ${DateTime.now().millisecondsSinceEpoch}", pdf: pdfFile);

    PdfApi.openFile(file);
  }

  void generateLedgerReport() async{
    List<CattleFeedSell> cattleFeedSellList = await CattleFeedSellService.getAllCattleFeedSell(widget.admin.id!,customerCodeList,fromDate!.toIso8601String(),toDate!.toIso8601String() );
    print("cattle feed sell list length is ${cattleFeedSellList.length}");
    LedgerReportGeneration ledgerReportGeneration =LedgerReportGeneration(cattleFeedSellList, fromDate!.toIso8601String(), toDate!.toIso8601String());
    final pdfFile = await ledgerReportGeneration.generate();
    final file = await PdfApi.saveDocument(name: "${widget.admin.dairyName} ${DateTime.now().millisecondsSinceEpoch}", pdf: pdfFile);

    PdfApi.openFile(file);
}
  bool isLeapYear()
  {
    int year = DateTime.now().year;
    return (year % 4 == 0) && ((year % 100 != 0) || (year % 400 == 0));}

  void setDatesForReport(){
    DateTime fullDate = DateTime.now();
    int date = fullDate.day;
    int set = date~/10 ;
    if(set == 0)
    {
      int prevMonth = DateTime(fullDate.year,fullDate.month-1).month;
        fromDate = DateTime(fullDate.year,prevMonth,21);
      if([4,6,9,11].contains(prevMonth))
      {

        toDate =DateTime(fullDate.year,prevMonth,30);
      }
      else if( prevMonth == 2 )
        {

            if(isLeapYear())
              {
                toDate =DateTime(fullDate.year,prevMonth,29);
              }
            else{
              toDate =DateTime(fullDate.year,prevMonth,28);

            }
        }
      else{

        toDate = DateTime(fullDate.year,prevMonth,31);

      }
    }
    else if (set == 1)
    {
      fromDate = DateTime(fullDate.year,fullDate.month,1);
      toDate = DateTime(fullDate.year,fullDate.month,10);


    }
    else
    {
      fromDate = DateTime(fullDate.year,fullDate.month,11);
      toDate = DateTime(fullDate.year,fullDate.month,20);

    }
    print(extractDate(fromDate!.toIso8601String()));
    print(extractDate(toDate!.toIso8601String()));
  }
  void setDatesForHistory(){
    fromDate = DateTime.now().subtract(Duration(days: 10));
    toDate = DateTime.now();
    fromDate = DateTime(2025,2,5).subtract(Duration(days: 10));
    toDate = DateTime(2025,2,5);
  }
  void checkReportGenerationForReport(){
    if(!(isCowSelected || isBuffaloSelected))
    {
      Fluttertoast.showToast(msg: "Select Milk type");
      return;
    }
    else{
      setDatesForReport();
      switch(widget.title)
      {
        case "Aavak Report":
          generateAavakReport();
          break;
        case "Customer Bill":
          generateCustomerBill();
          break;
        case "Customer Summary Report":
          generateCustomerSummary();
          break;
        case "Ledger Report":
          generateLedgerReport();
          break;
        default :
          generateSummary();

      }
    }
  }
  void checkReportGenerationForHistory(){
    if(!(isCowSelected || isBuffaloSelected))
    {
      Fluttertoast.showToast(msg: "Select Milk type");
      return;
    }
    else{
      setDatesForHistory();
      switch(widget.title)
      {
        case "Aavak Report":
          generateAavakReport();
          break;
        case "Customer Bill":
          generateCustomerBill();
          break;
        case "Customer Summary Report":
          generateCustomerSummary();
          break;
        case "Ledger Report":
          generateLedgerReport();
          break;
        default :
          generateSummary();

      }
    }
  }
  void checkReportGenerationForButton(){

      if(!(isCowSelected || isBuffaloSelected) || (fromDate == null || toDate == null))
      {
        Fluttertoast.showToast(msg: "Enter Required fields");
      }
      else{
        switch(widget.title)
        {
          case "Aavak Report":
            generateAavakReport();
            break;
          case "Customer Bill":
            generateCustomerBill();
            break;
          case "Customer Summary Report":
            generateCustomerSummary();
            break;
          case "Ledger Report":
            generateLedgerReport();
            break;
          default :
            generateSummary();

      }
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue[50],
      appBar: CustomWidgets.buildAppBar(widget.title),
      drawer: NewCustomDrawer(),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Animal selection checkboxes
            if(widget.title != "Customer Bill" && widget.title != "Ledger Report")
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child:       Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Checkbox(
                      activeColor: Colors.blue,      // Checkbox background when checked
                      checkColor: Colors.white,
                      value: isCowSelected,
                      onChanged: (value) {
                        setState(() {
                          isCowSelected = value!;
                        });
                      },
                    ),
                    Text('Cow'),
                    SizedBox(width: 50,),
                    Checkbox(
                      activeColor: Colors.blue,      // Checkbox background when checked
                      checkColor: Colors.white,                  value: isBuffaloSelected,
                      onChanged: (value) {
                        setState(() {
                          isBuffaloSelected = value!;
                        });
                      },
                    ),
                    Text('Buffalo'),
                  ],
                ),
              ),
            ),
            SizedBox(height: 20),
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              child: InkWell(
                onTap: checkReportGenerationForReport,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    children: [
                      Icon(Icons.calendar_month_outlined,size: 50, color: Color(0xFF24A1DE)),
                      SizedBox(height: 10),
                      Text("10 Days Report",
                        style: TextStyle(
                          fontSize: 18,

                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            SizedBox(height: 20),
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              child: InkWell(
                onTap: checkReportGenerationForHistory,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    children: [
                      Icon(Icons.calendar_month_outlined,size: 50, color: Color(0xFF24A1DE)),
                      SizedBox(height: 10),
                      Text("Recent 10 days history",
                        style: TextStyle(
                          fontSize: 18,

                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            SizedBox(height: 20),

            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              child: Padding(
                padding: const EdgeInsets.all(28.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Text("Customise Dates",style: TextStyle(fontWeight: FontWeight.bold,fontSize: 20),),
                      ],
                    ),
                    SizedBox(height: 20,),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // From Date Field
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'From Date:',
                              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                            SizedBox(height: 8),
                            InkWell(
                              onTap: () => pickDate(context, true),
                              child: Container(
                                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  border: Border.all(color: Colors.grey),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  fromDate == null
                                      ? 'DD/MM/YYYY'
                                      : '${fromDate?.day.toString().padLeft(2, '0')}/${fromDate?.month.toString().padLeft(2, '0')}/${fromDate?.year}',
                                  style: TextStyle(fontSize: 14),
                                ),
                              ),
                            ),
                          ],
                        ),
                        // To Date Field
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'To Date:',
                              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                            SizedBox(height: 8),
                            InkWell(
                              onTap: () => pickDate(context, false),
                              child: Container(
                                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  border: Border.all(color: Colors.grey),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  toDate == null
                                      ? 'DD/MM/YYYY'
                                      : '${toDate?.day.toString().padLeft(2, '0')}/${toDate?.month.toString().padLeft(2, '0')}/${toDate?.year}',
                                  style: TextStyle(fontSize: 14),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    Padding(
                      padding: const EdgeInsets.all(18.0),
                      child: CustomWidgets.customButton(text:  "Generate Report",
                       onPressed:  checkReportGenerationForButton
                      ),
                    )
                  ],
                ),
              ),
            ),


          ],
        ),
      ),
    );
  }
}
