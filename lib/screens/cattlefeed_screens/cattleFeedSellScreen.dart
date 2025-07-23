import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../model/cattleFeedSell.dart';
import '../../service/cattleFeedSellService.dart';
import '../../widgets/appbar.dart';
import '../../model/admin.dart';
import '../../model/cattleFeedPurchase.dart';
import '../../model/Customer.dart';
import 'cattleFeedPurchaseScreen.dart';

class CattleFeedSellScreen extends StatefulWidget {
  List<CattleFeedPurchase> cattleFeedPurchaseList = [];

  @override
  State<CattleFeedSellScreen> createState() =>
      _CattleFeedSellScreenState();
}

class _CattleFeedSellScreenState extends State<CattleFeedSellScreen> {
   TextEditingController codeController = TextEditingController();
   TextEditingController customerNameController = TextEditingController();
   TextEditingController feedNameController = TextEditingController();
   TextEditingController rateController = TextEditingController();
  final TextEditingController dateController = TextEditingController();
  List<Customer> customerList = CustomWidgets.allCustomers();
  Admin admin = CustomWidgets.currentAdmin();
  String paymentMethod = "Credit";
  int selectedQuantity = 1;
  double totalAmount = 0.0;
  bool isLoading = false;

  final List<int> quantityOptions = List.generate(50, (index) => index + 1);
  final List<String> amountOptions = ['Credit', 'Cash'];

  List< CattleFeedSell> savedCattleFeedSells = [];
  int? editingIndex;

  void calculateTotalAmount() {
    if (rateController.text.isEmpty  ) {
      Fluttertoast.showToast(msg: "add rate",backgroundColor: Colors.redAccent);
      return;
    }

      setState(() {
        totalAmount = selectedQuantity * double.parse(rateController.text.trim());
      });

  }
  void saveCattleFeedSell() async{
    if (codeController.text.isEmpty ||
        customerNameController.text.isEmpty ||
        feedNameController.text.isEmpty ) {
      Fluttertoast.showToast(msg: "add all fields",backgroundColor: Colors.redAccent);
      return;
    }
      CattleFeedSell? cattleFeedSell = CattleFeedSell(
        customerId: codeController.text,
        date : DateTime.now().toIso8601String(),
        feedName:feedNameController.text.trim(),
        quantity: selectedQuantity,
        rate: double.parse(rateController.text.trim()),
        modeOfPayback: paymentMethod,
        totalAmount: totalAmount,
        adminId: admin.id
      );
    setState(() {
      isLoading = true;
    });
      cattleFeedSell = await   CattleFeedSellService.addCattleFeedSell(cattleFeedSell);
    setState(() {
      isLoading = false;
    });
      if(cattleFeedSell == null) {
        Fluttertoast.showToast(msg: "Error",backgroundColor: Colors.redAccent);
        return;
      }
    // Clear input fields after saving
    codeController.clear();
    customerNameController.clear();
    dateController.clear();
    feedNameController.clear();
    rateController.clear();
    selectedQuantity = 1;
    paymentMethod = "Credit";
    totalAmount = 0.0; // Reset the total amount
    Fluttertoast.showToast(msg: "sell saved", backgroundColor: Colors.greenAccent);
  }

