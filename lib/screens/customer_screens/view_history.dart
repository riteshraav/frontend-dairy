import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import '../../api/customer_billing_report.dart';
import '../../screens/drawer_screens/drawer_screen.dart';
import '../../screens/drawer_screens/new_custom_drawer.dart';
import '../../service/CustomerBalanceService.dart';
import '../../service/deduction_service.dart';
import '../../service/mik_collection_service.dart';
import '../../widgets/appbar.dart';
import '../../api/pdf_api.dart';
import '../../model/CustomerBalance.dart';
import '../../model/Customer.dart';
import '../../model/admin.dart';
import '../../model/deduction.dart';
import '../../model/milk_collection.dart';
import '../auth_screens/login_screen.dart';

class CustomerMilkHistory extends StatefulWidget {

  final Customer customer;
  CustomerMilkHistory( {
    required this.customer,
  });

  @override
  State<CustomerMilkHistory> createState() => _CustomerMilkHistoryState();
}

class _CustomerMilkHistoryState extends State<CustomerMilkHistory> {
  final Admin admin = CustomWidgets.currentAdmin();
  List<MilkCollection> changable = [];
  List<MilkCollection>? milkCollectionList = [];
  bool isCowSelected = false;
  bool isBuffaloSelected = false;
  DateTime? fromDate;
  DateTime? toDate;
  double totalQuantity = 0 ;
  double totalAmount = 0;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    loadData();
    setState(() {
      isCowSelected = widget.customer.cow!;
      isBuffaloSelected = widget.customer.buffalo!;
    });

  }

