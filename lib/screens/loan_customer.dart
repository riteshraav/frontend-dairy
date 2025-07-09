// import 'package:flutter/material.dart';
// import 'package:fluttertoast/fluttertoast.dart';
// import 'package:hive/hive.dart';
// import 'package:hive_flutter/hive_flutter.dart';
// import 'package:intl/intl.dart';
// import '../service/loanentry_service.dart';
// import '../widgets/appbar.dart';
// import '../model/Customer.dart';
// import '../model/admin.dart';
// import '../model/loancustomerinfo.dart';
//
// class LoanScreen extends StatefulWidget {
//   List<LoanEntry> loanEntry ;
//   LoanScreen(this.loanEntry);
//   @override
//   _LoanScreenState createState() => _LoanScreenState();
// }
//
// class _LoanScreenState extends State<LoanScreen> {
//
//   final Box<List<LoanEntry>> loanEntryBox = Hive.box<List<LoanEntry>>('loanEntryBox');
//   TextEditingController dateController = TextEditingController();
//   TextEditingController codeController = TextEditingController();
//   TextEditingController nameController = TextEditingController();
//   TextEditingController LoanAmountController = TextEditingController();
//   TextEditingController noteController = TextEditingController();
//   TextEditingController interestRateController = TextEditingController();
//   String selectedPaymentMethod = "Credit";
//   bool isEditing = false;
//   int? editingIndex;
//   Admin admin = CustomWidgets.currentAdmin();
//   List<LoanEntry> loanEntryList = [];
//   List<Customer> customerList = CustomWidgets.allCustomers();
//   late Customer selectedCustomer ;
//
//   @override
//   void initState() {
//     super.initState();
//     loanEntryList = loanEntryBox.get('loanEntry')??[];
//     dateController.text = DateFormat('dd/MM/yyyy').format(DateTime.now());
//   }
//
//   void _saveData() async{
//     final loanEntry = LoanEntry(
//       remainingInterest: 0.0,
//       recentDeduction: DateTime.now().toIso8601String(),
//       date: DateTime.now().toIso8601String(),
//       customerId: codeController.text,
//       adminId:admin.id!,
//       loanAmount: double.tryParse(LoanAmountController.text) ?? 0.0,
//       note: noteController.text,
//       interestRate: double.tryParse(interestRateController.text) ?? 0.0,
//       modeOfPayback: selectedPaymentMethod,
//     );
//
//
//     if (isEditing && editingIndex != null) {
//       loanEntryList[editingIndex!] = loanEntry;
//       // **Update existing entry instead of adding a new one**
//     } else {
//       // **Add new entry**
//       loanEntryList.add(loanEntry);
//     }
//     loanEntryBox.put('loanEntry', loanEntryList);
//     bool isSuccessful = await LoanEntryService.addLoanEntry(loanEntry);
//     if(isSuccessful)
//       {
//         Fluttertoast.showToast(msg: "entry saved");
//       }
//     _clearFields();
//   }
//   double calculateInterest(LoanEntry entry){
//     return (entry.loanAmount * entry.interestRate * (DateTime.now().difference(DateTime.parse(entry.date)).inDays)/365) * 0.01;
//   }
//
//   void handleDuplicateEntry(LoanEntry   entry) async{
//     showDialog(
//       context: context,
//       builder: (context) => AlertDialog(
//         titlePadding: EdgeInsets.all(15),
//         contentPadding: EdgeInsets.symmetric(horizontal: 10),
//         actionsPadding: EdgeInsets.only(bottom: 10, right: 10),
//         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
//         title: Text("Previous Advance", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
//         content: SingleChildScrollView(
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Text(
//                 'This customer already has lend money:',
//                 style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
//               ),
//               ListTile(
//                 dense: true, // Makes tiles more compact
//                 leading: Text(
//                   "Code : ${entry.customerId}",
//                   style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
//                 ),
//               ),
//               ListTile(
//                 dense: true, // Makes tiles more compact
//                 leading: Text(
//                   "Name : ${CustomWidgets.searchCustomerName(entry.customerId)}",
//                   style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
//                 ),
//               ),
//               ListTile(
//                 dense: true, // Makes tiles more compact
//                 leading: Text(
//                   "Amount : ${entry.loanAmount}",
//                   style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
//                 ),
//               ),
//               ListTile(
//                 dense: true, // Makes tiles more compact
//                 leading: Text(
//                   "Rate : ${entry.interestRate}",
//                   style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
//                 ),
//               ),
//               ListTile(
//                 dense: true, // Makes tiles more compact
//                 leading: Text(
//                   "Interest : ${calculateInterest(entry)}",
//                   style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
//                 ),
//               ),
//
//
//             ],
//           ),
//         ),
//
//         actions: [
//           TextButton(
//             child: Text("Cancel", style: TextStyle(color: Colors.grey[700])),
//             onPressed: () => Navigator.pop(context),
//           ),
//           CustomWidgets.customButton(text:  "Delete",onPressed:  () async {
//             bool customerDeleted = await LoanEntryService.deleteLoanEntry(entry);
//             if (customerDeleted) {
//               widget.loanEntry.remove(entry);
//               Fluttertoast.showToast(msg: "Deleted Successfully");
//             } else {
//               Fluttertoast.showToast(msg: "Error");
//             }
//             Navigator.pop(context);
//           },buttonBackgroundColor:  Colors.red)
//         ],
//       ),
//     );
//   }
//
//   void _clearFields() {
//     setState(() {
//       codeController.clear();
//       nameController.clear();
//       LoanAmountController.clear();
//       noteController.clear();
//       interestRateController.clear();
//       selectedPaymentMethod = "Credit";
//       isEditing = false;
//       editingIndex = null;
//     });
//   }
//
//   void _editData(int index,LoanEntry entry) {
//     setState(() {
//       codeController.text = entry.customerId;
//       nameController.text = entry.adminId;
//       LoanAmountController.text = entry.loanAmount.toString();
//       noteController.text = entry.note;
//       interestRateController.text = entry.interestRate.toString();
//       selectedPaymentMethod = entry.modeOfPayback;
//       isEditing = true;
//       editingIndex = index;
//     });
//   }
//
//   void _deleteData(int index) {
//     LoanEntry loanEntry = loanEntryList.removeAt(index);
//     loanEntryBox.put('loanEntry',loanEntryList);
//     print("${loanEntry.adminId}_${loanEntry.customerId}");
//     LoanEntryService.deleteLoanEntry(loanEntry);
//     _clearFields();
//     setState(() {});
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return PopScope(
//         onPopInvokedWithResult:(bool didPop, Object? result) async {
//       if (didPop) {
//         Navigator.pop(context,widget.loanEntry);
//       }},
//       child: Scaffold(
//         backgroundColor: Colors.blue[50],
//         appBar: CustomWidgets.buildAppBar(" Customer Loan",[],IconButton(onPressed: ()=>{
//           print("advance list size is ${widget.loanEntry.length}"),
//           Navigator.pop(context,widget.loanEntry)
//         }, icon: Icon(Icons.arrow_back))),
//         body: SingleChildScrollView(
//           child: Padding(
//             padding: EdgeInsets.all(16.0),
//             child: Column(
//               children: [
//                 TextField(controller: dateController, readOnly: true, decoration: InputDecoration(labelText: "Date",
//                     fillColor: Colors.white,
//                     filled: true,
//                     border: OutlineInputBorder())),
//                 SizedBox(height: 15),
//                 Row(
//                   children: [
//                     SizedBox(
//                       width: 112,
//                       child: Autocomplete<Customer>(
//                         optionsBuilder: (TextEditingValue textEditingValue) {
//                           return customerList
//                               .where((supplier) => supplier.code!.contains(textEditingValue.text))
//                               .toList();
//                         },
//                         displayStringForOption: (Customer option) => "${option.code!} - ${option.name!}",
//                         onSelected: (Customer selection) {
//                           _clearFields();
//                           LoanEntry? entryToBeDeleted;
//
//                           try {
//                             entryToBeDeleted = widget.loanEntry.firstWhere(
//                                   (entry) => selection.code == entry.customerId,
//                             );
//                           } catch (e) {
//                             entryToBeDeleted = null;
//                           }
//
//                           if (entryToBeDeleted != null   && entryToBeDeleted.loanAmount != 0.0) {
//
//                             print("entry is duplicate");
//                             handleDuplicateEntry(entryToBeDeleted);
//                             return;
//                           }
//                           print("entry is not duplicate");
//                           codeController.text = selection.code!;
//                           nameController.text = selection.name!;
//                           selectedCustomer = selection;
//                           FocusScope.of(context).unfocus(); // Hide suggestions
//                         },
//                         fieldViewBuilder: (context, controller, focusNode, onEditingComplete) {
//                           codeController = controller;
//                           return TextField(
//                             controller: controller,
//                             focusNode: focusNode,
//                             decoration: InputDecoration(
//                               filled: true,
//                               fillColor: Colors.white,
//                               labelText: "Code",
//                               border: OutlineInputBorder(),
//                               suffixIcon: Icon(Icons.search),
//                             ),
//                           );
//                         },
//                       ),
//                     ),
//                     SizedBox(width: 10),
//                     Expanded(
//                       child: Autocomplete<Customer>(
//                         optionsBuilder: (TextEditingValue textEditingValue) {
//                           return customerList
//                               .where((supplier) => supplier.name!.toLowerCase().contains(textEditingValue.text.toLowerCase()))
//                               .toList();
//                         },
//                         displayStringForOption: (Customer option) => "${option.code!} - ${option.name!}",
//                         onSelected: (Customer selection) {
//                           _clearFields();
//
//                           LoanEntry? entryToBeDeleted;
//
//                           try {
//                             entryToBeDeleted = widget.loanEntry.firstWhere(
//                                   (entry) => selection.code == entry.customerId,
//                             );
//                           } catch (e) {
//                             entryToBeDeleted = null;
//                           }
//
//                           if (entryToBeDeleted != null   && entryToBeDeleted.loanAmount != 0.0) {
//
//                             print("entry is duplicate");
//                             handleDuplicateEntry(entryToBeDeleted);
//                             return;
//                           }
//                           print("entry is not duplicate");
//                           codeController.text = selection.code!;
//                           nameController.text = selection.name!;
//                           selectedCustomer = selection;
//                           FocusScope.of(context).unfocus(); // Hide suggestions
//                         },
//                         fieldViewBuilder: (context, controller, focusNode, onEditingComplete) {
//                           nameController = controller;
//                           return TextField(
//                             controller: controller,
//                             focusNode: focusNode,
//                             decoration: InputDecoration(
//                               filled: true,
//                               fillColor: Colors.white,
//                               labelText: "Customer Name",
//                               border: OutlineInputBorder(),
//                             ),
//                           );
//                         },
//                       ),
//                     ),
//                   ],
//                 ),
//                 SizedBox(height: 15),
//                 TextField(controller: LoanAmountController,
//                     keyboardType: TextInputType.number,
//                     decoration: InputDecoration(labelText: "Loan Amount",
//
//                       fillColor: Colors.white,
//                       filled: true,border: OutlineInputBorder(),
//                       contentPadding: EdgeInsets.symmetric(vertical: 6, horizontal: 10),)),
//                 SizedBox(height: 15),
//                 TextField(controller: noteController, decoration: InputDecoration(labelText: "Note",
//                   fillColor: Colors.white,
//                   filled: true,border: OutlineInputBorder(),
//                   contentPadding: EdgeInsets.symmetric(vertical: 6, horizontal: 10),)),
//                 SizedBox(height: 15),
//                 TextField(controller: interestRateController, keyboardType: TextInputType.number,
//                     decoration: InputDecoration(labelText: "Interest Rate",
//                       fillColor: Colors.white,
//                       filled: true,border: OutlineInputBorder(),
//                       contentPadding: EdgeInsets.symmetric(vertical: 6, horizontal: 10),)),
//                 SizedBox(height: 15),
//
//                 DropdownButtonFormField<String>(
//                   value: selectedPaymentMethod,
//                   decoration: InputDecoration(labelText: "Payment Method",
//                     fillColor: Colors.white,
//                     filled: true,border: OutlineInputBorder(),
//                     contentPadding: EdgeInsets.symmetric(vertical: 6, horizontal: 10),),
//                   items: ["Credit", "Cash"].map((method) {
//                     return DropdownMenuItem(value: method, child: Text(method));
//                   }).toList(),
//                   onChanged: (value) {
//                     setState(() {
//                       selectedPaymentMethod = value!;
//                     });
//                   },
//                 ),
//                 SizedBox(height: 15),
//                 CustomWidgets.customButton(text:"save", onPressed: _saveData),
//                 SizedBox(height: 15),
//
//                 SingleChildScrollView(
//                   scrollDirection: Axis.horizontal,
//                   child: DataTable(
//                     columnSpacing: 8,
//                     headingRowHeight: 45,
//                     border: TableBorder.all(),
//                     headingRowColor: MaterialStateProperty.all(Color(0xFF24A1DE)),
//                     columns: [
//                       //DataColumn(label: Text("Date",style: TextStyle(color: Colors.white),)),
//                       DataColumn(label: Text("Code",style: TextStyle(color: Colors.white),)),
//                       //DataColumn(label: Text("Name",style: TextStyle(color: Colors.white),)),
//                       DataColumn(label: Text("Amt",style: TextStyle(color: Colors.white),)),
//                       DataColumn(label: Text("Interest",style: TextStyle(color: Colors.white),)),
//                       DataColumn(label: Text("Pay",style: TextStyle(color: Colors.white),)),
//                       DataColumn(label: Text("Edit",style: TextStyle(color:Colors.white),)),
//                       DataColumn(label: Text("Delete",style: TextStyle(color: Colors.white),)),
//                     ],
//                     rows: List.generate(
//                       loanEntryList.length,
//                           (index) {
//                         final entry = loanEntryList[index];
//                         return DataRow(cells: [
//                           //DataCell(Text(dateController.text)),
//                           DataCell(Text(entry.customerId)),
//                          // DataCell(Text(selectedCustomer.name!)),
//                           DataCell(Text(entry.loanAmount.toString())),
//                           DataCell(Text(entry.interestRate.toString())),
//                           DataCell(Text(entry.modeOfPayback)),
//                           DataCell(IconButton(icon: Icon(Icons.edit), onPressed: () => _editData(index, entry))),
//                           DataCell(IconButton(icon: Icon(Icons.delete), onPressed: () => _deleteData(index))),
//                             ],
//
//                         );
//                       },
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }
//
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/intl.dart';
import '../service/loanentry_service.dart';
import '../widgets/appbar.dart';
import '../model/Customer.dart';
import '../model/admin.dart';
import '../model/loancustomerinfo.dart';

class LoanScreen extends StatefulWidget {
  List<LoanEntry> loanEntry;
  LoanScreen(this.loanEntry);
  @override
  _LoanScreenState createState() => _LoanScreenState();
}

class _LoanScreenState extends State<LoanScreen> {
  final Box<List<LoanEntry>> loanEntryBox = Hive.box<List<LoanEntry>>('loanEntryBox');
  TextEditingController dateController = TextEditingController();
  TextEditingController codeController = TextEditingController();
  TextEditingController nameController = TextEditingController();
  TextEditingController LoanAmountController = TextEditingController();
  TextEditingController noteController = TextEditingController();
  TextEditingController interestRateController = TextEditingController();
  String selectedPaymentMethod = "Credit";
  bool isEditing = false;
  int? editingIndex;
  Admin admin = CustomWidgets.currentAdmin();
  List<LoanEntry> loanEntryList = [];
  List<Customer> customerList = CustomWidgets.allCustomers();
  late Customer selectedCustomer;

  @override
  void initState() {
    super.initState();
    loanEntryList = loanEntryBox.get('loanEntry') ?? [];
    dateController.text = DateFormat('dd/MM/yyyy').format(DateTime.now());
  }

  void _saveData() async {
    final loanEntry = LoanEntry(
      remainingInterest: 0.0,
      recentDeduction: DateTime.now().toIso8601String(),
      date: DateTime.now().toIso8601String(),
      customerId: codeController.text,
      adminId: admin.id!,
      loanAmount: double.tryParse(LoanAmountController.text) ?? 0.0,
      note: noteController.text,
      interestRate: double.tryParse(interestRateController.text) ?? 0.0,
      modeOfPayback: selectedPaymentMethod,
    );

    if (isEditing && editingIndex != null) {
      loanEntryList[editingIndex!] = loanEntry;
    } else {
      loanEntryList.add(loanEntry);
    }

    loanEntryBox.put('loanEntry', loanEntryList);
    bool isSuccessful = await LoanEntryService.addLoanEntry(loanEntry);
    if (isSuccessful) {
      Fluttertoast.showToast(msg: "Entry saved");
    }
    _clearFields();
    setState(() {});
  }

  double calculateInterest(LoanEntry entry) {
    final loanAmount = entry.loanAmount ?? 0.0;
    final interestRate = entry.interestRate ?? 0.0;
    return (loanAmount * interestRate * (DateTime.now().difference(DateTime.parse(entry.date)).inDays) / 365) * 0.01;
  }

  void handleDuplicateEntry(LoanEntry entry) async {
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
              Text('This customer already has lend money:', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ListTile(leading: Text("Code : ${entry.customerId}", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500))),
              ListTile(leading: Text("Name : ${CustomWidgets.searchCustomerName(entry.customerId)}", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500))),
              ListTile(leading: Text("Amount : ${entry.loanAmount ?? 0.0}", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500))),
              ListTile(leading: Text("Rate : ${entry.interestRate ?? 0.0}", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500))),
              ListTile(leading: Text("Interest : ${calculateInterest(entry)}", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500))),
            ],
          ),
        ),
        actions: [
          TextButton(
            child: Text("Cancel", style: TextStyle(color: Colors.grey[700])),
            onPressed: () => Navigator.pop(context),
          ),
          CustomWidgets.customButton(
            text: "Delete",
            onPressed: () async {
              bool customerDeleted = await LoanEntryService.deleteLoanEntry(entry);
              if (customerDeleted) {
                widget.loanEntry.remove(entry);
                Fluttertoast.showToast(msg: "Deleted Successfully");
              } else {
                Fluttertoast.showToast(msg: "Error");
              }
              Navigator.pop(context);
            },
            buttonBackgroundColor: Colors.red,
          )
        ],
      ),
    );
  }

  void _clearFields() {
    setState(() {
      codeController.clear();
      nameController.clear();
      LoanAmountController.clear();
      noteController.clear();
      interestRateController.clear();
      selectedPaymentMethod = "Credit";
      isEditing = false;
      editingIndex = null;
    });
  }

  void _editData(int index, LoanEntry entry) {
    setState(() {
      codeController.text = entry.customerId;
      nameController.text = entry.adminId;
      LoanAmountController.text = (entry.loanAmount ?? 0.0).toString();
      noteController.text = entry.note;
      interestRateController.text = (entry.interestRate ?? 0.0).toString();
      selectedPaymentMethod = entry.modeOfPayback;
      isEditing = true;
      editingIndex = index;
    });
  }

  void _deleteData(int index) {
    LoanEntry loanEntry = loanEntryList.removeAt(index);
    loanEntryBox.put('loanEntry', loanEntryList);
    LoanEntryService.deleteLoanEntry(loanEntry);
    _clearFields();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      onPopInvokedWithResult: (bool didPop, Object? result) async {
        if (didPop) {
          Navigator.pop(context, widget.loanEntry);
        }
      },
      child: Scaffold(
        backgroundColor: Colors.blue[50],
        appBar: CustomWidgets.buildAppBar(" Customer Loan", [], IconButton(onPressed: () {
          Navigator.pop(context, widget.loanEntry);
        }, icon: Icon(Icons.arrow_back))),
        body: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.all(16.0),
            child: Column(
              children: [
                TextField(controller: dateController, readOnly: true, decoration: InputDecoration(labelText: "Date", fillColor: Colors.white, filled: true, border: OutlineInputBorder())),
                SizedBox(height: 15),
                Row(
                  children: [
                    SizedBox(
                      width: 112,
                      child: Autocomplete<Customer>(
                        optionsBuilder: (text) => customerList.where((s) => s.code!.contains(text.text)).toList(),
                        displayStringForOption: (option) => "${option.code!} - ${option.name!}",
                        onSelected: (selection) {
                          _clearFields();
                          LoanEntry? entry = widget.loanEntry.firstWhere((entry) => selection.code == entry.customerId, orElse: () => LoanEntry(loanAmount: 0.0, interestRate: 0.0, remainingInterest: 0.0, recentDeduction: '', date: '', customerId: '', adminId: '', note: '', modeOfPayback: ''));
                          if (entry.loanAmount != 0.0) {
                            handleDuplicateEntry(entry);
                            return;
                          }
                          codeController.text = selection.code!;
                          nameController.text = selection.name!;
                          selectedCustomer = selection;
                          FocusScope.of(context).unfocus();
                        },
                        fieldViewBuilder: (context, controller, focusNode, onEditingComplete) {
                          codeController = controller;
                          return TextField(
                            controller: controller,
                            focusNode: focusNode,
                            decoration: InputDecoration(filled: true, fillColor: Colors.white, labelText: "Code", border: OutlineInputBorder(), suffixIcon: Icon(Icons.search)),
                          );
                        },
                      ),
                    ),
                    SizedBox(width: 10),
                    Expanded(
                      child: Autocomplete<Customer>(
                        optionsBuilder: (text) => customerList.where((s) => s.name!.toLowerCase().contains(text.text.toLowerCase())).toList(),
                        displayStringForOption: (option) => "${option.code!} - ${option.name!}",
                        onSelected: (selection) {
                          _clearFields();
                          LoanEntry? entry = widget.loanEntry.firstWhere((entry) => selection.code == entry.customerId, orElse: () => LoanEntry(loanAmount: 0.0, interestRate: 0.0, remainingInterest: 0.0, recentDeduction: '', date: '', customerId: '', adminId: '', note: '', modeOfPayback: ''));
                          if (entry.loanAmount != 0.0) {
                            handleDuplicateEntry(entry);
                            return;
                          }
                          codeController.text = selection.code!;
                          nameController.text = selection.name!;
                          selectedCustomer = selection;
                          FocusScope.of(context).unfocus();
                        },
                        fieldViewBuilder: (context, controller, focusNode, onEditingComplete) {
                          nameController = controller;
                          return TextField(
                            controller: controller,
                            focusNode: focusNode,
                            decoration: InputDecoration(filled: true, fillColor: Colors.white, labelText: "Customer Name", border: OutlineInputBorder()),
                          );
                        },
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 15),
                TextField(controller: LoanAmountController, keyboardType: TextInputType.number, decoration: InputDecoration(labelText: "Loan Amount", fillColor: Colors.white, filled: true, border: OutlineInputBorder(), contentPadding: EdgeInsets.symmetric(vertical: 6, horizontal: 10))),
                SizedBox(height: 15),
                TextField(controller: noteController, decoration: InputDecoration(labelText: "Note", fillColor: Colors.white, filled: true, border: OutlineInputBorder(), contentPadding: EdgeInsets.symmetric(vertical: 6, horizontal: 10))),
                SizedBox(height: 15),
                TextField(controller: interestRateController, keyboardType: TextInputType.number, decoration: InputDecoration(labelText: "Interest Rate", fillColor: Colors.white, filled: true, border: OutlineInputBorder(), contentPadding: EdgeInsets.symmetric(vertical: 6, horizontal: 10))),
                SizedBox(height: 15),
                DropdownButtonFormField<String>(
                  value: selectedPaymentMethod,
                  decoration: InputDecoration(labelText: "Payment Method", fillColor: Colors.white, filled: true, border: OutlineInputBorder(), contentPadding: EdgeInsets.symmetric(vertical: 6, horizontal: 10)),
                  items: ["Credit", "Cash"].map((method) => DropdownMenuItem(value: method, child: Text(method))).toList(),
                  onChanged: (value) => setState(() => selectedPaymentMethod = value!),
                ),
                SizedBox(height: 15),
                CustomWidgets.customButton(text: "Save", onPressed: _saveData),
                SizedBox(height: 15),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: DataTable(
                    columnSpacing: 8,
                    headingRowHeight: 45,
                    border: TableBorder.all(),
                    headingRowColor: MaterialStateProperty.all(Color(0xFF24A1DE)),
                    columns: [
                      DataColumn(label: Text("Code", style: TextStyle(color: Colors.white))),
                      DataColumn(label: Text("Amt", style: TextStyle(color: Colors.white))),
                      DataColumn(label: Text("Interest", style: TextStyle(color: Colors.white))),
                      DataColumn(label: Text("Pay", style: TextStyle(color: Colors.white))),
                      DataColumn(label: Text("Edit", style: TextStyle(color: Colors.white))),
                      DataColumn(label: Text("Delete", style: TextStyle(color: Colors.white))),
                    ],
                    rows: List.generate(loanEntryList.length, (index) {
                      final entry = loanEntryList[index];
                      return DataRow(cells: [
                        DataCell(Text(entry.customerId)),
                        DataCell(Text((entry.loanAmount ?? 0.0).toString())),
                        DataCell(Text((entry.interestRate ?? 0.0).toString())),
                        DataCell(Text(entry.modeOfPayback)),
                        DataCell(IconButton(icon: Icon(Icons.edit), onPressed: () => _editData(index, entry))),
                        DataCell(IconButton(icon: Icon(Icons.delete), onPressed: () => _deleteData(index))),
                      ]);
                    }),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
