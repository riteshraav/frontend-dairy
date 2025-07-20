import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
import '../../model/cattleFeedSupplier.dart';
import '../../service/cattleFeedPurchaseService.dart';
import '../../service/cattleFeedSupplierService.dart';
import '../../widgets/appbar.dart';
import '../../model/admin.dart';
import '../../model/cattleFeedPurchase.dart';

class CattleFeedPurchaseScreen extends StatefulWidget {
  @override
  _CattleFeedPurchaseScreenState createState() => _CattleFeedPurchaseScreenState();
  CattleFeedPurchaseScreen();
}

class _CattleFeedPurchaseScreenState extends State<CattleFeedPurchaseScreen> {
  TextEditingController voucherController = TextEditingController();
  TextEditingController cattleFeedNameController = TextEditingController();
  TextEditingController dateController = TextEditingController();
  TextEditingController codeController = TextEditingController();
  TextEditingController supplierController = TextEditingController();
  TextEditingController qtyController = TextEditingController();
  TextEditingController rateController = TextEditingController();
  TextEditingController amtController = TextEditingController();
  TextEditingController gstController = TextEditingController();
  TextEditingController gstAmtController = TextEditingController();
  TextEditingController commController = TextEditingController();
  TextEditingController wagesController = TextEditingController();
  TextEditingController billAmtController = TextEditingController();
  TextEditingController totalAmtController = TextEditingController();
  Admin admin = CustomWidgets.currentAdmin();
  List<CattleFeedSupplier> cattleFeedSupplierList = [];
  bool _isLoading = false;
  String paymentMethod = 'Credit';
  List<String> paymentMethods = ['Credit', 'Cash'];
  void loadData()async{
    setState(() {
      _isLoading = true;
    });
    cattleFeedSupplierList = await CattleFeedSupplierService.getAllCattleFeedSupplier(admin.id! );
    setState(() {
      _isLoading = false;
    });
  }
  @override
  void initState() {
    super.initState();
    loadData();
    dateController.text = DateFormat('dd/MM/yyyy').format(DateTime.now());
  }