  // void editCattleFeedSell(int index) {
  //   CattleFeedSell cattleFeedSell = savedCattleFeedSells[index];
  //   codeController.text = cattleFeedSell.customerId!;
  //   customerNameController.text = CustomWidgets.searchCustomerName(cattleFeedSell.customerId!);
  //   dateController.text = cattleFeedSell.date!;
  //   selectedFeed = widget.cattleFeedPurchaseList.firstWhere((c)=>c.feedName == cattleFeedSell.feedName);
  //   selectedQuantity = cattleFeedSell.quantity!;
  //   paymentMethod = cattleFeedSell.modeOfPayback!;
  //   editingIndex = index; // Set the index of the cattleFeedSell being edited
  //   // Calculate total amount based on the selected values
  //   calculateTotalAmount();
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomWidgets.buildAppBar("Cattle Feed Sell", [
        IconButton(
          icon: const Icon(Icons.add),
          onPressed: () {
            Navigator.push(context, MaterialPageRoute(builder: (context)=>CattleFeedPurchaseScreen()));
          },
        ),
      ],),
      backgroundColor: Colors.blue[50],
      body:isLoading? Center(child: CircularProgressIndicator()): SingleChildScrollView(
        padding: EdgeInsets.all(10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Row for Date input field
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
                      codeController.text = selection.code!;
                      customerNameController.text = selection.name!;
                      FocusScope.of(context).unfocus(); // Hide suggestions
                    },
                    fieldViewBuilder: (context, controller, focusNode, onEditingComplete) {
                      codeController = controller;
                      return TextField(
                        controller: controller,
                        focusNode: focusNode,
                        decoration: InputDecoration(
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
                  child: Autocomplete<Customer>(
                    optionsBuilder: (TextEditingValue textEditingValue) {
                      return customerList
                          .where((supplier) => supplier.name!.toLowerCase().contains(textEditingValue.text.toLowerCase()))
                          .toList();
                    },
                    displayStringForOption: (Customer option) => "${option.code!} - ${option.name!}",
                    onSelected: (Customer selection) {
                      codeController.text = selection.code!;
                      customerNameController.text = selection.name!;
                      FocusScope.of(context).unfocus(); // Hide suggestions
                    },
                    fieldViewBuilder: (context, controller, focusNode, onEditingComplete) {
                      customerNameController = controller;
                      return TextField(
                        controller: controller,
                        focusNode: focusNode,
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: Colors.white,
                          labelText: "Customer Name",
                          border: OutlineInputBorder(),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20), // Add some spacing
        
            // Row for Feed and Weight Selection
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: feedNameController,
                    decoration: InputDecoration(
                      labelText: "Feed Name",
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(vertical: 2, horizontal: 10),
                      filled: true,
                      fillColor: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(width: 20),
               Expanded(
                 child: TextField(
                   onChanged: (value){
                     calculateTotalAmount();
                   },
                    controller: rateController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: "rate",

                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(vertical: 2, horizontal: 10),
                      filled: true,
                      fillColor: Colors.white,
                    ),
                  ),
               ),
              ],
            ),
            const SizedBox(height: 20),
        
            // Row for Quantity and Amount Type Selection
            Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<int>(
                    value: selectedQuantity,
                    decoration: InputDecoration(
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder()),
                    items: quantityOptions.map((int item) {
                      return DropdownMenuItem<int>(
                        value: item,
                        child: Text('$item'),
                      );
                    }).toList(),
                    onChanged: (int? newValue) {
                      setState(() {
                        selectedQuantity = newValue ?? 1;
                      });
                      calculateTotalAmount();
                    },
                  ),
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: paymentMethod,
                    decoration: InputDecoration(
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder()),
                    items: amountOptions.map((String item) {
                      return DropdownMenuItem<String>(
                        value: item,
                        child: Text(item),
                      );
                    }).toList(),
                    onChanged: (String? newValue) {
                      setState(() {
                        paymentMethod = newValue!;
                      });
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
        
            // Row with Save Button and Total Amount
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Total Amount: ₹${totalAmount.toStringAsFixed(2)}',
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                CustomWidgets.customButton(text:  "Save",onPressed:  saveCattleFeedSell)
              ],
            ),
            // const SizedBox(height: 20),
            //
            // // Display Saved cattleFeedSells
            // savedCattleFeedSells.isNotEmpty
            //     ? Column(
            //   crossAxisAlignment: CrossAxisAlignment.start,
            //   children: [
            //     const Text(
            //       "Customer Sell Details:",
            //       style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            //     ),
            //     const SizedBox(height: 10),
            //     Table(
            //       border: TableBorder.all(),
            //       columnWidths: const {
            //         0: FlexColumnWidth(2),
            //         1: FlexColumnWidth(1),
            //         2: FlexColumnWidth(2),
            //         3: FlexColumnWidth(2),
            //         4: FlexColumnWidth(1), // For Edit button
            //       },
            //       children: [
            //         // Table Header
            //         const TableRow(
            //           decoration: BoxDecoration(color: Color(0xFF24A1DE)),
            //           children: [
            //             Padding(
            //               padding: EdgeInsets.all(8.0),
            //               child: Text("Feed", style: TextStyle(color: Colors.white)),
            //             ),
            //
            //             Padding(
            //               padding: EdgeInsets.all(8.0),
            //               child: Text("Qty", style: TextStyle(color: Colors.white)),
            //             ),
            //             Padding(
            //               padding: EdgeInsets.all(8.0),
            //               child: Text("Amount Type", style: TextStyle(color: Colors.white)),
            //             ),
            //             Padding(
            //               padding: EdgeInsets.all(8.0),
            //               child: Text("Total Amount", style: TextStyle(color: Colors.white)),
            //             ),
            //             Padding(
            //               padding: EdgeInsets.all(8.0),
            //               child: Text("Edit", style: TextStyle(color: Colors.white)),
            //             ),
            //             Padding(padding: EdgeInsets.all(8.0),
            //             child: Text("Delete", style: TextStyle(color: Colors.white)),
            //             )
            //           ],
            //         ),
            //         // Data Rows
            //         ...savedCattleFeedSells.asMap().entries.map((entry) {
            //           int index = entry.key;
            //           var cattleFeedSell = entry.value;
            //           return TableRow(
            //             children: [
            //               Padding(
            //                 padding: const EdgeInsets.all(8.0),
            //                 child: Text(cattleFeedSell.feedName!),
            //               ),
            //
            //               Padding(
            //                 padding: const EdgeInsets.all(8.0),
            //                 child: Text('${cattleFeedSell.quantity!}'),
            //               ),
            //               Padding(
            //                 padding: const EdgeInsets.all(8.0),
            //                 child: Text(cattleFeedSell.modeOfPayback!),
            //               ),
            //               Padding(
            //                 padding: const EdgeInsets.all(8.0),
            //                 child: Text('\₹${cattleFeedSell.totalAmount}'),
            //               ),
            //               // Edit Button
            //               IconButton(
            //                 icon: const Icon(Icons.edit, color: Colors.blue),
            //                 onPressed: () {
            //                   editCattleFeedSell(index);
            //                 },
            //               ),
            //           IconButton(
            //           icon: Icon(Icons.delete, color: Colors.blue),
            //           onPressed: (){
            //           deleteCattleFeedSell(index);
            //           },
            //           )
            //             ],
            //           );
            //         }),
            //       ],
            //     ),
            //   ],
            // )
            //     : Container(),
          ],
        ),
      ),
    );
  }
}
