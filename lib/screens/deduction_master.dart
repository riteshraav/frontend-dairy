import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import '../model/CustomerBalance.dart';
import '../model/advancecustomerinfo.dart';
import '../model/deduction.dart';
import '../model/loancustomerinfo.dart';
import '../model/milk_collection.dart';
import '../service/CustomerBalanceService.dart';
import '../service/customerAdvanceService.dart';
import '../service/deduction_service.dart';
import '../service/loanentry_service.dart';
import '../service/mik_collection_service.dart';
import '../widgets/appbar.dart';
import '../model/admin.dart';
import '../model/Customer.dart';
import 'auth_screens/login_screen.dart';

class DeductionMasterScreen extends StatefulWidget {
  @override
  _DeductionMasterScreenState createState() => _DeductionMasterScreenState();
}

class _DeductionMasterScreenState extends State<DeductionMasterScreen> {
  List<Customer> customerList = CustomWidgets.allCustomers();

  TextEditingController milkTotalBillController = TextEditingController();
  TextEditingController totalBalController = TextEditingController();
  TextEditingController dedAmountController = TextEditingController();
  TextEditingController netPayController = TextEditingController();
  TextEditingController fromDateController = TextEditingController();
  TextEditingController toDateController = TextEditingController();
  TextEditingController memberCodeController = TextEditingController();
  TextEditingController nameController = TextEditingController();
  TextEditingController cattleFeedBalanceController = TextEditingController();
  TextEditingController advanceBalanceController = TextEditingController();
  TextEditingController creditMilkBalanceController = TextEditingController();
  TextEditingController loanBalanceController = TextEditingController();
  TextEditingController otherExpenseBalanceController = TextEditingController();
  TextEditingController doctorVisitFeesBalanceController = TextEditingController();
  TextEditingController expenseBalanceController = TextEditingController();
  TextEditingController cattleFeedDeductionController = TextEditingController();
  TextEditingController advanceDeductionController = TextEditingController();
  TextEditingController creditMilkDeductionController = TextEditingController();
  TextEditingController loanDeductionController = TextEditingController();
   LoanEntry? loanEntry ;
   double loanInterest = 0;
   bool isLoading = false;
   double advanceInterest = 0;
   AdvanceEntry? advanceEntry;
  TextEditingController otherExpenseDeductionController =
      TextEditingController();
  TextEditingController doctorVisitFeesDeductionController =
      TextEditingController();
  TextEditingController expenseDeductionController = TextEditingController();
  FocusNode saveFocusNode = FocusNode();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  late DateTime from;
  late DateTime to;
  double totalAmount = 0;
  double calculateInterestFor(double amount,double interestRate,String date){
    return (amount * interestRate * (DateTime.now().difference(DateTime.parse(date)).inDays)/365) * 0.01;
  }

  Customer selectedCustomer = Customer();
  Admin admin = CustomWidgets.currentAdmin();
  CustomerBalance? currentCustomerBalance =
      CustomerBalance(adminId: "dummy", customerId: "dummy");