  void _selectDate(BuildContext context) async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );

    if (pickedDate != null) {
      setState(() {
        dateController.text = DateFormat('dd/MM/yyyy').format(pickedDate);
      });
    }
  }
  void calculateAmount() {
    double qty = double.tryParse(qtyController.text) ?? 0;
    double rate = double.tryParse(rateController.text) ?? 0;
    double amount = qty * rate;
    amtController.text = amount.toStringAsFixed(2);
    calculateGST();
  }

  void calculateGST() {
    double amount = double.tryParse(amtController.text) ?? 0;
    double gstPercentage = double.tryParse(gstController.text) ?? 0;
    double gstAmount = (amount * gstPercentage) / 100;
    gstAmtController.text = gstAmount.toStringAsFixed(2);
    calculateBillAmount();
  }

  void calculateBillAmount() {
    double amount = double.tryParse(amtController.text) ?? 0;
    double gstAmount = double.tryParse(gstAmtController.text) ?? 0;
    double comm = double.tryParse(commController.text) ?? 0;
    double wages = double.tryParse(wagesController.text) ?? 0;
    double billAmount = amount + gstAmount + comm + wages;
    billAmtController.text = billAmount.toStringAsFixed(2);
    totalAmtController.text = billAmtController.text;
  }
  void saveCattleFeedPurchase(){

  }
  List<CattleFeedPurchase> savedPurchases = [];
  int? editingIndex;

  Future<void> savePurchase() async {

    if (codeController.text.isNotEmpty &&
        cattleFeedNameController.text.isNotEmpty &&
        supplierController.text.isNotEmpty &&
        qtyController.text.isNotEmpty &&
        rateController.text.isNotEmpty &&
        amtController.text.isNotEmpty &&
        gstController.text.isNotEmpty &&
        gstAmtController.text.isNotEmpty &&
        commController.text.isNotEmpty &&
        wagesController.text.isNotEmpty &&
        billAmtController.text.isNotEmpty &&
        dateController.text.isNotEmpty) {
      CattleFeedPurchase cattleFeedPurchase =  CattleFeedPurchase(
        feedName: cattleFeedNameController.text,
        voucher: '${admin.id}_${DateTime.now().millisecond}',
        code: codeController.text,
        supplier: supplierController.text,
        quantity: int.parse(qtyController.text),
        rate: double.parse(rateController.text),
        amount: double.parse(amtController.text),
        gst: double.parse(gstController.text),
        gstAmount: double.parse(gstAmtController.text),
        commission: double.parse(commController.text),
        wages: double.parse(wagesController.text),
        billAmount: double.parse(billAmtController.text),
        paymentMethod: paymentMethod,
        date: DateTime.now().toIso8601String(),
         totalAmount: double.parse(totalAmtController.text),
        adminId: admin.id
      );
      setState(() {
        if (editingIndex != null) {
          cattleFeedPurchase.date = savedPurchases[editingIndex!].date;
          savedPurchases[editingIndex!] = cattleFeedPurchase; // Update existing cattleFeedPurchase
          editingIndex = null; // Reset editing index
        } else {
          savedPurchases.add(cattleFeedPurchase); // Add new cattleFeedPurchase
        }

        // Clear input fields after saving
        cattleFeedNameController.clear();
        codeController.clear();
        supplierController.clear();
        dateController.clear();
        qtyController.clear();
        rateController.clear();
        amtController.clear();
        gstController.clear();
        gstAmtController.clear();
        commController.clear();
        wagesController.clear();
        billAmtController.clear();
        totalAmtController.clear();
        paymentMethod = 'Credit';
      });
      setState(() {
        _isLoading = true;
      });
      bool isSaved = await CattleFeedPurchaseService.addCattleFeedPurchase(cattleFeedPurchase);
      setState(() {
        _isLoading = false;
      });
      if(isSaved){
        Fluttertoast.showToast(msg: "Info Saved");
      }
      else{
        Fluttertoast.showToast(msg: "Failed to save info");
      }
    } else {
      Fluttertoast.showToast(msg: "Enter values in all fields");
      return;
    }
  }

  void editPurchase(int index) {
    CattleFeedPurchase cattleFeedPurchase = savedPurchases[index];
    cattleFeedNameController.text = cattleFeedPurchase.feedName!;
    codeController.text = cattleFeedPurchase.code!;
    supplierController.text = cattleFeedPurchase.supplier!;
    qtyController.text =cattleFeedPurchase.quantity.toString();
    rateController.text = cattleFeedPurchase.rate.toString();
    amtController.text = cattleFeedPurchase.amount.toString();
    gstController.text = cattleFeedPurchase.gst.toString();
    gstAmtController.text = cattleFeedPurchase.gstAmount.toString();
    commController.text = cattleFeedPurchase.commission.toString();
    wagesController.text = cattleFeedPurchase.wages.toString();
    billAmtController.text = cattleFeedPurchase.billAmount.toString();
    paymentMethod = cattleFeedPurchase.paymentMethod.toString();
    totalAmtController.text = cattleFeedPurchase.totalAmount.toString();
    dateController.text = cattleFeedPurchase.date.toString();


    editingIndex = index; // Set the index of the purchase being edited
  }
  InputDecoration customInputDecoration(String label, {Widget? suffixIcon}) {
    return InputDecoration(
      labelText: label,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8.0)),
      focusedBorder: OutlineInputBorder(
        borderSide: BorderSide(color: Colors.blue, width: 2),
      ),
      enabledBorder: OutlineInputBorder(
        borderSide: BorderSide(color: Colors.grey, width: 1),
      ),
      suffixIcon: suffixIcon,
    );
  }

  @override
  Widget build(BuildContext context) {
    // Initial cattle feed list
    return Scaffold(
      backgroundColor:Colors.blue[50],
      appBar: CustomWidgets.buildAppBar('Cattle Feed Purchase'),
      body:_isLoading? Center(child: CircularProgressIndicator()): SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: dateController,
                    decoration: InputDecoration(
                      labelText: "Date",
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(vertical: 2, horizontal: 10),
                      filled: true,
                      fillColor: Colors.white,
                      suffixIcon: IconButton(
                        icon: Icon(Icons.calendar_month),
                        onPressed: () => _selectDate(context),
                      ),
                    ),
                    readOnly: true,
                  ),
                ),
              ],
            ),
            SizedBox(height: 10),
            Row(
              children: [
                SizedBox(
                  width: 112,
                  child: Autocomplete<CattleFeedSupplier>(
                    optionsBuilder: (TextEditingValue textEditingValue) {
                      return cattleFeedSupplierList
                          .where((supplier) => supplier.code!.contains(textEditingValue.text))
                          .toList();
                    },
                    displayStringForOption: (CattleFeedSupplier option) => "${option.code!} - ${option.name!}",
                    onSelected: (CattleFeedSupplier selection) {
                      FocusScope.of(context).unfocus();
                      codeController.text = selection.code!;
                      supplierController.text = selection.name!;
                    },
                    fieldViewBuilder: (context, controller, focusNode, onEditingComplete) {
                      codeController = controller;
                      return TextField(
                        controller: controller,
                        focusNode: focusNode,
                        decoration: InputDecoration(
                          contentPadding: EdgeInsets.symmetric(vertical: 2, horizontal: 10),
                          filled: true,
                          fillColor: Colors.white,
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
                  child: Autocomplete<CattleFeedSupplier>(
                    optionsBuilder: (TextEditingValue textEditingValue) {
                      return cattleFeedSupplierList
                          .where((supplier) => supplier.name!.toLowerCase().contains(textEditingValue.text.toLowerCase()))
                          .toList();
                    },
                    displayStringForOption: (CattleFeedSupplier option) => "${option.code!} - ${option.name!}",
                    onSelected: (CattleFeedSupplier selection) {
                      FocusScope.of(context).unfocus();

                      codeController.text = selection.code!;
                      supplierController.text = selection.name!;
                    },
                    fieldViewBuilder: (context, controller, focusNode, onEditingComplete) {
                      supplierController = controller;
                      return TextField(
                        controller: controller,
                        focusNode: focusNode,
                        decoration: InputDecoration(
                          contentPadding: EdgeInsets.symmetric(vertical: 2, horizontal: 10),
                          filled: true,
                          fillColor: Colors.white,
                          labelText: "Supplier Name",
                          border: OutlineInputBorder(),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
            SizedBox(height: 10),

            /// **Third Row: Qty, Rate, Amount**
            Row(
              children: [
              Expanded(child: TextField(
                controller: cattleFeedNameController,
                decoration: InputDecoration(
                  labelText: "Feed Name",
                  border: OutlineInputBorder(),
                  contentPadding: EdgeInsets.symmetric(vertical: 2, horizontal: 10),
                  filled: true,
                  fillColor: Colors.white,
                ),
                // onChanged: (val) => calculateAmount(),
              ),),

                SizedBox(width: 10),
                Expanded(
                  child: TextField(
                    controller: qtyController,
                    decoration: InputDecoration(
                      labelText: "Quantity",
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(vertical: 2, horizontal: 10),
                      filled: true,
                      fillColor: Colors.white,
                    ),
                    keyboardType: TextInputType.number,
                    onChanged: (val) => calculateAmount(),
                  ),
                ),
              ],
            ),
            SizedBox(height: 10,),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: rateController,
                    decoration: InputDecoration(
                      labelText: "Rate",
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(vertical: 2, horizontal: 10),
                      filled: true,
                      fillColor: Colors.white,
                    ),
                    keyboardType: TextInputType.number,
                    onChanged: (val) => calculateAmount(),
                  ),
                ),
                SizedBox(width: 10),
                Expanded(
                  child: TextField(
                    controller: amtController,
                    decoration: InputDecoration(
                      labelText: "Amount",
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(vertical: 2, horizontal: 10),
                      filled: true,
                      fillColor: Colors.white,
                    ),
                    readOnly: true,
                  ),
                ),
              ],
            ),
            SizedBox(height: 10),

            /// **Fourth Row: GST (%) & GST Amount**
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: gstController,
                    decoration: InputDecoration(
                      labelText: "GST (%)",
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(vertical: 2, horizontal: 10),
                      filled: true,
                      fillColor: Colors.white,
                    ),
                    keyboardType: TextInputType.number,
                    onChanged: (val) => calculateGST(),
                  ),
                ),
                SizedBox(width: 10),
                Expanded(
                  child: TextField(
                    controller: gstAmtController,
                    decoration: InputDecoration(
                      labelText: "GST Amount",
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(vertical: 2, horizontal: 10),
                      filled: true,
                      fillColor: Colors.white,
                    ),
                    readOnly: true,
                  ),
                ),
              ],
            ),
            SizedBox(height: 10),
            TextField(
              controller: totalAmtController,
              decoration: InputDecoration(
                labelText:"Part",
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.symmetric(vertical: 2, horizontal: 10),
                filled: true,
                fillColor: Colors.white,
              ),
              readOnly: true,
            ),
            SizedBox(height: 10),

            /// **Fifth Row: Commission & Wages**
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: commController,
                    decoration: InputDecoration(
                      labelText: "Commission",
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(vertical: 2, horizontal: 10),
                      filled: true,
                      fillColor: Colors.white,
                    ),
                    keyboardType: TextInputType.number,
                    onChanged: (val) => calculateBillAmount(),
                  ),
                ),
                SizedBox(width: 10),
                Expanded(
                  child: TextField(
                    controller: wagesController,
                    decoration: InputDecoration(
                      labelText: "Wages",
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(vertical: 2, horizontal: 10),
                      filled: true,
                      fillColor: Colors.white,
                    ),
                    keyboardType: TextInputType.number,
                    onChanged: (val) => calculateBillAmount(),
                  ),
                ),
              ],
            ),
            SizedBox(height: 10),

            /// **Sixth Row: Bill Amount & Payment Method**
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: billAmtController,
                    decoration: InputDecoration(
                      labelText: "Bill Amount",
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(vertical: 2, horizontal: 10),
                      filled: true,
                      fillColor: Colors.white,
                    ),
                    readOnly: true,
                  ),
                ),
                SizedBox(width: 10),
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: paymentMethods.contains(paymentMethod) ? paymentMethod : null,
                    decoration: InputDecoration(
                      labelText: "Payment Method",
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(vertical: 2, horizontal: 10),
                      filled: true,
                      fillColor: Colors.white,
                    ),
                    items: paymentMethods
                        .map((method) => DropdownMenuItem(
                      value: method,
                      child: Text(method),
                    ))
                        .toList(),
                    onChanged: (value) {
                      setState(() {
                        paymentMethod = value!;
                      });
                    },
                  ),
                ),
              ],
            ),
            SizedBox(height: 10),

            /// **Seventh Row: Total Amount**
            TextField(
              controller: totalAmtController,
              decoration: InputDecoration(
                labelText: "Total Amount",
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.symmetric(vertical: 2, horizontal: 10),
                filled: true,
                fillColor: Colors.white,
              ),
              readOnly: true,
            ),
            SizedBox(height: 20),

             CustomWidgets.customButton(text: 'save',onPressed: savePurchase),
            // SizedBox(height: 20),
            // /// **Table for Saved Purchases**
            // Table(
            //   border: TableBorder.all(),
            //   columnWidths: const {
            //     0: FlexColumnWidth(50),
            //     1: FlexColumnWidth(50),
            //     2: FlexColumnWidth(50),
            //     3: FlexColumnWidth(50),
            //     4: FlexColumnWidth(50),
            //     5: FlexColumnWidth(50),
            //     6: FlexColumnWidth(50),
            //     7: FlexColumnWidth(50),
            //     8: FlexColumnWidth(50),
            //     9: FlexColumnWidth(50),
            //     10: FlexColumnWidth(50),
            //     // 11: FlexColumnWidth(50),
            //     // 12: FlexColumnWidth(50),
            //     // 13: FlexColumnWidth(50),
            //     // 14: FlexColumnWidth(50),
            //     // 15: FlexColumnWidth(50),
            //     // 16:FlexColumnWidth(50),
            //   },
            //     // Table Header
            //     children :[
            //     const TableRow(
            //       decoration: BoxDecoration(color: Color(0xFF24A1DE)),
            //       children: [
            //         // Padding(
            //         //   padding: EdgeInsets.all(8.0),
            //         //   child: Text("Voichar", style: TextStyle(color: Colors.white)),
            //         // ),
            //         // Padding(
            //         //   padding: EdgeInsets.all(8.0),
            //         //   child: Text("Date", style: TextStyle(color: Colors.white)),
            //         // ),
            //         Padding(
            //           padding: EdgeInsets.all(8.0),
            //           child: Text("Code", style: TextStyle(color: Colors.white)),
            //         ),
            //         // Padding(
            //         //   padding: EdgeInsets.all(8.0),
            //         //   child: Text("Supplier Name", style: TextStyle(color: Colors.white)),
            //         // ),
            //         Padding(
            //           padding: EdgeInsets.all(8.0),
            //           child: Text("Qty", style: TextStyle(color: Colors.white)),
            //          ),
            //         // // Padding(
            //         // //   padding: EdgeInsets.all(8.0),
            //         // //   child: Text("Rate", style: TextStyle(color: Colors.white)),
            //         // // ),
            //         // Padding(
            //         //   padding: EdgeInsets.all(8.0),
            //         //   child: Text("Amount", style: TextStyle(color: Colors.white)),
            //         // // ),
            //         // Padding(
            //         //   padding: EdgeInsets.all(8.0),
            //         //   child: Text("GST", style: TextStyle(color: Colors.white)),
            //         // ),
            //         // Padding(
            //         //   padding: EdgeInsets.all(8.0),
            //         //   child: Text("GST Amount", style: TextStyle(color: Colors.white)),
            //         // ),
            //         // Padding(
            //         //   padding: EdgeInsets.all(8.0),
            //         //   child: Text("Commission", style: TextStyle(color: Colors.white)),
            //         // ),
            //         // Padding(
            //         //   padding: EdgeInsets.all(8.0),
            //         //   child: Text("Wages", style: TextStyle(color: Colors.white)),
            //         // ),
            //         // Padding(
            //         //   padding: EdgeInsets.all(8.0),
            //         //   child: Text("Bill Amount", style: TextStyle(color: Colors.white)),
            //         // ),
            //         Padding(
            //           padding: EdgeInsets.all(8.0),
            //           child: Text("Pay Meth", style: TextStyle(color: Colors.white)),
            //         ),
            //         Padding(
            //           padding: EdgeInsets.all(8.0),
            //           child: Text("Total Amt", style: TextStyle(color: Colors.white)),
            //         ),
            //         Padding(
            //           padding: EdgeInsets.all(8.0),
            //           child: Text("Edit", style: TextStyle(color: Colors.white)),
            //         ),
            //         Padding(
            //           padding: EdgeInsets.all(8.0),
            //           child: Text("Delete", style: TextStyle(color: Colors.white)),
            //         ),
            //
            //       ],
            //     ),
            //     // Data Rows
            //     ...savedPurchases.asMap().entries.map((entry) {
            //       int index = entry.key;
            //       CattleFeedPurchase purchase = entry.value;
            //       return TableRow(
            //         children: [
            //           Padding(
            //             padding: const EdgeInsets.all(8.0),
            //             child: Text(purchase.voucher.toString()),
            //           ),
            //           // Padding(
            //           //   padding: const EdgeInsets.all(8.0),
            //           //   child: Text(purchase.date!),
            //           // ),
            //           Padding(
            //             padding: const EdgeInsets.all(8.0),
            //             child: Text('${purchase.code}'),
            //           ),
            //           // Padding(
            //           //   padding: const EdgeInsets.all(8.0),
            //           //   child: Text(purchase.supplier!),
            //           // ),
            //           Padding(
            //             padding: const EdgeInsets.all(8.0),
            //             child: Text(purchase.quantity.toString()),
            //           ),
            //           // Padding(
            //           //   padding: const EdgeInsets.all(8.0),
            //           //   child: Text(purchase.rate.toString()),
            //           // ),
            //           // Padding(
            //           //   padding: const EdgeInsets.all(8.0),
            //           //   child: Text(purchase.amount.toString()),
            //           // ),
            //           // Padding(
            //           //   padding: const EdgeInsets.all(8.0),
            //           //   child: Text(purchase.gst.toString()),
            //           // ),
            //           // Padding(
            //           //   padding: const EdgeInsets.all(8.0),
            //           //   child: Text(purchase.gstAmount.toString()),
            //           // ),
            //           // Padding(
            //           //   padding: const EdgeInsets.all(8.0),
            //           // child: Text(purchase.commission.toString()),
            //           // ),
            //           // Padding(
            //           //   padding: const EdgeInsets.all(8.0),
            //           //   child: Text(purchase.wages.toString()),
            //           // ),
            //           Padding(
            //             padding: const EdgeInsets.all(8.0),
            //             child: Text(purchase.billAmount.toString()),
            //           ),
            //           Padding(
            //             padding: const EdgeInsets.all(8.0),
            //             child: Text(purchase.paymentMethod.toString()),
            //           ),
            //           Padding(
            //             padding: const EdgeInsets.all(8.0),
            //             child: Text(purchase.totalAmount.toString()),
            //           ),
            //
            //           // Edit Button
            //           IconButton(
            //             icon: Icon(Icons.edit, color: Colors.blue),
            //             onPressed: () {
            //               editPurchase(index);
            //             },
            //           ),
            //           IconButton(
            //             icon: Icon(Icons.delete, color: Colors.blue),
            //             onPressed: () {
            //               deletePurchase(index);
            //             },
            //           ),
            //         ],
            //       );
            //
            //     }).toList(),
            //   ],
            //
            // )

          ],
        ),
      ),
    );
  }
}