void loadData()async{
   try {
      milkCollectionList =
      await MilkCollectionService()
          .getAllForCustomerAuth(
          widget.customer.code!,admin.id!);
      if(milkCollectionList == null)
        {
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (context) => LoginPage()),
                (route) => false, // Clears entire stack
          );
        }
      setState(() {
        changable = milkCollectionList!;
      });
      print("milkCollectionList?.length ${milkCollectionList?.length}");
      // Proceed with the fetched data
    } catch (e) {
      print('Error: $e');
      // Show an error message to the user or handle gracefully
    }
}
  void pickDate(BuildContext context, bool isFrom) async {
    DateTime? selectedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: isFrom
          ? DateTime(2000)
          : (fromDate ?? DateTime(2000)), // Ensure To Date can't be before From Date
      lastDate: DateTime.now(),

    builder: (context, child) {
      return Theme(
        data: ThemeData.light().copyWith(
          primaryColor: Colors.deepPurple, // Changes header background color
          colorScheme: ColorScheme.light(primary: Color(0xFF24A1DE)), // Button colors
          buttonTheme: ButtonThemeData(textTheme: ButtonTextTheme.primary),
          dialogBackgroundColor: Colors.white, // Background color of the picker
          textTheme: TextTheme(
            bodyLarge: TextStyle(color: Colors.black), // General text color
            titleLarge: TextStyle(color: Colors.white), // Title text color
          ),
        ),
        child: child!,
      );
    },
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
void filterByMilk()
{
  List<MilkCollection> cowMilkList = [];
  List<MilkCollection> buffaloMilkList = [];
    totalAmount = 0;
    totalQuantity = 0;

  if(isCowSelected) {
      cowMilkList = milkCollectionList!.where((milkCollection) {
        totalQuantity = totalQuantity + milkCollection.quantity!;
        totalAmount = totalAmount + milkCollection.totalValue!;
        return milkCollection.milkType == "cow";
      }).toList();
    }
  if(isBuffaloSelected) {
    cowMilkList = milkCollectionList!.where((milkCollection) {
      totalQuantity = totalQuantity + milkCollection.quantity!;
      totalAmount = totalAmount + milkCollection.totalValue!;
      return milkCollection.milkType == "buffalo";
    }).toList();
  }
  setState(() {
    changable = cowMilkList + buffaloMilkList;
  });
}
  void filterCollection(DateTime? from, DateTime? to) {
    to = to?.add(Duration(days: 1));
    totalAmount = 0;
    totalQuantity = 0;
    // Create empty lists to hold filtered milk collections
    List<MilkCollection> cowMilkList = [];
    List<MilkCollection> buffaloMilkList = [];
  print(isCowSelected);
  print(isBuffaloSelected);
    // Filter for Cow milk
    if (isCowSelected) {
      if (from == null && to == null) {
        // No date range, just filter by milk type
        cowMilkList = milkCollectionList!.where((milkCollection) {
          totalQuantity = totalQuantity + milkCollection.quantity!;
          totalAmount = totalAmount + milkCollection.totalValue!;
          return milkCollection.milkType == "cow";
        }).toList();
      } else {
        // With date range, filter by both date and milk type
        cowMilkList = milkCollectionList!.where((milkCollection) {
          totalQuantity = totalQuantity + milkCollection.quantity!;
          totalAmount = totalAmount + milkCollection.totalValue!;
          DateTime milkDate = DateTime.parse(milkCollection.date!);
          return (milkDate.isAfter(from!) || milkDate.isAtSameMomentAs(from!)) &&
              (milkDate.isBefore(to!) || milkDate.isAtSameMomentAs(to!)) &&
              milkCollection.milkType == "cow";
        }).toList();
      }
    }

    // Filter for Buffalo milk
    if (isBuffaloSelected) {
      if (from == null && to == null) {
        // No date range, just filter by milk type
        buffaloMilkList = milkCollectionList!.where((milkCollection) {
          totalQuantity = totalQuantity + milkCollection.quantity!;
          totalAmount = totalAmount + milkCollection.totalValue!;
          return milkCollection.milkType == "buffalo";
        }).toList();
      } else {
        // With date range, filter by both date and milk type
        buffaloMilkList = milkCollectionList!.where((milkCollection) {
          totalQuantity = totalQuantity + milkCollection.quantity!;
          totalAmount = totalAmount + milkCollection.totalValue!;
          DateTime milkDate = DateTime.parse(milkCollection.date!);
          return (milkDate.isAfter(from!) || milkDate.isAtSameMomentAs(from!)) &&
              (milkDate.isBefore(to!) || milkDate.isAtSameMomentAs(to!)) &&
              milkCollection.milkType == "buffalo";
        }).toList();
      }
    }
    // Combine filtered lists for cow and buffalo milk
    setState(() {
      changable = cowMilkList + buffaloMilkList;
    });
  }
  String extractDate(String date) {
    DateTime dateTime = DateTime.parse(date);
    return '${dateTime.day.toString().padLeft(2, '0')}/${dateTime.month.toString().padLeft(2, '0')}/${dateTime.year}';
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: NewCustomDrawer(),
      appBar: CustomWidgets.buildAppBar('Customer History'),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with Customer Details
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Expanded(
                  child: Card(
                    elevation: 4,
                    child: Container(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Code: ${widget.customer.code}',
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                          SizedBox(height: 8),
                          Text('Name: ${widget.customer.name}'),
                          Text('Phone: ${widget.customer.phone}'),
                          Text('Milk Type: ${_getMilkType(widget.customer)}'),
                        ],
                      ),
                    ),
                  ),
                ),

              ],
            ),
            Column(
              children: [
                // Animal selection checkboxes
                if(widget.customer.buffalo! && widget.customer.cow!)
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Select MilkType:',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),

                    Checkbox(

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
                      value: isBuffaloSelected,
                      onChanged: (value) {
                        setState(() {
                          isBuffaloSelected = value!;
                        });
                      },
                    ),
                    Text('Buffalo'),
                  ],
                ),

                Divider(height: 20,),
                // Date pickers
                Row(
                  // mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,// Ensures Row does not expand unnecessarily
                  children: [
                    // From Date Field
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '',
                          style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                        ),
                        SizedBox(height: 6), // Reduce spacing
                        InkWell(
                          onTap: () => pickDate(context, true),
                          child: Container(
                            width: 120, // Manually set width (Reduce this further if needed)
                            height: 43, // Reduce height
                            padding: EdgeInsets.symmetric(horizontal: 6, vertical:4 ), // Reduce padding
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey),
                              borderRadius: BorderRadius.circular(6),
                              color: Colors.grey[200],
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  fromDate == null ? 'DD/MM/YYYY' : extractDate(fromDate.toString()),
                                  style: TextStyle(fontSize: 15, color: Colors.black), // Reduce font size
                                ),
                                Icon(Icons.calendar_today, size: 12, color: Colors.blue), // Smaller icon
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),

                    // "To" in the Center

                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 8),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                         // Aligns content to the top
                        children: [
                          SizedBox(height: 20), // Adjust this value to move "To" downward
                          Text(
                            "To",
                            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),


                    // To Date Field
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '',
                          style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                        ),
                        SizedBox(height: 6),
                        InkWell(
                          onTap: () => pickDate(context, false),
                          child: Container(
                            width: 120, // Manually set width
                            height: 40, // Reduce height
                            padding: EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey),
                              borderRadius: BorderRadius.circular(6),
                              color: Colors.grey[200],
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  toDate == null ? 'DD/MM/YYYY' : extractDate(toDate.toString()),
                                  style: TextStyle(fontSize: 15, color: Colors.black),
                                ),
                                Icon(Icons.calendar_today, size: 12, color: Colors.blue),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
            SizedBox(height: 10,),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                ElevatedButton(
                    style: CustomWidgets.elevated(),
                    onPressed: () async {

                      var isDeviceConnected = await  CustomWidgets.internetConnection();
                      if(!isDeviceConnected){
                        CustomWidgets.showDialogueBox(context : context);
                        return;
                      }

                  if(fromDate == null && toDate == null)
                    {
                      filterByMilk();
                      Fluttertoast.showToast(msg: "Search Complete");
                    }
                    else if((widget.customer.buffalo! && widget.customer.cow!) && (isBuffaloSelected || isCowSelected)){
                     filterCollection(fromDate, toDate);
                      Fluttertoast.showToast(msg: "Search Complete");
                    }
                     else if((widget.customer.buffalo! || widget.customer.cow!))
                       {
                         filterCollection(fromDate, toDate);
                         Fluttertoast.showToast(msg: "Search Complete");
                       }
                    else{
                      Fluttertoast.showToast(msg: "Select milk-type");
                    }
                    }, child:
                    Text("Search",style: TextStyle(color: Colors.white))),

                ElevatedButton(style: CustomWidgets.elevated(),
                    onPressed: ()async{
                      if(fromDate == null || toDate == null)
                        {
                          CustomWidgets.showCustomSnackBar("Enter dates first", context, 1);
                        }
                      else if(changable.isNotEmpty)
                      {
                        CustomerBalance? customerBalance = await CustomerBalanceService().getCustomerBalanceAuth(admin.id!, widget.customer.code!);
                        if(customerBalance == null)
                        {
                          Fluttertoast.showToast(msg: "customer balalnce is null");
                          return;
                        }
                        if(customerBalance.adminId == "dummy")
                        {
                          Fluttertoast.showToast(msg: "Something went worong");
                          return;
                        }

                        List<Deduction>? deduction = await DeductionService().getDeductionForReportAuth(admin.id!,widget.customer.code!,fromDate!.toIso8601String(),toDate!.toIso8601String());
                        if(deduction == null)
                          {
                           Fluttertoast.showToast(msg: "deduction is null");
                            return;
                          }
                        List<Customer> customerList = [widget.customer];
                        CustomerBillingReport pdfCustomerHistory = CustomerBillingReport(changable, admin,customerList, fromDate!, toDate!,deduction,[customerBalance] );
                        final pdfFile = await pdfCustomerHistory.generate();
                         final file = await PdfApi.saveDocument(name: "${admin.dairyName} ${fromDate!.day} ${toDate!.day}", pdf: pdfFile);
                         PdfApi.openFile(file);

                      }
                    },
                    child: Text("Print",style: TextStyle(color: Colors.white))),
                ElevatedButton(style: CustomWidgets.elevated(),
                    onPressed:(){
                    setState(() {
                      fromDate = null;
                      toDate = null;
                    });
                    setState(() {
                      changable = milkCollectionList!;
                    });
                    },
                    child: Text("Clear",style: TextStyle(color: Colors.white),)),
              ],
            ),
            SizedBox(height: 20,),
            Expanded(
              child: changable.isNotEmpty
                  ? _buildTable()
                  : Center(
                child: Text(
                  "No collection has been made by ${widget.customer.name}.",
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getMilkType(Customer customer) {
    List<String> types = [];
    if (customer.buffalo!) types.add("Buffalo");
    if (customer.cow!) types.add("Cow");
    return types.join(", ");
  }

  Widget _buildTable() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [

        // Fixed Date Column
        // Scrollable Columns
        Expanded(
          child: SingleChildScrollView(
            scrollDirection: Axis.vertical,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                border: TableBorder.all(
                  //borderRadius: BorderRadius.all(Radius.circular())
                ),
                headingRowHeight: 40,
                columnSpacing: 10,
                headingRowColor: MaterialStateProperty.all(Color(0xFF24A1DE)),// Match header height
                dataRowMinHeight: 40, // Match row height
                columns: _dataColumnWithoutDate(),
                rows: _dataRowsWithoutDate(),
              ),
            ),
          ),
        ),
      ],
    );
  }