  void _searchDeductionInfo() async {
    print("[SearchDeduction] Start");

    if (memberCodeController.text == "" ||
        fromDateController.text == "" ||
        toDateController.text == "") {
      Fluttertoast.showToast(msg: "Enter code and dates");
      print("[SearchDeduction] Validation failed: Missing code or dates");
      return;
    }

    print("[SearchDeduction] Inputs:");
    print("  Member Code: ${memberCodeController.text}");
    print("  From Date: ${fromDateController.text}");
    print("  To Date: ${toDateController.text}");

    setState(() {
      isLoading = true;
    });

    print("[SearchDeduction] Fetching milk collection list...");
    List<MilkCollection>? milkCollectionList = await MilkCollectionService()
        .getForCustomersWithSpecificationAuth([selectedCustomer.code!], from.toIso8601String(),to.toIso8601String(),admin.id!,true,true);

    if (milkCollectionList == null) {
      print("[SearchDeduction] Milk collection list is null - logging out.");
      CustomWidgets.logout(context);
      setState(() {
        isLoading = false;
      });
      return;
    }
    print("[SearchDeduction] Milk collection fetched: ${milkCollectionList.length} items");
    milkCollectionList.forEach((entry)=> print(entry.date));
    print("[SearchDeduction] Fetching customer balance...");
    currentCustomerBalance = await CustomerBalanceService()
        .getCustomerBalanceAuth(admin.id!, selectedCustomer.code!);

    if (currentCustomerBalance == null) {
      print("[SearchDeduction] Customer balance is null - logging out.");
      CustomWidgets.logout(context, "something went wrong");
      setState(() {
        isLoading = false;
      });
      return;
    }

    print("[SearchDeduction] Customer balance fetched successfully.");
    print("  Loan Balance: ${currentCustomerBalance!.balanceLoan}");
    print("  Advance Balance: ${currentCustomerBalance!.balanceAdvance}");
    print("  Credit Milk: ${currentCustomerBalance!.balanceCreditMilk}");

    if (currentCustomerBalance!.adminId == 'dummy') {
      Fluttertoast.showToast(msg: "something went wrong");
      print("[SearchDeduction] Dummy adminId detected");
    }

    if (currentCustomerBalance?.balanceLoan != 0) {
      print("[SearchDeduction] Fetching loan entry...");
      loanEntry = await LoanEntryService.getLoanEntryForCustomer(admin.id!, selectedCustomer.code!);

      if (loanEntry != null) {
        print("[SearchDeduction] Loan entry found");
        print("  Loan Amount: ${loanEntry!.loanAmount}");
        print("  Interest Rate: ${loanEntry!.interestRate}");
        print("  Date: ${loanEntry!.date}");

        loanInterest = calculateInterestFor(
          loanEntry!.loanAmount ?? 0.0,
          loanEntry!.interestRate ?? 0.0,
          loanEntry!.date,
        );

        loanInterest += loanEntry!.remainingInterest!;
        print("  Calculated Loan Interest: $loanInterest");
      } else {
        print("[SearchDeduction] No loan entry found");
      }
    }

    if (currentCustomerBalance?.balanceAdvance != 0) {
      print("[SearchDeduction] Fetching advance entry...");
      advanceEntry = await CustomerAdvanceService.getForCustomer(admin.id!, selectedCustomer.code!);

      if (advanceEntry != null) {
        print("[SearchDeduction] Advance entry found");
        print("  Advance Amount: ${advanceEntry!.advanceAmount}");
        print("  Interest Rate: ${advanceEntry!.interestRate}");
        print("  Last Deduction Date: ${advanceEntry!.recentDeduction}");

        advanceInterest = calculateInterestFor(
          advanceEntry!.advanceAmount,
          advanceEntry!.interestRate,
          advanceEntry!.recentDeduction,
        );
        advanceInterest += advanceEntry!.remainingInterest;
        print("  Calculated Advance Interest: $advanceInterest");
      } else {
        print("[SearchDeduction] No advance entry found");
      }
    }

    print("[SearchDeduction] Filtering milk collection list by date range...");
    List<MilkCollection> filteredList = milkCollectionList.where((milkCollection) {
      DateTime collectionDate = DateTime.parse(milkCollection.date!);
      return collectionDate.isAfter(from.subtract(Duration(days: 1))) &&
          collectionDate.isBefore(to.add(Duration(days: 1)));
    }).toList();

    print("[SearchDeduction] Filtered list size: ${filteredList.length}");

    totalAmount = 0;
    for (var milkCollection in filteredList) {
      totalAmount += milkCollection.totalValue!;
    }

    print("[SearchDeduction] Total Milk Bill Amount: $totalAmount");

    setState(() {
      isLoading = false;
      milkTotalBillController.text = totalAmount.toStringAsFixed(2);
      cattleFeedBalanceController.text =
          (currentCustomerBalance!.balanceCattleFeed ?? "").toString();
      advanceBalanceController.text =
      "${currentCustomerBalance!.balanceAdvance} + $advanceInterest";
      creditMilkBalanceController.text =
          currentCustomerBalance!.balanceCreditMilk.toString();
      loanBalanceController.text =
      "${currentCustomerBalance!.balanceLoan} + $loanInterest";
      otherExpenseBalanceController.text =
          currentCustomerBalance!.balanceOtherExpense.toString();
      doctorVisitFeesBalanceController.text =
          currentCustomerBalance!.balanceDoctorVisitingFees.toString();
      expenseBalanceController.text =
          currentCustomerBalance!.balanceExpense.toString();
      totalBalController.text = currentCustomerBalance!.totalBalance.toString();
    });

    print("[SearchDeduction] UI updated with final values");
    print('membrcontroller ${nameController.text}');
  }

