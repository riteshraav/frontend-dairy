import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

import '../model/admin.dart';
import '../model/advancecustomerinfo.dart';
import '../service/customerAdvanceService.dart';
import '../widgets/appbar.dart';
import 'advance_customer.dart';
class CustomerAdvanceHistory extends StatefulWidget {
  List<AdvanceEntry>? newAdvanceEntries;
   CustomerAdvanceHistory({super.key , this.newAdvanceEntries});

  @override
  State<CustomerAdvanceHistory> createState() => _CustomerAdvanceHistoryState();
}

class _CustomerAdvanceHistoryState extends State<CustomerAdvanceHistory> {
  final TextEditingController _searchController = TextEditingController();

  List<AdvanceEntry> advanceList = [];
  List<AdvanceEntry> store = [];
  Admin admin = CustomWidgets.currentAdmin();
  bool isLoading = false;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    loadData();

    _searchController.addListener(_searchCustomer);
  }
  void _deleteData(AdvanceEntry entry)async{
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        titlePadding: EdgeInsets.all(15),
        contentPadding: EdgeInsets.symmetric(horizontal: 10),
        actionsPadding: EdgeInsets.only(bottom: 10, right: 10),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        title: Text("Previous Advance", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'This customer already has lend money:',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              ListTile(
                dense: true, // Makes tiles more compact
                leading: Text(
                  "Code : ${entry.code}",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                ),
              ),
              ListTile(
                dense: true, // Makes tiles more compact
                leading: Text(
                  "Name : ${entry.name}",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                ),
              ),
              ListTile(
                dense: true, // Makes tiles more compact
                leading: Text(
                  "Amount : ${entry.advanceAmount}",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                ),
              ),
              ListTile(
                dense: true, // Makes tiles more compact
                leading: Text(
                  "Rate : ${entry.interestRate}",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                ),
              ),
              ListTile(
                dense: true, // Makes tiles more compact
                leading: Text(
                  "Interest : ${calculateInterest(entry)}",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                ),
              ),


            ],
          ),
        ),

        actions: [
          TextButton(
            child: Text("Cancel", style: TextStyle(color: Colors.grey[700])),
            onPressed: () => Navigator.pop(context),
          ),
          CustomWidgets.customButton(text:  "Delete",onPressed:  () async {
            setState(() {
              isLoading = true;
            });

            bool customerDeleted = await CustomerAdvanceService.deleteAdvance(entry);
              setState(() {
                isLoading = false;
              });
            if (customerDeleted) {
              store.remove(entry);
              advanceList.remove(entry);
              Fluttertoast.showToast(msg: "Deleted Successfully");
            } else {
              Fluttertoast.showToast(msg: "Error");
            }
            Navigator.pop(context);
          },buttonBackgroundColor:  Colors.red)
        ],
      ),
    );
  }
  void _searchCustomer() {
    if (_searchController.text.isNotEmpty) {
      List<AdvanceEntry> foundEntries =
      advanceList.where((entry)=> entry.code.toString() == _searchController.text.trim()).toList();
      if (foundEntries.isNotEmpty) {
        setState(() {
          store = foundEntries;
        });
      } else {
        CustomWidgets.showCustomSnackBar(
            "No customer found with ${_searchController.text}", context, 2);
      }
    } else {
      setState(() {
        store = advanceList;
      });
    }
  }
  void addButtonWorking()async{
    List<AdvanceEntry> result = await Navigator.push(context, MaterialPageRoute(builder: (context)=> AdvanceScreen(advanceList)));
    if(result != null){
      setState(() {
      store = result;
    });
    }
  }
  double calculateInterest(AdvanceEntry entry){
    return (entry.advanceAmount * entry.interestRate * (DateTime.now().difference(DateTime.parse(entry.date)).inDays)/365) * 0.01;
  }
  void loadData() async {
    setState(() => isLoading = true); // Show loader immediately

    advanceList = await CustomerAdvanceService.getAllAdvanceForAdmin(admin.id!);
    print("lenfth of advnace list is ${advanceList.length}");
    advanceList.sort((a, b) => int.parse(a.code).compareTo(int.parse(b.code)));

    setState(() {
      store = advanceList;
      isLoading = false;
    }); // Rebuild UI
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: CustomWidgets.buildAppBar("Customer Advance History",[IconButton(onPressed: (){
      addButtonWorking();
      }, icon: Icon(Icons.add))]),
      backgroundColor: Colors.blue[50],
      body:
      Container(
        height: double.infinity,
        child: Stack(

          children:[
            SingleChildScrollView(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextField(
                    keyboardType: TextInputType.phone,
                    controller: _searchController,
                    decoration: InputDecoration(
                      fillColor: Colors.white,
                      filled: true,
                      suffixIcon: (_searchController.text !="")?IconButton(onPressed: (){
                        _searchController.clear();
                      }, icon: Icon(Icons.clear)):null,
                      labelText: 'Enter Customer Code',
                      border: const OutlineInputBorder(),

                    ),
                  ),
                ),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: DataTable(
                      columnSpacing: 8,
                      headingRowHeight: 45,
                      border: TableBorder.all(),
                      headingRowColor: WidgetStateProperty.all(Color(0xFF24A1DE)),
                      columns: [
                        //DataColumn(label: Text("Date",style: TextStyle(color: Colors.white),)),
                        DataColumn(label: Text("Status",style: TextStyle(color: Colors.white),)),
                        DataColumn(label: Text("Code",style: TextStyle(color: Colors.white),)),
                        //DataColumn(label: Text("Name",style: TextStyle(color: Colors.white),)),
                        DataColumn(label: Text("Amt",style: TextStyle(color: Colors.white),)),
                        DataColumn(label: Text("Rate",style: TextStyle(color: Colors.white),)),
                        DataColumn(label: Text("Interest",style: TextStyle(color: Colors.white),)),
                        DataColumn(label: Text("Pay",style: TextStyle(color: Colors.white),)),

                        DataColumn(label: Text("Delete",style: TextStyle(color: Colors.white),)),
                      ],
                      rows: List.generate(
                        store.length,
                            (index) {
                          final entry = store[index];
                          return DataRow(
                            color: WidgetStateProperty.resolveWith<Color?>(
                                  (Set<WidgetState> states) {
                                return Colors.white; // white background
                              },
                            ),
                            cells: [
                              // DataCell(Text(dateController.text)),
                              DataCell(Row(
                                children: [
                                  Text(entry.advanceAmount == 0?"NIL":"PENDING",style: TextStyle(color: entry.advanceAmount == 0?Colors.green:Colors.red),),
                                  IconButton(icon: Icon(entry.advanceAmount == 0? Icons.check_box:Icons.close) , color:entry.advanceAmount == 0?Colors.green :Colors.red , onPressed: () => _deleteData(entry)),
                                ],
                              )),
                              DataCell(Text(entry.code)),
                              //DataCell(Text(selectedCustomer.name!)),
                              DataCell(Text(entry.advanceAmount.toString())),
                              DataCell(Text(entry.interestRate.toString())),
                              DataCell(Text((calculateInterest(entry)).toStringAsFixed(2))),
                              DataCell(Text(entry.paymentMethod)),
                              DataCell(IconButton(icon: Icon(Icons.delete, color: Colors.blue,), onPressed: () => _deleteData(entry))),
                            ],

                          );
                        },
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
            if (isLoading)
              Positioned.fill(
                child: Center(child: CircularProgressIndicator()),
              ),
          ]
        ),
      ),
    );
  }
}