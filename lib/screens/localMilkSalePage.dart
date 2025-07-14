import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';

import '../model/Customer.dart';
import '../providers/cow_ratechart_provider.dart';
import '../providers/buffalo_ratechart_provider.dart';
import '../model/admin.dart';
import '../model/localsale.dart';
import '../widgets/appbar.dart';

class LocalMilkSalePage extends StatefulWidget {
  @override
  _LocalMilkSalePageState createState() => _LocalMilkSalePageState();
}

class _LocalMilkSalePageState extends State<LocalMilkSalePage> {
  String selectedType = 'Credit';
  String selectedCowBuff = 'Buffalo';
  int? editingIndex;

  final litersController = TextEditingController();
  final amountController = TextEditingController();
  final buffaloRateController = TextEditingController();
  final cowRateController = TextEditingController();
  final codeController = TextEditingController();
  final customerController = TextEditingController();
  final dateController = TextEditingController();

  final _paymentMethod = <bool>[true, false];
  final _milkTypeToggle = <bool>[true, false];

  List<Customer> customerList = [];
  List<LocalMilkSale> localeSaleList = [];
  late Admin admin;

  final FocusNode quantityFocusNode = FocusNode();
  @override
  void initState() {
    super.initState();
    Hive.initFlutter();
    admin = CustomWidgets.currentAdmin();
    dateController.text = CustomWidgets.extractDate(DateTime.now());
    customerList = CustomWidgets.allCustomers();
    _loadRates();
    _loadSavedEntries();

    litersController.addListener(_calculateAmount);
    buffaloRateController.addListener(() {
      _calculateAmount();
      _updateRateProvider();
    });
    cowRateController.addListener(() {
      _calculateAmount();
      _updateRateProvider();
    });
  }

  void _loadRates() {
    buffaloRateController.text = Provider.of<BuffaloRatechartProvider>(context, listen: false)
        .localMilkSaleBuffalo
        .toStringAsFixed(2);
    cowRateController.text = Provider.of<CowRateChartProvider>(context, listen: false)
        .localMilkSaleCow
        .toStringAsFixed(2);
  }

  Future<void> _loadSavedEntries() async {
    final box = await Hive.openBox('localMilkSaleBox');
    final list = box.values.cast<Map>().toList();
    setState(() {
      localeSaleList = list
          .map((e) => LocalMilkSale.fromJson(Map<String, dynamic>.from(e)))
          .toList();
    });
  }

  Future<void> _saveAllToHive() async {
    final box = await Hive.openBox('localMilkSaleBox');
    await box.clear();
    for (var entry in localeSaleList) {
      await box.add(entry.toJson());
    }
  }

  void _addOrUpdateSale() async {
    if (litersController.text.isEmpty || amountController.text.isEmpty) {
      Fluttertoast.showToast(msg: "Add all required fields");
      return;
    }
    final entry = LocalMilkSale(
      customerId: codeController.text,
      adminId: admin.id!,
      date: DateTime.now().toIso8601String(),
      paymentType: selectedType,
      milkType: selectedCowBuff,
      quantity: double.parse(litersController.text),
      rate: double.parse((selectedCowBuff == "Buffalo")
          ? buffaloRateController.text
          : cowRateController.text),
      totalValue: double.parse(amountController.text),
    );
    setState(() {
      if (editingIndex != null) {
        localeSaleList[editingIndex!] = entry;
        editingIndex = null;
        Fluttertoast.showToast(msg: "Updated");
      } else {
        localeSaleList.add(entry);
        Fluttertoast.showToast(msg: "Saved");
      }
    });
    await _saveAllToHive();
    _clearForm();
  }

  void _deleteEntry(int idx) async {
    final box = await Hive.openBox('localMilkSaleBox');
    await box.deleteAt(idx);
    setState(() {
      localeSaleList.removeAt(idx);
    });
    Fluttertoast.showToast(msg: "Deleted");
  }

  void _calculateAmount() {
    final liters = double.tryParse(litersController.text) ?? 0;
    final rate = double.tryParse((selectedCowBuff == "Buffalo")
        ? buffaloRateController.text
        : cowRateController.text) ??
        0;
    final amt = liters * rate;
    setState(() {
      amountController.text = amt.toStringAsFixed(2);
    });
  }

