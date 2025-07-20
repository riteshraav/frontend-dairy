import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/intl.dart';
import '../model/Customer.dart';
import '../service/customerAdvanceService.dart';
import '../widgets/appbar.dart';
import '../model/admin.dart';
import '../model/advancecustomerinfo.dart';

class AdvanceScreen extends StatefulWidget {
  List<AdvanceEntry> advanceList;
  AdvanceScreen(this.advanceList);
  @override
  _AdvanceScreenState createState() => _AdvanceScreenState();
}

class _AdvanceScreenState extends State<AdvanceScreen> {
  final Box<List<AdvanceEntry>> AdvanceEntryBox =Hive.box<List<AdvanceEntry>>('advanceBox');
 var  advanceBox = Hive.box<List<AdvanceEntry>>('advanceBox');
  Admin admin = CustomWidgets.currentAdmin();
  TextEditingController dateController = TextEditingController();
  TextEditingController codeController = TextEditingController();
  TextEditingController nameController = TextEditingController();
  TextEditingController advanceAmountController = TextEditingController();
  TextEditingController noteController = TextEditingController();
  TextEditingController interestRateController = TextEditingController();
  TextEditingController deductionValueController = TextEditingController();
  String autoDeductionType = "Deduct Litre wise";
  List<Customer> customerList = CustomWidgets.allCustomers();
  String selectedPaymentMethod = "Credit";
  bool isEditing = false;
  int? editingIndex;
  bool isLoading = false;
  late AdvanceEntry selectedEntry;

  @override
  void initState() {
    super.initState();
    dateController.text = DateFormat('dd/MM/yyyy').format(DateTime.now());
  }
  List<AdvanceEntry> list = [];
  void _saveData() {
    List<AdvanceEntry> advanceEntry = advanceBox.get('advance')??[];

    if(advanceAmountController.text != "" ) {
      final entry = AdvanceEntry(
          date: DateTime.now().toIso8601String(),
          code: codeController.text,
          name: nameController.text,
          advanceAmount: double.parse(advanceAmountController.text),
          note: noteController.text,
          interestRate: double.tryParse(interestRateController.text) ?? 0.0,
          paymentMethod: selectedPaymentMethod,
          adminId: admin.id!,
          remainingInterest: 0.0, recentDeduction: DateTime.now().toIso8601String()
      );

      if (isEditing && editingIndex != null) {
        // **Update existing entry instead of adding a new one**
        entry.date = selectedEntry.date;
        advanceEntry[editingIndex!] = entry;
        setState(() {
          isEditing = false;
        });

      } else {
        // **Add new entry**
        advanceEntry.add(entry);
      }
      setState(() {
        isLoading = true;
      });
      CustomerAdvanceService.addCustomerAdvance(entry);
      setState(() {
        isLoading = false;
      });
      advanceBox.put('advance', advanceEntry);

      setState(() {
       list = advanceEntry;
     });

    }
    else{
      Fluttertoast.showToast(msg: "Enter advance amount");
    }

    _clearFields();
  }
  double calculateInterest(AdvanceEntry entry){
    return (entry.advanceAmount * entry.interestRate * (DateTime.now().difference(DateTime.parse(entry.date)).inDays)/365) * 0.01;
  }

