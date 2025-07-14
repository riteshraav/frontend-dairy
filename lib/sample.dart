import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
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
  String selectedCowBuff = 'Cow';
  double totalValue = 0;
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
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    customerList = CustomWidgets.allCustomers();
    dateController.text = CustomWidgets.extractDate(DateTime.now());
    litersController.addListener(calculateAmount);
    buffaloRateController.addListener((){
      calculateAmount();
      updateLocalMilkRate();
    });
    cowRateController.addListener(
            (){
          calculateAmount();
          updateLocalMilkRate();
        }
    );
    localMilkSaleRateBuffalo = Provider.of<BuffaloRatechartProvider>(context, listen: false).localMilkSaleBuffalo;
    localMilkSaleRateCow = Provider.of<CowRateChartProvider>(context, listen: false).localMilkSaleCow;
    buffaloRateController.text =localMilkSaleRateBuffalo.toStringAsFixed(2);
    cowRateController.text = localMilkSaleRateCow.toStringAsFixed(2);
  }

  void updateLocalMilkRate(){
    if(selectedCowBuff == "Buffalo")
    {
      BuffaloRatechartProvider buffaloRatechartProvider = BuffaloRatechartProvider();
      buffaloRatechartProvider.localMilkSaleBuffalo = double.parse(buffaloRateController.text);

    }
    else{
      CowRateChartProvider cowRateChartProvider = CowRateChartProvider();
      cowRateChartProvider.localMilkSaleCow = double.parse(cowRateController.text);
    }
  }
  void saveInfo() async {
    print('in save info of local milk sale');
    print('selected type is $selectedType');
    if(litersController.text.trim() == "" || amountController.text.trim().isEmpty)
    {
      Fluttertoast.showToast(msg: "add all required fields");
      return;
    }
    LocalMilkSale localMilkSale = LocalMilkSale(
        customerId: codeController.text,
        adminId: admin.id!,
        date: DateTime.now().toIso8601String(),
        paymentType: selectedType,
        milkType: selectedCowBuff,
        quantity: double.parse(litersController.text),
        rate: double.parse((selectedCowBuff =="Buffalo")?buffaloRateController.text:cowRateController.text),
        totalValue: double.parse(amountController.text));


    bool isSaved= false;//await LocalMilkSaleService.addLocalMilkSale(localMilkSale);
    if(isSaved)
    {
      localeSaleList.add(localMilkSale);
      print(localeSaleList);
      Fluttertoast.showToast(msg: "Milk Sale Saved");
      clearAll();
    }
    else{
      Fluttertoast.showToast(msg: "Error");
    }

  }
  void calculateAmount(){
    setState(() {
      totalValue = double.parse((selectedCowBuff =="Buffalo")?buffaloRateController.text:cowRateController.text) * double.parse(litersController.text);
      amountController.text = totalValue.toStringAsFixed(2);
    });
    print(totalValue);
  }
  void clearAll(){
    codeController.clear();
    customerController.clear();
    litersController.clear();
    amountController.clear();
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
              // Date and Type Section
              Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children:[
                    Expanded(
                      child: TextField(controller: dateController, readOnly: true, decoration: InputDecoration(labelText: "Date",
                          fillColor: Colors.white,
                          filled: true,
                          border: OutlineInputBorder())),
                    ),
                    SizedBox(width: 10,),
                    Container(
                      decoration: BoxDecoration(

                          color: Colors.white,
                          borderRadius: BorderRadius.all(Radius.circular(8))
                      ),
                      child: ToggleButtons(

                        onPressed: (int index) {
                          setState(() {
                            // The button that is tapped is set to true, and the others to false.
                            for (int i = 0; i < _paymentMethod.length; i++) {
                              _paymentMethod[i] = i == index;

                            }
                            selectedType = (index == 0)?"Credit":"Cash";
                            print('selected type is $selectedType');
                          });
                        },
                        borderRadius: const BorderRadius.all(Radius.circular(8)),
                        selectedBorderColor: Colors.blue[100],
                        selectedColor: Colors.black,
                        fillColor: Colors.blue[100],
                        color: Colors.black,
                        isSelected: _paymentMethod,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(left:22.0,right: 22.0),
                            child: Text("Credit"),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(left:22.0,right: 22.0),
                            child: Text("Cash"),
                          )
                        ],
                      ),
                    ),
                  ]

              ),
              SizedBox(height: 16),
              (_paymentMethod[0])?
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
                        customerController.text = selection.name!;
                        FocusScope.of(context).unfocus(); // Hide suggestions
                      },
                      fieldViewBuilder: (context, controller, focusNode, onEditingComplete) {
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
                            suffixIcon: (codeController.text !="")?IconButton(icon:Icon(Icons.clear), onPressed: () { codeController.clear(); },):null,
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
                        customerController.text = selection.name!;
                        FocusScope.of(context).unfocus(); // Hide suggestions
                      },
                      fieldViewBuilder: (context, controller, focusNode, onEditingComplete) {
                        customerController = controller;
                        return TextField(
                          controller: controller,
                          focusNode: focusNode,
                          decoration: InputDecoration(
                            suffixIcon: (customerController.text !="")?IconButton(icon:Icon(Icons.clear), onPressed: () { customerController.clear(); },):null,
                            filled: true,
                            fillColor: Colors.white,
                            labelText: "Customer  Name",
                            border: OutlineInputBorder(),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ) :SizedBox() ,
              SizedBox(height: 16,),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    decoration: BoxDecoration(

                        color: Colors.white,
                        borderRadius: BorderRadius.all(Radius.circular(8))
                    ),
                    child: ToggleButtons(
                      onPressed: (int index) {
                        setState(() {
                          // The button that is tapped is set to true, and the others to false.
                          for (int i = 0; i < _selectedMilkType.length; i++) {
                            _selectedMilkType[i] = i == index;
                          }
                          selectedCowBuff = (index == 0)?"Buffalo":"Cow";
                        });
                      },
                      borderRadius: const BorderRadius.all(Radius.circular(8)),
                      selectedBorderColor: Colors.blue[100],
                      selectedColor: Colors.black,

                      fillColor: Colors.blue[100],
                      color: Colors.black,
                      isSelected: _selectedMilkType,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(left: 20,right: 20,),
                          child: Text("Buffalo"),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(left: 25,right: 25,),
                          child: Text("Cow"),
                        )
                      ],
                    ),
                  ),
                  SizedBox(width: 16,),
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

              SizedBox(height: 16,),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: (selectedCowBuff =="Buffalo")?buffaloRateController:cowRateController,
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

              // Action Buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  CustomWidgets.customButton(text:"Save",onPressed:  saveInfo),
                  CustomWidgets.customButton(text:"Clear",onPressed:  clearAll)
                ],
              ),
              SizedBox(height: 16),
              SizedBox(
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: DataTable(
                    columnSpacing: 10,
                    border: TableBorder.all(),
                    //decoration: BoxDecoration(color: Color(0xFF24A1DE)),
                    headingRowColor: MaterialStateProperty.all(Color(0xFF24A1DE)),
                    columns: [
                      DataColumn(label: Text("Code",style: TextStyle(color: Colors.white),)),
                      DataColumn(label: Text("M Type",style: TextStyle(color: Colors.white))),
                      DataColumn(label: Text("Pay Type",style: TextStyle(color: Colors.white),)),
                      DataColumn(label: Text("Qty",style: TextStyle(color:Colors.white),)),
                      DataColumn(label: Text("Amt",style: TextStyle(color: Colors.white),)),
                      DataColumn(label: Text("Edit",style: TextStyle(color: Colors.white),)),
                      DataColumn(label: Text("Delete",style: TextStyle(color: Colors.white),))

                    ],
                    rows: List.generate(
                      localeSaleList.length,
                          (index) {
                        final entry =localeSaleList[index];
                        return DataRow(cells: [
                          DataCell(Text(entry.customerId??"")),
                          DataCell(Text(entry.milkType??"")),
                          DataCell(Text(entry.paymentType)),
                          DataCell(Text(entry.quantity.toStringAsFixed(2))),
                          DataCell(Text(entry.totalValue.toStringAsFixed(2))),
                          DataCell(IconButton(icon:Icon(Icons.edit),onPressed:()=>{})),
                          DataCell(IconButton(icon:Icon(Icons.delete),onPressed:()=>{})),

                        ]);
                      },
                    ),
                  ),
                ),
              ),

            ],
          ),
        ),
      ),
    );
  }
}