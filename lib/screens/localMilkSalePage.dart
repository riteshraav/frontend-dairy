import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:hive/hive.dart';
import 'package:provider/provider.dart';
import '../model/Customer.dart';
import '../providers/cow_ratechart_provider.dart';
import '../service/local_milk_sale_service.dart';
import '../widgets/appbar.dart';
import '../model/admin.dart';
import '../model/localsale.dart';
import '../providers/buffalo_ratechart_provider.dart';

class LocalMilkSalePage extends StatefulWidget {
  @override
  _LocalMilkSalePageState createState() => _LocalMilkSalePageState();
}

class _LocalMilkSalePageState extends State<LocalMilkSalePage> {
  final _formKey = GlobalKey<FormState>();
  String? selectedDivision = 'HeadOffice';
  String selectedType = 'Credit';
  String selectedCowBuff = 'Buffalo';
  double totalValue = 0;
  int? editingIndex;

  TextEditingController litersController = TextEditingController();
  TextEditingController fatController = TextEditingController();
  TextEditingController snfController = TextEditingController();
  TextEditingController amountController = TextEditingController();
  TextEditingController buffaloRateController = TextEditingController();
  TextEditingController cowRateController = TextEditingController();
  TextEditingController dateController = TextEditingController();
  TextEditingController customerController = TextEditingController();
  TextEditingController codeController = TextEditingController();

  List<Customer> customerList = [];
  final List<bool> _paymentMethod = <bool>[true, false];
  final List<bool> _selectedMilkType = <bool>[true, false];

  List<LocalMilkSale> localeSaleList = [];
  Admin admin = CustomWidgets.currentAdmin();
  double localMilkSaleRateBuffalo = 0;
  double localMilkSaleRateCow = 0;
  bool loading = false;
  @override
  void initState() {
    super.initState();
    selectedCowBuff = 'Buffalo';
    customerList = CustomWidgets.allCustomers();
    dateController.text = CustomWidgets.extractDate(DateTime.now());

    litersController.addListener(calculateAmount);
    buffaloRateController.addListener(() {
      calculateAmount();
      updateLocalMilkRate();
    });
    cowRateController.addListener(() {
      calculateAmount();
      updateLocalMilkRate();
    });

    localMilkSaleRateBuffalo =
        Provider.of<BuffaloRatechartProvider>(context, listen: false)
            .localMilkSaleBuffalo;
    localMilkSaleRateCow =
        Provider.of<CowRateChartProvider>(context, listen: false)
            .localMilkSaleCow;

    buffaloRateController.text = localMilkSaleRateBuffalo.toStringAsFixed(2);
    cowRateController.text = localMilkSaleRateCow.toStringAsFixed(2);

    loadSavedEntries();
  }

  void updateLocalMilkRate() {
    if (selectedCowBuff == "Buffalo") {
      Provider.of<BuffaloRatechartProvider>(context, listen: false)
          .localMilkSaleBuffalo =
          double.tryParse(buffaloRateController.text) ?? 0;
    } else {
      Provider.of<CowRateChartProvider>(context, listen: false)
          .localMilkSaleCow =
          double.tryParse(cowRateController.text) ?? 0;
    }
  }

  String get todayKey => "milkSale_${DateTime.now().toString().substring(0, 10)}";

  void loadSavedEntries() async {
    setState(() {
      loading = true;
    });
   List<LocalMilkSale>? list = await LocalMilkSaleService.getDateEntries(DateTime.now().toIso8601String(),admin.id!);
    if(list == null)
      {
        Fluttertoast.showToast(msg: "Something went wrong");
        return;
      }
    setState(() {
      localeSaleList = list;
      loading = false;
    });
  }

  void saveToHive() async {
    final box = await Hive.openBox('localMilkSaleBox');
    await box.put(todayKey, localeSaleList);
  }

