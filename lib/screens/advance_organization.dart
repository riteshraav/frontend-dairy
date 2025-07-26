import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:intl/intl.dart';

import '../service/advanceOrganizationService.dart';
import '../widgets/appbar.dart';
import '../model/admin.dart';
import '../model/advanceorganizationinfo.dart';

class OrganizationScreen extends StatefulWidget {
  @override
  _OrganizationScreenState createState() => _OrganizationScreenState();
}

class _OrganizationScreenState extends State<OrganizationScreen> {
  TextEditingController dateController = TextEditingController();
  TextEditingController addAmountController = TextEditingController();
  TextEditingController currentBalanceController = TextEditingController();
  Admin admin = CustomWidgets.currentAdmin();
  double currentBalance =0;
  bool _isLoading = false;
  var advanceOrganizationBox = Hive.box<List<AdvanceOrganization>>('advanceOrganizationBox');
  List<AdvanceOrganization> advanceOrganizationList = [];
  @override
  void initState() {
    super.initState();
    loadData();
    dateController.text = DateFormat('dd/MM/yyyy').format(DateTime.now());
    currentBalance = admin.currentBalance??0;
    currentBalanceController.text = admin.currentBalance.toString();
  }
  void loadData()async{
   setState(() {
     _isLoading = true;
   });
   List<AdvanceOrganization> list = await AdvanceOrganizationService.getAdvanceOrganization(admin.id!);
   setState(() {
     advanceOrganizationList.addAll(list);
   });
   print( advanceOrganizationList.length);
   print("'''''''''''''''''''''''object'''''''''''''''''''''''");
   setState(() {
     _isLoading = false;
   });
  }
  void _saveData()async{
    double addAmount = double.tryParse(addAmountController.text) ?? 0;
    double previousBalance = currentBalance;
     currentBalance = currentBalance + addAmount;
    print(previousBalance);
    print(addAmount);
    print(currentBalance);
    AdvanceOrganization advanceOrganization = AdvanceOrganization(
      date: DateTime.now().toIso8601String(),
      previousBalance: previousBalance,
      addAmount: addAmount,
      totalBalance: currentBalance,
      adminId: admin.id!
    );
    print("admain organization ${advanceOrganization.adminId}");
    setState(() {
      _isLoading = true;
    });
    bool isAdvanceOrganizationUpdated = await AdvanceOrganizationService.addAdvanceOrganization(advanceOrganization);
    setState(() {
      _isLoading = false;
    });
    if(isAdvanceOrganizationUpdated)
   {
     setState(()  {

       advanceOrganizationList.add(advanceOrganization);
       advanceOrganizationBox.put('advanceOrganization',advanceOrganizationList);
       addAmountController.clear();
       currentBalanceController.text = currentBalance.toString();
       admin.currentBalance = currentBalance;
     });
     bool? isAdminUpdated = await CustomWidgets.updateAdmin(admin,context);
     if(isAdminUpdated == null)
     {
       // Navigator.of(context).pushAndRemoveUntil(
       //   MaterialPageRoute(builder: (context) => LoginPage()),
       //       (route) => false, // Clears entire stack
       // );
       Fluttertoast.showToast(msg: "null");
       return;
     }
     Fluttertoast.showToast(msg: "saved");
   }
 else{
   Fluttertoast.showToast(msg: "error");
 }


  }

  void updateAdmin()async{
    bool? isAdminUpdated = await CustomWidgets.updateAdmin(admin,context);
    if(isAdminUpdated == null)
    {
      // Navigator.of(context).pushAndRemoveUntil(
      //   MaterialPageRoute(builder: (context) => LoginPage()),
      //       (route) => false, // Clears entire stack
      // );
      return;
    }
  }
  void _deleteData(int index) async{
    setState(() {
      _isLoading = true;
    });
    bool isDeleted =await AdvanceOrganizationService.deleteAdvanceOrganization(advanceOrganizationList[index]);
     setState(() {
       _isLoading = false;
     });
      if(isDeleted) {
        setState(() {
      advanceOrganizationList.removeAt(index);
      advanceOrganizationBox.put('advanceOrganization',advanceOrganizationList);
      Fluttertoast.showToast(msg: "Deleted");
    });
      }
      else{
        Fluttertoast.showToast(msg: "Failed to delete");
      }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue[50],
      appBar: CustomWidgets.buildAppBar('Advance Organization'),
      body:
      Stack(
        children:[ SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                TextField(
                  controller: dateController,
                  readOnly: true,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: "Date",
                    fillColor: Colors.white,
                    filled: true,
                  ),
                ),
                SizedBox(height: 10),
                TextField(
                  readOnly: true,
                  controller: currentBalanceController,
                  decoration: InputDecoration(
                    labelText: "Current Balance",
                    fillColor: Colors.white,
                    filled: true,
                    border: OutlineInputBorder(),
                  ),
                ),
                SizedBox(height: 10),
                TextField(
                  controller: addAmountController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: "Add Amount",
                    fillColor: Colors.white,
                    filled: true,
                    border: OutlineInputBorder(),
                  ),
                  //  onChanged: (_) => _updateTotalBalance(),
                ),
                SizedBox(height: 10),
                // ElevatedButton(
                //   onPressed: _saveData,
                //   child: Text("Add"),
                // ),
                CustomWidgets.buttonloader(_isLoading, _saveData, "Save"),
                SizedBox(height: 20),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal, // Enables horizontal scrolling
                  child: SingleChildScrollView(
                      scrollDirection: Axis.vertical, // Enables vertical scrolling
                      child: DataTable(
                        border: TableBorder.all(color: Colors.black, width: 1),
                        columnSpacing: 10,
                        headingRowColor: WidgetStateProperty.all(Color(0xFF24A1DE)),
                        dataRowColor: WidgetStateProperty.all(Colors.white),

                        columns: [
                          DataColumn(label: Text("Date", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white))),
                          DataColumn(label: Text("Pre Bal", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white))),
                          DataColumn(label: Text("Add Amt", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white))),
                          DataColumn(label: Text("Total Bal", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white))),
                          DataColumn(label: Text("Delete", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white))),
                        ],

                        rows: List.generate(
                          advanceOrganizationList.length,
                              (index) {
                            AdvanceOrganization org = advanceOrganizationList.reversed.toList()[index];
                            DateTime date = DateTime.parse(org.date);
                            return DataRow(cells: [
                              DataCell(Text("${date.day}/${date.month}")),
                              DataCell(Text(org.previousBalance.toString())),
                              DataCell(Text(org.addAmount.toString())),
                              DataCell(Text(org.totalBalance.toString())),
                              DataCell(IconButton(
                                icon: Icon(Icons.delete),
                                onPressed: () => _deleteData(index),
                              )),
                            ]);
                          },
                        ),
                      )

                  ),
                ),
              ],
            ),
          ),
          if (_isLoading)
            Positioned.fill(
              child: Container(
                color: Colors.black.withOpacity(0.3),
                child: Center(child: CircularProgressIndicator()),
              ),
            ),
        ]
      ),

    );
  }
}