  void handleDuplicateEntry(AdvanceEntry   entry) async{
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
                widget.advanceList.remove(entry);
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
  void _clearFields() {
    setState(() {
      codeController.clear();
      nameController.clear();
      advanceAmountController.clear();
      noteController.clear();
      interestRateController.clear();
      deductionValueController.clear();
      selectedPaymentMethod = "Credit";
      isEditing = false;
      editingIndex = null;
    });
  }

  void _editData(int index, AdvanceEntry entry) {
    setState(() {
      selectedEntry = entry;
      codeController.text = entry.code;
      nameController.text = entry.name;
      advanceAmountController.text = entry.advanceAmount.toString();
      noteController.text = entry.note;
      interestRateController.text = entry.interestRate.toString();
      selectedPaymentMethod = entry.paymentMethod;

      isEditing = true;
      editingIndex = index;
    });
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue[50],
      appBar: CustomWidgets.buildAppBar(" Customer Advance",[],IconButton(onPressed: ()=>{
        print("advance list size is ${widget.advanceList.length}"),
        Navigator.pop(context,widget.advanceList)
      }, icon: Icon(Icons.arrow_back))),

      body:isLoading? Center(child: CircularProgressIndicator()): SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Column(
            children: [
              TextField(controller: dateController, readOnly: true, decoration: InputDecoration(labelText: "Date",
                  fillColor: Colors.white,
                  filled: true,
                  border: OutlineInputBorder())),
              SizedBox(height: 15),
              Row(
                children: [
                  SizedBox(
                    width: 112,
                    child: Autocomplete<Customer>(
                      optionsBuilder: (TextEditingValue textEditingValue) {
                        return customerList
                            .where((supplier) => supplier.code!.contains(textEditingValue.text))
                            .toList();
                      },
                      displayStringForOption: (Customer option) => "${option.code!} - ${option.name!}",
                      onSelected: (Customer selection) {
                        _clearFields();

                        AdvanceEntry? entryToBeDeleted;

                        try {
                          entryToBeDeleted = widget.advanceList.firstWhere(
                                (entry) => selection.code == entry.code,
                          );
                        } catch (e) {
                          entryToBeDeleted = null;
                        }


                        if (entryToBeDeleted != null && entryToBeDeleted.advanceAmount != 0.0) {

                          print("entry is duplicate and must delete it ${entryToBeDeleted.advanceAmount }/////////////////////");
                          handleDuplicateEntry(entryToBeDeleted);
                          return;
                        }
                        print("entry is not duplicate");


                        codeController.text = selection.code!;
                        nameController.text = selection.name!;
                        FocusScope.of(context).unfocus(); // Hide suggestions
                      },
                      fieldViewBuilder: (context, controller, focusNode, onEditingComplete) {
                        codeController = controller;
                        return TextField(
                          controller: controller,
                          focusNode: focusNode,
                          decoration: InputDecoration(
                            fillColor: Colors.white,
                            filled: true,
                            labelText: "Code",
                            border: OutlineInputBorder(),
                            suffixIcon: Icon(Icons.search),
                          ),
                        );
                      },
                    ),
                  ),
                  SizedBox(width: 10),
                  Expanded(
                    child: Autocomplete<Customer>(
                      optionsBuilder: (TextEditingValue textEditingValue) {
                        return customerList
                            .where((supplier) => supplier.name!.toLowerCase().contains(textEditingValue.text.toLowerCase()))
                            .toList();
                      },
                      displayStringForOption: (Customer option) => "${option.code!} - ${option.name!}",
                      onSelected: (Customer selection) {
                        _clearFields();
                        AdvanceEntry? entryToBeDeleted;

                        try {
                          entryToBeDeleted = widget.advanceList.firstWhere(
                                (entry) => selection.code == entry.code,
                          );
                        } catch (e) {
                          entryToBeDeleted = null;
                        }

                        if (entryToBeDeleted != null   && entryToBeDeleted.advanceAmount != 0.0) {

                          print("entry is duplicate");
                          handleDuplicateEntry(entryToBeDeleted);
                          return;
                        }
                        print("entry is not duplicate");
                        codeController.text = selection.code!;
                        nameController.text = selection.name!;
                        FocusScope.of(context).unfocus(); // Hide suggestions
                      },
                      fieldViewBuilder: (context, controller, focusNode, onEditingComplete) {
                        nameController = controller;
                        return TextField(
                          controller: controller,
                          focusNode: focusNode,
                          decoration: InputDecoration(
                            fillColor: Colors.white,
                            filled: true,
                            labelText: "Customer Name",
                            border: OutlineInputBorder(),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
              SizedBox(height: 15),
              TextField(controller: advanceAmountController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(labelText: "Advance Amount",
                      fillColor: Colors.white,
                      filled: true,border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.symmetric(vertical: 6, horizontal: 10),)),
              SizedBox(height: 15),
              TextField(controller: noteController, decoration: InputDecoration(labelText: "Note",
                  fillColor: Colors.white,
                  filled: true,border: OutlineInputBorder(),
              contentPadding: EdgeInsets.symmetric(vertical: 6, horizontal: 10),)),
              SizedBox(height: 15),
              TextField(controller: interestRateController, keyboardType: TextInputType.number,
                  decoration: InputDecoration(labelText: "Interest Rate",
                      fillColor: Colors.white,
                      filled: true,border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.symmetric(vertical: 6, horizontal: 10),)),
              SizedBox(height: 15),

              DropdownButtonFormField<String>(
                value: selectedPaymentMethod,
                decoration: InputDecoration(labelText: "Payment Method",
                    fillColor: Colors.white,
                    filled: true,border: OutlineInputBorder(),
                  contentPadding: EdgeInsets.symmetric(vertical: 6, horizontal: 10),),
                items: ["Credit", "Cash"].map((method) {
                  return DropdownMenuItem(value: method, child: Text(method));
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    selectedPaymentMethod = value!;
                  });
                },
              ),

              SizedBox(height: 10),
              ElevatedButton(
                onPressed: _saveData,
                child: Text(isEditing ? "Update" : "Save",style: TextStyle(color: Colors.white),),
                style: CustomWidgets.elevated(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