  @override
  void initState() {
    super.initState();
    milkTotalBillController.addListener(updateNetPayment);

    cattleFeedDeductionController.addListener(updateTotalDeduction);
    advanceDeductionController.addListener(updateTotalDeduction);
    creditMilkDeductionController.addListener(updateTotalDeduction);
    loanDeductionController.addListener(updateTotalDeduction);
    otherExpenseDeductionController.addListener(updateTotalDeduction);
    doctorVisitFeesDeductionController.addListener(updateTotalDeduction);
    expenseDeductionController.addListener(updateTotalDeduction);
    dedAmountController.addListener(updateNetPayment);
  }

  Future<void> _selectDate(BuildContext context,
      TextEditingController controller, String dateType) async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() {

        (dateType == "from") ? from = picked : to = picked;
        controller.text = "${picked.day}/${picked.month}/${picked.year}";
      });
    }
  }

  void updateTotalBalance() {
    double cattleFeedBalance =
        double.tryParse(cattleFeedBalanceController.text) ?? 0;
    double advanceBalance = double.tryParse(advanceBalanceController.text) ?? 0;
    double creditMilkBalance =
        double.tryParse(creditMilkBalanceController.text) ?? 0;
    double loanBalance = double.tryParse(loanBalanceController.text) ?? 0;
    double otherExpenseBalance =
        double.tryParse(otherExpenseBalanceController.text) ?? 0;
    double expenseBalance = double.tryParse(expenseBalanceController.text) ?? 0;
    double doctorVisitingFeesBalance =
        double.tryParse(doctorVisitFeesBalanceController.text) ?? 0;
    double totalBal = doctorVisitingFeesBalance +
        cattleFeedBalance +
        advanceBalance +
        creditMilkBalance +
        loanBalance +
        otherExpenseBalance +
        expenseBalance;
    totalBalController.text = totalBal.toStringAsFixed(2);
  }

  void updateTotalDeduction() {
    double cattleFeedBalance =
        double.tryParse(cattleFeedDeductionController.text) ?? 0;
    double advanceDeduction =
        double.tryParse(advanceDeductionController.text) ?? 0;
    double creditMilkDeduction =
        double.tryParse(creditMilkDeductionController.text) ?? 0;
    double loanDeduction = double.tryParse(loanDeductionController.text) ?? 0;
    double otherExpenseDeduction =
        double.tryParse(otherExpenseDeductionController.text) ?? 0;
    double expenseDeduction =
        double.tryParse(expenseDeductionController.text) ?? 0;
    double doctorVisitingFeesDeduction =
        double.tryParse(doctorVisitFeesDeductionController.text) ?? 0;
    double dedAmount = doctorVisitingFeesDeduction +
        cattleFeedBalance +
        advanceDeduction +
        creditMilkDeduction +
        loanDeduction +
        otherExpenseDeduction +
        expenseDeduction;
    dedAmountController.text = dedAmount.toStringAsFixed(2);
  }

  void updateNetPayment() {
    double dedAmount = double.tryParse(dedAmountController.text) ?? 0;
    double milkTotal = double.tryParse(milkTotalBillController.text) ?? 0;
    netPayController.text = (milkTotal - dedAmount).toStringAsFixed(2);
  }

  void saveChanges() async {
    if (memberCodeController.text == "" ||
        fromDateController.text == "" ||
        toDateController.text == "") {
      Fluttertoast.showToast(msg: "Enter code and dates");
      return;
    }
    if (_formKey.currentState!.validate()) {
      print("Validated successfully");
    } else {
      print("Validation failed");
      return;
    }
    double cattleFeedBalance =
        (double.tryParse(cattleFeedBalanceController.text) ?? 0) -
            (double.tryParse(cattleFeedDeductionController.text) ?? 0);

    double creditMilkBalance =
        (double.tryParse(creditMilkBalanceController.text) ?? 0) -
            (double.tryParse(creditMilkDeductionController.text) ?? 0);

    double otherExpense =
        (double.tryParse(otherExpenseBalanceController.text) ?? 0) -
            (double.tryParse(otherExpenseDeductionController.text) ?? 0);
    double expenseBalance =
        (double.tryParse(expenseBalanceController.text) ?? 0) -
            (double.tryParse(expenseDeductionController.text) ?? 0);
    double doctorVisitingFees =
        (double.tryParse(doctorVisitFeesBalanceController.text) ?? 0) -
            (double.tryParse(doctorVisitFeesDeductionController.text) ?? 0);
    double totalBalance = (double.tryParse(totalBalController.text) ?? 0) -
        (double.tryParse(dedAmountController.text) ?? 0);
    double loanBalance = (double.tryParse(loanBalanceController.text) ?? 0) - (double.tryParse(loanDeductionController.text) ?? 0);
        double advanceBalance =   (double.tryParse(advanceBalanceController.text) ?? 0) - (double.tryParse(advanceDeductionController.text) ?? 0) ;
   setState(() {
     isLoading = true;
   });
    if(loanEntry != null)
    {
      double remainingLoanDeduction = (loanInterest - (double.tryParse(loanDeductionController.text) ?? 0));
      loanBalance = (double.tryParse(loanBalanceController.text) ?? 0) -((remainingLoanDeduction < 0)? remainingLoanDeduction:0.0);
      loanInterest = (remainingLoanDeduction > 0)?remainingLoanDeduction:0.0;
      loanEntry!.remainingInterest = loanInterest;
      loanEntry!.loanAmount = loanBalance;
      loanEntry!.recentDeduction = DateTime.now().toIso8601String();
      LoanEntryService.addLoanEntry(loanEntry!);
    }
    if(advanceEntry != null)
      {
        double remainingAdvanceDeduction = (advanceInterest - (double.tryParse(advanceDeductionController.text) ?? 0));
        advanceBalance =
            (double.tryParse(advanceBalanceController.text) ?? 0) - ((remainingAdvanceDeduction < 0)? remainingAdvanceDeduction:0.0);
        advanceInterest = (remainingAdvanceDeduction > 0)?remainingAdvanceDeduction:0.0;
        advanceEntry!.remainingInterest = advanceInterest;
        advanceEntry!.advanceAmount = advanceBalance;
        advanceEntry!.recentDeduction = DateTime.now().toIso8601String();
        CustomerAdvanceService.addCustomerAdvance(advanceEntry!);
      }
    CustomerBalance customerBalance = CustomerBalance(
        adminId: admin.id!,
        customerId: selectedCustomer.code!,
        balanceCattleFeed: (cattleFeedBalance < 0) ? 0 : cattleFeedBalance,
        balanceAdvance: (advanceBalance < 0) ? 0 : advanceBalance,
        balanceCreditMilk: (creditMilkBalance < 0) ? 0 : creditMilkBalance,
        balanceLoan: (loanBalance < 0) ? 0 : loanBalance,
        balanceExpense: (expenseBalance < 0) ? 0 : expenseBalance,
        balanceDoctorVisitingFees:
            (doctorVisitingFees < 0) ? 0 : doctorVisitingFees,
        balanceOtherExpense: (otherExpense < 0) ? 0 : otherExpense,
        totalBalance: (totalBalance < 0) ? 0 : totalBalance);
    Deduction deduction = Deduction(
        adminId: admin.id!,
        customerId: selectedCustomer.code!,
        cattleFeed: double.tryParse(cattleFeedDeductionController.text) ?? 0,
        advance: double.tryParse(advanceDeductionController.text) ?? 0,
        creditMilk: double.tryParse(creditMilkDeductionController.text) ?? 0,
        loan: double.tryParse(loanDeductionController.text) ?? 0,
        doctorVisitFees:
            double.tryParse(doctorVisitFeesDeductionController.text) ?? 0,
        expense: double.tryParse(expenseDeductionController.text) ?? 0,
        otherExpense:
            double.tryParse(otherExpenseDeductionController.text) ?? 0,
        date: from.toIso8601String(),
        total: double.tryParse(dedAmountController.text) ?? 0);
    bool? isCustomerBalanceUpdated =
        await CustomerBalanceService().addCustomerBalanceAuth(customerBalance);

    if (isCustomerBalanceUpdated == null) {
      CustomWidgets.logout(context);
      setState(() {
        isLoading = false;
      });
      return;
    }
    // bool isDeductionUpdated = await DeductionService.addDeduction(deduction);
    bool? isDeductionUpdated =
        await DeductionService().addDeductionAuth(deduction);
    if (isDeductionUpdated == null) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => LoginPage()),
        (route) => false, // Clears entire stack
      );
      setState(() {
        isLoading = false;
      });
      return;
    }
    setState(() {
      isLoading = false;
    });
    if (isCustomerBalanceUpdated && isDeductionUpdated) {
      Fluttertoast.showToast(msg: "Saved");
      clearAllControllers();
    } else {
      Fluttertoast.showToast(msg: "Error");
    }
  }

  void clearAllControllers() {
    milkTotalBillController.clear();
    totalBalController.clear();
    dedAmountController.clear();
    netPayController.clear();
    fromDateController.clear();
    toDateController.clear();
    memberCodeController.clear();
    nameController.clear();
    cattleFeedBalanceController.clear();
    advanceBalanceController.clear();
    creditMilkBalanceController.clear();
    loanBalanceController.clear();
    otherExpenseBalanceController.clear();
    doctorVisitFeesBalanceController.clear();
    expenseBalanceController.clear();
    cattleFeedDeductionController.clear();
    advanceDeductionController.clear();
    creditMilkDeductionController.clear();
    loanDeductionController.clear();
    otherExpenseDeductionController.clear();
    doctorVisitFeesDeductionController.clear();
    expenseDeductionController.clear();
  }

  double controllerToDouble(TextEditingController controller) {
    if (controller.text.isEmpty) {
      return 0;
    }
    return double.parse(controller.text);
  }

  String? cattleFeedDeductionValidator(String? value) {
    double balance = controllerToDouble(cattleFeedBalanceController);
    double deduction = controllerToDouble(cattleFeedDeductionController);
    if (deduction >= 0 && balance >= deduction) {
      return null;
    } else {
      return " Invalid";
    }
  }

  String? advanceDeductionValidator(String? value) {
    double balance = currentCustomerBalance!.balanceAdvance! + advanceInterest + advanceInterest;
    double deduction = controllerToDouble(advanceDeductionController);
    if (deduction >= 0 && balance >= deduction) {
      return null;
    } else {
      return " Invalid";
    }
  }

  String? milkCreditDeductionValidator(String? value) {
    double balance = controllerToDouble(creditMilkBalanceController);
    double deduction = controllerToDouble(creditMilkDeductionController);
    if (deduction >= 0 && balance >= deduction) {
      return null;
    } else {
      return " Invalid";
    }
  }

  String? loanDeductionValidator(String? value) {
    double balance = currentCustomerBalance!.balanceLoan! + loanInterest + loanInterest;
    double deduction = controllerToDouble(loanDeductionController);
    if (deduction >= 0 && balance >= deduction) {
      return null;
    } else {
      return " Invalid";
    }
  }


  String? otherExpenseDeductionValidator(String? value) {
    double balance = controllerToDouble(otherExpenseBalanceController);
    double deduction = controllerToDouble(otherExpenseDeductionController);
    if (deduction >= 0 && balance >= deduction) {
      return null;
    } else {
      return " Invalid";
    }
  }

  String? doctorVisitFeesDeductionValidator(String? value) {
    double balance = controllerToDouble(doctorVisitFeesBalanceController);
    double deduction = controllerToDouble(doctorVisitFeesDeductionController);
    if (deduction >= 0 && balance >= deduction) {
      return null;
    } else {
      return " Invalid";
    }
  }

  String? expenseDeductionValidator(String? value) {
    double balance = controllerToDouble(expenseBalanceController);
    double deduction = controllerToDouble(expenseDeductionController);
    if (deduction >= 0 && balance >= deduction) {
      return null;
    } else {
      return " Invalid";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue[50],
      appBar: CustomWidgets.buildAppBar("Deduction Master"),
      body: Stack(
        children: [

          SingleChildScrollView(
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  SizedBox(
                    width: 112,
                    child: Autocomplete<Customer>(
                      optionsBuilder: (TextEditingValue textEditingValue) {
                        return customerList
                            .where((supplier) =>
                            supplier.code!.contains(textEditingValue.text))
                            .toList();
                      },
                      displayStringForOption: (Customer option) =>
                      "${option.code!} - ${option.name!}",
                      onSelected: (Customer selection) {
                        selectedCustomer = selection;

                        memberCodeController.text = selection.code!;
                        nameController.text = selection.name!;
                        FocusScope.of(context)
                            .requestFocus(saveFocusNode); // Hide suggestions
                      },
                      fieldViewBuilder:
                          (context, controller, focusNode, onEditingComplete) {
                        memberCodeController = controller;
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
                            .where((supplier) => supplier.name!
                            .toLowerCase()
                            .contains(textEditingValue.text.toLowerCase()))
                            .toList();
                      },
                      displayStringForOption: (Customer option) =>
                      "${option.code!} - ${option.name!}",
                      onSelected: (Customer selection) {
                        selectedCustomer = selection;
                        memberCodeController.text = selection.code!;
                        nameController.text = selection.name!;
                        FocusScope.of(context)
                            .requestFocus(saveFocusNode); // Hide suggestions
                      },
                      fieldViewBuilder:
                          (context, controller, focusNode, onEditingComplete) {
                        nameController = controller;
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
              SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: fromDateController,
                      readOnly: true,
                      decoration: InputDecoration(
                        labelText: "From",
                        border: OutlineInputBorder(),
                        contentPadding:
                        EdgeInsets.symmetric(vertical: 2, horizontal: 10),
                        filled: true,
                        fillColor: Colors.white,
                        suffixIcon: IconButton(
                          icon: Icon(Icons.calendar_month),
                          onPressed: () =>
                              _selectDate(context, fromDateController, "from"),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 20),
                  Expanded(
                    child: TextField(
                      readOnly: true,
                      controller: toDateController,
                      decoration: InputDecoration(
                        labelText: "To",
                        border: OutlineInputBorder(),
                        contentPadding:
                        EdgeInsets.symmetric(vertical: 2, horizontal: 10),
                        filled: true,
                        fillColor: Colors.white,
                        suffixIcon: IconButton(
                          icon: Icon(Icons.calendar_month),
                          onPressed: () =>
                              _selectDate(context, toDateController, "to"),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(
                height: 10,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CustomWidgets.customButton(
                      onPressed: _searchDeductionInfo,
                      focusNode: saveFocusNode,
                      text: "search")
                ],
              ),
              SizedBox(height: 20),
              TextField(
                readOnly: true,
                controller: milkTotalBillController,
                decoration: InputDecoration(
                  labelText: "Milk Total Bill (₹)",
                  border: OutlineInputBorder(),
                  contentPadding:
                  EdgeInsets.symmetric(vertical: 2, horizontal: 10),
                  filled: true,
                  fillColor: Colors.white,
                ),
              ),
              SizedBox(height: 20),
              Text("Deduction List",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              Form(
                key: _formKey,
                child: Table(
                  border: TableBorder.all(),
                  children: [
                    TableRow(children: [
                      tableCell("Deduction Name", true),
                      tableCell("Balance", true),
                      tableCell("Deduction", true),
                    ]),
                    TableRow(
                      children: [
                        tableCell("Cattle Feed", false),
                        tableInputField(
                          controller: cattleFeedBalanceController,
                          isEditable: false,
                        ),
                        tableInputField(
                            controller: cattleFeedDeductionController,
                            isEditable: true,
                            validator: cattleFeedDeductionValidator),
                      ],
                    ),
                    TableRow(
                      children: [
                        tableCell("Advance", false),
                        tableInputField(
                            controller: advanceBalanceController,
                            isEditable: false),
                        tableInputField(
                            controller: advanceDeductionController,
                            isEditable: true,
                            validator: advanceDeductionValidator),
                      ],
                    ),
                    TableRow(
                      children: [
                        tableCell("Milk Credit", false),
                        tableInputField(
                          controller: creditMilkBalanceController,
                          isEditable: false,
                        ),
                        tableInputField(
                            controller: creditMilkDeductionController,
                            isEditable: true,
                            validator: milkCreditDeductionValidator),
                      ],
                    ),
                    TableRow(
                      children: [
                        tableCell("Loan", false),
                        tableInputField(
                          controller: loanBalanceController,
                          isEditable: false,
                        ),
                        tableInputField(
                            controller: loanDeductionController,
                            isEditable: true,
                            validator: loanDeductionValidator),
                      ],
                    ),
                    TableRow(
                      children: [
                        tableCell("Other Expenses", false),
                        tableInputField(
                          controller: otherExpenseBalanceController,
                          isEditable: false,
                        ),
                        tableInputField(
                            controller: otherExpenseDeductionController,
                            isEditable: true,
                            validator: otherExpenseDeductionValidator),
                      ],
                    ),
                    TableRow(
                      children: [
                        tableCell("Doctor Visit Fees", false),
                        tableInputField(
                          controller: doctorVisitFeesBalanceController,
                          isEditable: false,
                        ),
                        tableInputField(
                            controller: doctorVisitFeesDeductionController,
                            isEditable: true,
                            validator: doctorVisitFeesDeductionValidator),
                      ],
                    ),
                    TableRow(
                      children: [
                        tableCell("Expense", false),
                        tableInputField(
                          controller: expenseBalanceController,
                          isEditable: false,
                        ),
                        tableInputField(
                            controller: expenseDeductionController,
                            isEditable: true,
                            validator: expenseDeductionValidator),
                      ],
                    ),
                  ],
                ),
              ),
              SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                      child: TextField(
                          controller: totalBalController,
                          decoration: InputDecoration(
                              labelText: "Total Balance",
                              labelStyle: TextStyle(color: Colors.black),
                              border: OutlineInputBorder(),
                              contentPadding: EdgeInsets.symmetric(
                                  vertical: 2, horizontal: 10),
                              filled: true,
                              fillColor: Colors.white),
                          readOnly: true)),
                  SizedBox(width: 10),
                  Expanded(
                      child: TextField(
                          controller: dedAmountController,
                          decoration: InputDecoration(
                            labelText: "Deduction Amount",
                            labelStyle: TextStyle(
                              color: Colors.black,
                            ),
                            border: OutlineInputBorder(),
                            contentPadding:
                            EdgeInsets.symmetric(vertical: 2, horizontal: 10),
                            filled: true,
                            fillColor: Colors.white,
                          ),
                          readOnly: true)),
                ],
              ),
              SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: netPayController,
                      decoration: InputDecoration(
                        labelText: "Net Pay (₹)",
                        labelStyle: TextStyle(color: Colors.black),
                        border: OutlineInputBorder(),
                        filled: true,
                        fillColor: Colors.white,
                        contentPadding:
                        EdgeInsets.symmetric(vertical: 2, horizontal: 10),
                      ),
                      readOnly: true,
                    ),
                  ),
                  SizedBox(
                    width: 10,
                  ),
                  Expanded(
                    child: SizedBox(
                      width: 50,
                      child: ElevatedButton(
                        onPressed: saveChanges,
                        style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF24A1DE)),
                        child: const Text('Save',
                            style: TextStyle(color: Colors.white)),
                      ),
                    ),
                  )
                ],
              )
            ],
          ),
        ),
          if (isLoading)
            Positioned.fill(
              child: Container(
                color: Colors.black.withOpacity(0.3),
                child: Center(child: CircularProgressIndicator()),
              ),
            ),
        ],
      )

    );
  }

  Widget tableCell(String text, bool isHeader) {
    return Padding(
      padding: EdgeInsets.all(8),
      child: Text(text,
          style: TextStyle(
              fontWeight: isHeader ? FontWeight.bold : FontWeight.normal)),
    );
  }

  Widget tableInputField(
      {required TextEditingController controller,
      required bool isEditable,
      validator}) {
    return Padding(
      padding: EdgeInsets.all(8),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
            border: OutlineInputBorder(),
            filled: true,
            fillColor: Colors.white),
        keyboardType: TextInputType.number,
        validator: validator,
        readOnly: !isEditable,
        //  onChanged: (value) => updateCalculations(),
      ),
    );
  }
}