// Columns excluding the Date column
  List<DataColumn> _dataColumnWithoutDate() {

    return [
      DataColumn(label:Text('Date', style: TextStyle(fontWeight: FontWeight.bold,color: Colors.white))),
      DataColumn(label: Text('Milk',style: TextStyle(fontWeight: FontWeight.bold,color: Colors.white))),
      DataColumn(label: Text('M/E', style: TextStyle(fontWeight: FontWeight.bold,color: Colors.white))),
      DataColumn(label: Text('Qty', style: TextStyle(fontWeight: FontWeight.bold,color: Colors.white))),
      DataColumn(label: Text('Fat', style: TextStyle(fontWeight: FontWeight.bold,color: Colors.white))),
      DataColumn(label: Text('SNF', style: TextStyle(fontWeight: FontWeight.bold,color: Colors.white))),
      DataColumn(label: Text('Rate', style: TextStyle(fontWeight: FontWeight.bold,color: Colors.white))),
      DataColumn(label: Text('Total', style: TextStyle(fontWeight: FontWeight.bold,color: Colors.white))),
    ];
  }

// Rows excluding the Date column
  List<DataRow> _dataRowsWithoutDate() {
    return changable.map((collection) {
      return DataRow(

          cells: [
        DataCell(Text(extractDate(collection.date!))),
        DataCell(Text(collection.milkType == "buffalo"? "B":"C")),
        DataCell(Text(collection.time == "Morning"?"M":"E")),
        DataCell(Text('${collection.quantity}')),
        DataCell(Text('${collection.fat}')),
        DataCell(Text('${collection.snf}')),
        DataCell(Text('₹${collection.rate}')),
        DataCell(Text('₹${collection.totalValue}')),
      ]);
    }).toList();
  }
}