  void _updateRateProvider() {
    if (selectedCowBuff == "Buffalo") {
      Provider.of<BuffaloRatechartProvider>(context, listen: false)
          .localMilkSaleBuffalo = double.tryParse(buffaloRateController.text) ?? 0;
    } else {
      Provider.of<CowRateChartProvider>(context, listen: false)
          .localMilkSaleCow = double.tryParse(cowRateController.text) ?? 0;
    }
  }

  void _clearForm() {
    codeController.clear();
    customerController.clear();
    litersController.clear();
    amountController.clear();
    editingIndex = null;
    setState(() {
      selectedType = 'Credit';
      selectedCowBuff = 'Buffalo';
      _paymentMethod.setAll(0, [true, false]);
      _milkTypeToggle.setAll(0, [true, false]);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue[50],
      appBar: CustomWidgets.buildAppBar("Local Milk Sale"),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              // Date + Payment
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: TextField(
                      controller: dateController,
                      readOnly: true,
                      decoration: InputDecoration(
                        labelText: "Date",
                        fillColor: Colors.white,
                        filled: true,
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                  SizedBox(width: 10),
                  Container(
                    decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8)),
                    child: ToggleButtons(
                      onPressed: (idx) {
                        setState(() {
                          for (var i = 0; i < _paymentMethod.length; i++) {
                            _paymentMethod[i] = i == idx;
                          }
                          selectedType = idx == 0 ? 'Credit' : 'Cash';
                        });
                      },
                      borderRadius: BorderRadius.circular(8),
                      selectedBorderColor: Colors.blue[100],
                      selectedColor: Colors.black,
                      fillColor: Colors.blue[100],
                      color: Colors.black,
                      isSelected: _paymentMethod,
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 22),
                          child: Text("Credit"),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 22),
                          child: Text("Cash"),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(height: 16),

              if (selectedType == 'Credit')
                Row(
                  children: [
                    // Code field with Autocomplete (shows "1 - Ramesh" but saves "1")
                    Expanded(
                      flex: 1,
                      child: Autocomplete<Customer>(
                        optionsBuilder: (TextEditingValue textEditingValue) {
                          return customerList.where((Customer c) {
                            final query = textEditingValue.text.toLowerCase();
                            return ('${c.code} - ${c.name}').toLowerCase().contains(query);
                          }).toList();
                        },
                        displayStringForOption: (Customer c) => '${c.code} - ${c.name}',
                        onSelected: (Customer c) {
                          setState(() {
                            codeController.text = c.code!;
                            customerController.text = c.name!;
                          });
                          FocusScope.of(context).requestFocus(quantityFocusNode); // ⬅ move to quantity field
                        },

                        fieldViewBuilder:
                            (context, textEditingController, focusNode, onFieldSubmitted) {
                          textEditingController.text = codeController.text;
                          return TextField(
                            controller: textEditingController,
                            focusNode: focusNode,
                            decoration: InputDecoration(
                              labelText: 'Code',
                              fillColor: Colors.white,
                              filled: true,
                              border: OutlineInputBorder(),
                            ),
                            onChanged: (value) {},
                          );
                        },
                      ),
                    ),
                    SizedBox(width: 10),

                    // Name field with Autocomplete (shows "1 - Ramesh" but saves "Ramesh")
                    Expanded(
                      flex: 3,
                      child: Autocomplete<Customer>(
                        optionsBuilder: (TextEditingValue textEditingValue) {
                          return customerList.where((Customer c) {
                            final query = textEditingValue.text.toLowerCase();
                            return ('${c.code} - ${c.name}').toLowerCase().contains(query);
                          }).toList();
                        },
                        displayStringForOption: (Customer c) => '${c.code} - ${c.name}',
                        onSelected: (Customer c) {
                          setState(() {
                            codeController.text = c.code!;
                            customerController.text = c.name!;
                          });
                        },
                        fieldViewBuilder:
                            (context, textEditingController, focusNode, onFieldSubmitted) {
                          textEditingController.text = customerController.text;
                          return TextField(
                            controller: textEditingController,
                            focusNode: focusNode,
                            decoration: InputDecoration(
                              labelText: 'Customer Name',
                              fillColor: Colors.white,
                              filled: true,
                              border: OutlineInputBorder(),
                            ),
                            onChanged: (value) {},
                          );
                        },
                      ),
                    ),
                  ],
                ),


              SizedBox(height: 16),

              // Milk Type + Liters
              Row(
                children: [
                  Container(
                    decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8)),
                    child: ToggleButtons(
                      onPressed: (idx) {
                        setState(() {
                          for (var i = 0; i < _milkTypeToggle.length; i++) {
                            _milkTypeToggle[i] = i == idx;
                          }
                          selectedCowBuff = idx == 0 ? 'Buffalo' : 'Cow';
                          _calculateAmount();
                        });
                      },
                      borderRadius: BorderRadius.circular(8),
                      selectedBorderColor: Colors.blue[100],
                      selectedColor: Colors.black,
                      fillColor: Colors.blue[100],
                      color: Colors.black,
                      isSelected: _milkTypeToggle,
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: Text("Buffalo"),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 25),
                          child: Text("Cow"),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    child: TextFormField(
                      controller: litersController,
                      decoration: InputDecoration(
                        labelText: 'Liters',
                        fillColor: Colors.white,
                        filled: true,
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                    ),
                  ),
                ],
              ),

              SizedBox(height: 16),

              // Rate + Amount
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: selectedCowBuff == 'Buffalo'
                          ? buffaloRateController
                          : cowRateController,
                      decoration: InputDecoration(
                        labelText: 'Rate',
                        fillColor: Colors.white,
                        filled: true,
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                    ),
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    child: TextFormField(
                      controller: amountController,
                      decoration: InputDecoration(
                        labelText: 'Amount',
                        fillColor: Colors.white,
                        filled: true,
                        border: OutlineInputBorder(),
                      ),
                      readOnly: true,
                    ),
                  ),
                ],
              ),

              SizedBox(height: 16),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  CustomWidgets.customButton(
                      text: editingIndex == null ? "Save" : "Update",
                      onPressed: _addOrUpdateSale),
                  CustomWidgets.customButton(
                      text: "Clear", onPressed: _clearForm),
                ],
              ),

              SizedBox(height: 16),

              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: DataTable(
                  columnSpacing: 10,
                  border: TableBorder.all(),
                  headingRowColor:
                  MaterialStateProperty.all(Color(0xFF24A1DE)),
                  columns: [
                    DataColumn(
                        label: Text("Code",
                            style: TextStyle(color: Colors.white))),
                    DataColumn(
                        label: Text("M Type",
                            style: TextStyle(color: Colors.white))),
                    DataColumn(
                        label: Text("Pay Type",
                            style: TextStyle(color: Colors.white))),
                    DataColumn(
                        label: Text("Qty",
                            style: TextStyle(color: Colors.white))),
                    DataColumn(
                        label: Text("Amt",
                            style: TextStyle(color: Colors.white))),
                    DataColumn(
                        label: Text("Edit",
                            style: TextStyle(color: Colors.white))),
                    DataColumn(
                        label: Text("Delete",
                            style: TextStyle(color: Colors.white))),
                  ],
                  rows: List.generate(localeSaleList.length, (i) {
                    final e = localeSaleList[i];
                    return DataRow(cells: [
                      DataCell(Text(e.customerId ?? "")),
                      DataCell(Text(e.milkType)),
                      DataCell(Text(e.paymentType)),
                      DataCell(Text(e.quantity.toStringAsFixed(2))),
                      DataCell(Text(e.totalValue.toStringAsFixed(2))),
                      DataCell(IconButton(
                        icon: Icon(Icons.edit),
                        onPressed: () {
                          setState(() {
                            editingIndex = i;
                            codeController.text = e.customerId ?? "";
                            final customer = customerList.firstWhere(
                                  (c) => c.code == e.customerId,
                              orElse: () => Customer(code: '', name: ''),
                            );
                            customerController.text = customer.name ?? '';

                            litersController.text =
                                e.quantity.toStringAsFixed(2);
                            amountController.text =
                                e.totalValue.toStringAsFixed(2);
                            selectedType = e.paymentType;
                            selectedCowBuff = e.milkType;
                            for (int k = 0; k < _paymentMethod.length; k++) {
                              _paymentMethod[k] = (k == (e.paymentType == 'Credit' ? 0 : 1));
                            }
                            for (int k = 0; k < _milkTypeToggle.length; k++) {
                              _milkTypeToggle[k] =
                              (k == (e.milkType == 'Buffalo' ? 0 : 1));
                            }
                          });
                        },
                      )),
                      DataCell(IconButton(
                          icon: Icon(Icons.delete),
                          onPressed: () => _deleteEntry(i))),
                    ]);
                  }),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}