  void saveInfo() async {
    if (litersController.text.trim().isEmpty ||
        amountController.text.trim().isEmpty) {
      Fluttertoast.showToast(msg: "Add all required fields");
      return;
    }

    final localMilkSale = LocalMilkSale(
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
    if(editingIndex != null)
      {
          localMilkSale.id = localeSaleList[editingIndex!].id;
      }
    String isSaved= await LocalMilkSaleService.addLocalMilkSale(localMilkSale);

   if(isSaved == 'Unsuccessful') {
     print('failed to save');
      Fluttertoast.showToast(msg: 'failed to save');
   }
   else{
     print('local milk sale id : ${localMilkSale.id}');
      setState(() {
         if (editingIndex != null) {
           localeSaleList[editingIndex!] = localMilkSale;
           editingIndex = null;
           Fluttertoast.showToast(msg: "Milk Sale Updated");
         } else {
           localMilkSale.id = isSaved;
           localeSaleList.add(localMilkSale);
           print('local milk sale id : ${localeSaleList.last.id}');
          Fluttertoast.showToast(msg: "Milk Sale Saved");
         }
       });
       saveToHive();
       clearAll();
     }
  }

  void deleteEntry(int index) async {
    bool isDeleted = await LocalMilkSaleService.deleteMilkSale(localeSaleList[index]);
    if(isDeleted)
      {
        setState(() {
          localeSaleList.removeAt(index);
        });
        Fluttertoast.showToast(msg: "Entry deleted");
      }
    else{
      Fluttertoast.showToast(msg: 'Error');
    }

  }

  void calculateAmount() {
    setState(() {
      double rate = double.tryParse(
          (selectedCowBuff == "Buffalo")
              ? buffaloRateController.text
              : cowRateController.text) ??
          0;
      double liters = double.tryParse(litersController.text) ?? 0;
      totalValue = rate * liters;
      amountController.text = totalValue.toStringAsFixed(2);
    });
  }

  void clearAll() {
    codeController.clear();
    customerController.clear();
    litersController.clear();
    amountController.clear();
    editingIndex = null;
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
                        borderRadius: BorderRadius.all(Radius.circular(8))),
                    child: ToggleButtons(
                      onPressed: (int index) {
                        setState(() {
                          for (int i = 0; i < _paymentMethod.length; i++) {
                            _paymentMethod[i] = i == index;
                          }
                          selectedType = (index == 0) ? "Credit" : "Cash";
                        });
                      },
                      borderRadius: BorderRadius.all(Radius.circular(8)),
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
              (_paymentMethod[0])
                  ? Row(
                children: [
                  SizedBox(
                    width: 112,
                    child: Autocomplete<Customer>(
                      optionsBuilder: (textEditingValue) {
                        return customerList
                            .where((c) => c.code!
                            .contains(textEditingValue.text))
                            .toList();
                      },
                      displayStringForOption: (c) =>
                      "${c.code!} - ${c.name!}",
                      onSelected: (Customer selection) {
                        codeController.text = selection.code!;
                        customerController.text = selection.name!;
                        FocusScope.of(context).unfocus();
                      },
                      fieldViewBuilder:
                          (context, controller, focusNode, _) {
                        codeController = controller;
                        return TextField(
                          controller: controller,
                          focusNode: focusNode,
                          keyboardType: TextInputType.phone,
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: Colors.white,
                            labelText: "Code",
                            border: OutlineInputBorder(),
                          ),
                        );
                      },
                    ),
                  ),
                  SizedBox(width: 10),
                  Expanded(
                    child: Autocomplete<Customer>(
                      optionsBuilder: (textEditingValue) {
                        return customerList
                            .where((c) => c.name!
                            .toLowerCase()
                            .contains(textEditingValue.text
                            .toLowerCase()))
                            .toList();
                      },
                      displayStringForOption: (c) =>
                      "${c.code!} - ${c.name!}",
                      onSelected: (Customer selection) {
                        codeController.text = selection.code!;
                        customerController.text = selection.name!;
                        FocusScope.of(context).unfocus();
                      },
                      fieldViewBuilder:
                          (context, controller, focusNode, _) {
                        customerController = controller;
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
              )
                  : SizedBox(),
              SizedBox(height: 16),
              Row(
                children: [
                  Container(
                    decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.all(Radius.circular(8))),
                    child: ToggleButtons(
                      onPressed: (int index) {
                        setState(() {
                          for (int i = 0; i < _selectedMilkType.length; i++) {
                            _selectedMilkType[i] = i == index;
                          }
                          selectedCowBuff = (index == 0) ? "Buffalo" : "Cow";
                        });
                      },
                      borderRadius: BorderRadius.all(Radius.circular(8)),
                      selectedBorderColor: Colors.blue[100],
                      selectedColor: Colors.black,
                      fillColor: Colors.blue[100],
                      color: Colors.black,
                      isSelected: _selectedMilkType,
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
                        filled: true,
                        fillColor: Colors.white,
                        labelText: 'Liters',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: (selectedCowBuff == "Buffalo")
                          ? buffaloRateController
                          : cowRateController,
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Colors.white,
                        labelText: 'Rate',
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
                        filled: true,
                        fillColor: Colors.white,
                        labelText: 'Amount',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                      readOnly: true,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  CustomWidgets.customButton(text: "Save", onPressed: saveInfo),
                  CustomWidgets.customButton(
                      text: "Clear", onPressed: clearAll),
                ],
              ),
              SizedBox(height: 16),
              loading?
                Column(
          children: [
            Text("local sale loading.."),
            SizedBox(height: 16,),
            CircularProgressIndicator()
        ],
      ):
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
                  rows: List.generate(localeSaleList.length, (index) {
                    final entry = localeSaleList[index];
                    return DataRow(cells: [
                      DataCell(Text(entry.customerId ?? "")),
                      DataCell(Text(entry.milkType ?? "")),
                      DataCell(Text(entry.paymentType)),
                      DataCell(Text(entry.quantity.toStringAsFixed(2))),
                      DataCell(Text(entry.totalValue.toStringAsFixed(2))),
                      DataCell(IconButton(
                        icon: Icon(Icons.edit),
                        onPressed: () {
                          setState(() {
                            editingIndex = index;
                            litersController.text =
                                entry.quantity.toStringAsFixed(2);
                            amountController.text =
                                entry.totalValue.toStringAsFixed(2);
                            selectedCowBuff = entry.milkType ?? "Buffalo";
                            selectedType = entry.paymentType;
                            codeController.text = entry.customerId ?? "";
                            customerController.text = CustomWidgets.searchCustomerById(entry.customerId!, "Code").first.name!;
                            _paymentMethod[0] = selectedType == "Credit";
                            _paymentMethod[1] = selectedType == "Cash";
                            _selectedMilkType[0] =
                                selectedCowBuff == "Buffalo";
                            _selectedMilkType[1] = selectedCowBuff == "Cow";
                          });
                        },
                      )),
                      DataCell(IconButton(
                        icon: Icon(Icons.delete),
                        onPressed: () {
                          deleteEntry(index);
                        },
                      )),
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