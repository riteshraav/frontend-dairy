import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:hive/hive.dart';
import '../../model/customerqueue.dart';
import '../../screens/drawer_screens/drawer_screen.dart';
import '../../service/customer_service.dart';
import '../../service/sms_service.dart';
import '../../widgets/appbar.dart';
import '../../model/Customer.dart';
import '../../model/admin.dart';
import '../../service/admin_service.dart';
import '../auth_screens/login_screen.dart';

class AddCustomerPage extends StatefulWidget {
  Admin admin = CustomWidgets.currentAdmin();
  Customer? customer;
  AddCustomerPage(this.customer);

  @override
  _AddCustomerPageState createState() => _AddCustomerPageState();
}

class _AddCustomerPageState extends State<AddCustomerPage> {
  // Controllers for text fields
  final _formKey = GlobalKey<FormState>();

  final TextEditingController emailController = TextEditingController();
  final TextEditingController alternativemobileController = TextEditingController();
  final TextEditingController panController = TextEditingController();
  final TextEditingController aadharController = TextEditingController();
  //final TextEditingController accountNumberController = TextEditingController();
  final TextEditingController ifscCodeController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _idController = TextEditingController();
  final TextEditingController bankCodeController = TextEditingController();
  final TextEditingController sabhasaadController = TextEditingController();
  final TextEditingController bankBranchController = TextEditingController();
  final TextEditingController bankAccountNoController = TextEditingController();
  final TextEditingController animalCountController = TextEditingController();
  final TextEditingController averageMilkController = TextEditingController();
  bool isLoading = false;
  String? milkType;
  String? className;
  String? branch;
  String? gender;
  String? caste;
  String? label;

  bool isCowSelected = false;
  bool isBuffaloSelected = false;

  // Variables to store checkbox states
  String selectedMilkType = "";

// Validation Functions
  String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter an email';
    }
    String pattern = r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$';
    RegExp regex = RegExp(pattern);
    if (!regex.hasMatch(value)) {
      return 'Enter a valid email';
    }
    return null;
  }

  String? validateCustomerName(String? value) {
    if (value == null || value.isEmpty) {
      return 'please enter Customer Name';
    }
  }

  String? validateBankName(String? value) {
    if (value == null || value.isEmpty) {
      return 'please enter Bank  Name';
    }
  }


  String? validateIFSC(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter an IFSC code';
    }

    final regex = RegExp(r'^[A-Z]{4}0[A-Z0-9]{6}$');

    if (!regex.hasMatch(value)) {
      return 'Enter a valid IFSC code (e.g., SBIN0123456)';
    }

    return null;
  }



  String? validateanimalcount(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter a value';
    }
    final regex = RegExp(r'^-?[0-9]+$'); // Matches negative and positive integers
    if (!regex.hasMatch(value)) {
      return 'Please enter a valid integer';
    }
    return null;
  }

  String? validateavgmilk(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter a avg milk value';
    }
    final regex = RegExp(r'^-?[0-9]+$'); // Matches negative and positive integers
    if (!regex.hasMatch(value)) {
      return 'Please enter a valid integer';
    }
    return null;
  }

  String? validateMobile(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter a mobile number';
    }
    String pattern = r'^[6-9]\d{9}$'; // Validates 10-digit numbers starting with 6-9
    RegExp regex = RegExp(pattern);
    if (!regex.hasMatch(value)) {
      return 'Enter a valid 10-digit mobile number';
    }
    return null;
  }
  String? validateAlternativemobile(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter a mobile number';
    }
    String pattern = r'^[6-9]\d{9}$'; // Validates 10-digit numbers starting with 6-9
    RegExp regex = RegExp(pattern);
    if (!regex.hasMatch(value)) {
      return 'Enter a valid 10-digit mobile number';
    }
    return null;
  }
  String? validateAadhar(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter an Aadhar number';
    }
    String pattern = r'^\d{12}$'; // Validates a 12-digit Aadhar number
    RegExp regex = RegExp(pattern);
    if (!regex.hasMatch(value)) {
      return 'Enter a valid 12-digit Aadhar number';
    }
    return null;
  }

  String? Validatesabhsaadnumber(String ? value){
    if(value ==null || value.isEmpty){
      return "please enter valid sabhasaad number";
    }
    final regex = RegExp(r'^(?:[1-9][0-9]{0,3})$');
    if (!regex.hasMatch(value)) {
      return 'Enter a valid number between 1 and 9999';
    }
    return null;
  }

  String? ValidateBankAccountNo(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter an account number';
    }
    String pattern = r'^\d{11}$'; // Validates a 11-digit Aadhar number
    RegExp regex = RegExp(pattern);
    if (!regex.hasMatch(value)) {
      return 'Enter a valid 11-digit account number';
    }
    return null;
  }
  String? validatePAN(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter a PAN number';
    }
    String pattern = r'^[A-Z]{5}[0-9]{4}[A-Z]{1}$'; // Standard PAN format
    RegExp regex = RegExp(pattern);
    if (!regex.hasMatch(value)) {
      return 'Enter a valid PAN number (ABCDE1234F)';
    }
    return null;
  }

  String ? validateBankCode(String? value){
    if(value==null || value.isEmpty){
      return 'please enter a Bank Code';
    }
    final regex=RegExp(r'^[A-Z]{4}$');
    if(!regex.hasMatch(value)){
      return 'Only 4 capital letters allowed';

    }
    return null;
  }
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    if(widget.customer != null)
    {
      _idController.text = widget.customer!.code!;
      _nameController.text = widget.customer!.name ?? '';
      _phoneController.text = widget.customer!.phone ?? '';
      isCowSelected = widget.customer!.cow ?? false;
      isBuffaloSelected = widget.customer!.buffalo ?? false;
      emailController.text = widget.customer!.email ?? '';
      alternativemobileController.text = widget.customer!.alternateNumber??'';
      panController.text = widget.customer!.panNo ?? '';
      aadharController.text = widget.customer!.aadharNo ?? '';
      ifscCodeController.text = widget.customer!.ifscNo ?? '';
      bankCodeController.text = widget.customer!.bankCode ?? '';
      sabhasaadController.text = widget.customer!.sabhasadNo ?? '';
      bankBranchController.text = widget.customer!.bankBranchName ?? '';
      bankAccountNoController.text = widget.customer!.bankAccountNo ?? '';
      animalCountController.text = widget.customer!.animalCount.toString() ;
      averageMilkController.text = widget.customer!.averageMilk.toString() ;
    }
    else{
      _idController.text = (widget.admin.customerSequence!+1).toString();
    }
  }
  // Save customer logic
  void _saveCustomer() async {
    //var isDeviceConnected = await  CustomWidgets.internetConnection();
    // if(!isDeviceConnected){
    //
    //   CustomWidgets.showDialogueBox(context : context);
    //   return;
    // }
    if(milkType == "")
    {
      Fluttertoast.showToast(msg: "Enter milk type");
      return;
    }
    if(milkType == "Buffalo")
    {
      isBuffaloSelected = true;
      isCowSelected = false;
    }
    else if(milkType == 'Cow')
    {
      isCowSelected = true;
      isBuffaloSelected= false;
    }
    else{
      isBuffaloSelected = true;
      isCowSelected = true;
    }
    print(milkType);
    print(isBuffaloSelected);
    print(isCowSelected);
    String name = _nameController.text.trim().toUpperCase();
    String phone = _phoneController.text.trim();


    var customerBox = Hive.box<List<Customer>>('customerBox');
    //  var customerQueueBox = Hive.box<Map<String,List<dynamic>>>('customerQueueBox');
    // Map<String,List<dynamic>> customerQueue = customerQueueBox.get('customerQueue')??{};
    List<Customer> customerList = customerBox.get('customers')??[];
    if(widget.customer != null)
    {
      Customer customer = Customer(
          code:widget.customer!.code,
          name: name,
          phone: phone,
          adminId: widget.admin.id,
          cow: isCowSelected,
          buffalo: isBuffaloSelected,
          classType: className,
          branchName: branch,
          gender: gender,
          caste: caste,
          alternateNumber: alternativemobileController.text,
          email: emailController.text,
          //accountNo: accountNumberController.text,
          bankCode: bankCodeController.text,
          sabhasadNo: sabhasaadController.text,
          bankBranchName: bankBranchController.text,
          bankAccountNo: bankAccountNoController.text,
          ifscNo: ifscCodeController.text,
          aadharNo: aadharController.text,
          panNo: panController.text,
          animalCount: int.parse(animalCountController.text),
          averageMilk: double.parse(averageMilkController.text));
      //update in cache
      int index = customerList.indexWhere((c) => c.code == customer.code);
      customerList[index] = customer;
      customerBox.put('customers',customerList);
      //update in database
      bool updated = await  CustomerService.updateCustomer(customer);
      if(updated) {
        CustomWidgets.showCustomSnackBar(
            'Customer is updated with Id ${customer.code}', context, 2);
        String sms = "Dear Customer, "
            "Your info is updated in ${widget.admin.dairyName} as\n"
            "Code : ${customer.code}"
            "Name : $name\n"
            "Phone : $phone\n"
            "Type : ";
        String cowS =  (isCowSelected)?"cow ":" ";
        String buffaloS =  (isBuffaloSelected)?"buffalo":"";
        sms = "$sms$cowS$buffaloS\n";
        bool sent = await SmsService.sendSms(phone,sms);
        if(sent)
          Fluttertoast.showToast(msg: "Message sent");
      }
      //maintain a queue if device is not connected to the internet
      else
      {
        // List<dynamic>list = [customer.code,customer.name,customer.phone,customer.buffalo,customer.cow,customer.adminId,
        //   customer.classType, customer.branchName,customer.gender,customer.caste,customer.alternateNumber,customer.email,
        // customer.accountNo,customer.bankCode,customer.sabhasadNo,customer.bankBranchName,customer.bankAccountNo,
        // customer.ifscNo,customer.aadharNo,customer.panNo,customer.animalCount,customer.averageMilk];
        //     customerQueue.putIfAbsent(customer.code!, ()=>list);
        //     customerQueueBox.put('customerQueue', customerQueue);
        print("could not update customer");
        Fluttertoast.showToast(msg: "error");
      }
    }
    else {
      String code = (widget.admin.customerSequence!+1).toString();
      Admin admin = widget.admin;
      Customer customer = Customer(
          code:code,
          name: name,
          phone: phone,
          adminId: widget.admin.id,
          buffalo: isBuffaloSelected,
          cow: isCowSelected,
          classType: className,
          branchName: branch,
          gender: gender,
          caste: caste,
          alternateNumber: alternativemobileController.text,
          email: emailController.text,
          // accountNo: accountNumberController.text,
          bankCode: bankCodeController.text,
          sabhasadNo: sabhasaadController.text,
          bankBranchName: bankBranchController.text,
          bankAccountNo: bankAccountNoController.text,
          ifscNo: ifscCodeController.text,
          aadharNo: aadharController.text,
          panNo: panController.text,
          animalCount: int.parse(animalCountController.text),
          averageMilk: double.parse(averageMilkController.text)
      );


      // //update in cache
      customerList.add(customer);
      customerBox.put('customers',customerList);

      // update in database

      bool isRegistered = await CustomerService.addCustomer(customer);
      if(isRegistered){
        //prepare sms to send to customer
        String sms = "Dear Customer, "
            "You have registered in ${widget.admin.dairyName} as\n"
            "Code : $code\n"
            "Name : $name\n"
            "Phone Number : $phone\n"
            "Type : ";
        String cowS =  (isCowSelected)?"cow ":" ";
        String buffaloS =  (isBuffaloSelected)?"buffalo":"";
        sms = "$sms$cowS$buffaloS\n";
        bool sent = await SmsService.sendSms(phone,sms);
        // if(sent)
        //   Fluttertoast.showToast(msg: "Message sent");
      }


      //maintain a queue if device is not connected to the internet
      else
      {
        // List<dynamic>list = [customer.code,customer.name,customer.phone,customer.buffalo,customer.cow,customer.adminId,
        //   customer.classType, customer.branchName,customer.gender,customer.caste,customer.alternateNumber,customer.email,
        //   customer.accountNo,customer.bankCode,customer.sabhasadNo,customer.bankBranchName,customer.bankAccountNo,
        //   customer.ifscNo,customer.aadharNo,customer.panNo,customer.animalCount,customer.averageMilk];
        // customerQueue.putIfAbsent(customer.code!, ()=>list);
        // customerQueueBox.put('customerQueue', customerQueue);
        Fluttertoast.showToast(msg: "couldnot add customer");
        print("customer not added");

      }

      admin.customerSequence = widget.admin.customerSequence!+1;
      widget.admin = admin;
      updateAdmin(admin);
      CustomWidgets.showCustomSnackBar(
          'Customer is added with Code $code', context, 2);
      _resetInfo();

    }

  }
  void updateAdmin(Admin admin)async{
    bool? isAdminUpdated = await CustomWidgets.updateAdmin(admin,context);
    if(isAdminUpdated == null)
    {
      // Navigator.of(context).pushAndRemoveUntil(
      //   MaterialPageRoute(builder: (context) => LoginPage()),
      //       (route) => false, // Clears entire stack
      // );
      print("could not update admin");
      Fluttertoast.showToast(msg: "could not update admin");
      return;
    }
  }
  // Reset form logic
  void _resetInfo() {
    setState(() {
      _idController.text = (widget.admin.customerSequence!+1).toString();
      _nameController.clear();
      _phoneController.clear();
      isBuffaloSelected = false;
      isCowSelected = false;
      emailController.clear();
      alternativemobileController.clear();
      panController.clear();
      aadharController.clear();
      //accountNumberController.clear();
      ifscCodeController.clear();
      _phoneController.clear();
      bankCodeController.clear();
      sabhasaadController.clear();
      bankBranchController.clear();
      bankAccountNoController.clear();
      animalCountController.clear();
      averageMilkController.clear();


    });
  }

  String? currentMilkType(){

    if(widget.customer != null)
    {
      Customer c = widget.customer!;
      if(c.cow! && c.buffalo!)
      {
        return "Cow & Buffalo";
      }
      else if(c.cow!)
      {
        return "Cow";
      }
      else
        return "Buffalo";
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue[50],
      appBar: CustomWidgets.buildAppBar(widget.customer == null ?"Add Customer":"Edit Customer"),
      body: Stack(
        children:[ Padding(
          padding: EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: Column(
                children: [
                  _buildTextField(labelText: 'Code',
                      keyboardType: TextInputType.number,controller: _idController,readonly: true),
                  _buildTextField(labelText: 'Customer Name',controller: _nameController,
                      validator: validateCustomerName),
                  SizedBox(height: 20),

                  // Row for dropdowns
                  Row(
                    children: [
                      Flexible(child: _buildDropdownField('Milk Type', ['Cow', 'Buffalo', 'Cow & Buffalo'],currentMilkType(), validator:(value)=> value==null ? 'please select milk type':null,),),
                      SizedBox(width: 10),
                      Flexible(child: _buildDropdownField('Class', ['A', 'B', 'C'],widget.customer?.classType,validator:(value)=> value==null ? 'Please select class' : null,),),
                    ],
                  ),

                  SizedBox(height: 15),
                  Row(
                    children: [
                      Flexible(child: _buildDropdownField('Branch', ['Branch1', 'Branch2', 'Branch3'],widget.customer?.branchName,validator: (value)=> value==null? 'please select class': null,),),
                    ],
                  ),
                  SizedBox(height: 15),

                  Row(
                    children: [
                      Expanded(child: _buildDropdownField('Gender', ['Male', 'Female'], widget.customer?.gender,validator: (value)=> value==null?'please select Gender': null,),),
                      SizedBox(width: 10),
                      Expanded(child: _buildDropdownField('Caste', ['Caste1', 'Caste2', 'Caste3'],widget.customer?.caste, validator: (value)=> value==null? 'please select caste':null),),
                    ],
                  ),
                  SizedBox(height: 15),

                  // Mobile Fields
                  Row(
                    children: [
                      Expanded(
                        child: _buildTextField(
                          labelText: 'Mobile Number',
                          controller: _phoneController,
                          keyboardType: TextInputType.phone,
                          validator: validateMobile,
                        ),
                      ),

                    ],
                  ),
                  SizedBox(height: 15),
                  Row(
                    children: [
                      Expanded(child: _buildTextField(labelText: 'Alternative Mobile Number',
                        controller: alternativemobileController,
                        keyboardType: TextInputType.phone,
                        validator: validateAlternativemobile,)),
                    ],

                  ),
                  SizedBox(height:15),
                  // Email Field
                  _buildTextField(
                    labelText: 'Email',
                    controller: emailController,
                    keyboardType: TextInputType.emailAddress,
                    validator: validateEmail,
                  ),
                  // SizedBox(height: 15),
                  //
                  // // Account & Bank Fields
                  // _buildTextField(labelText: 'Account No',
                  //   controller: accountNumberController,
                  //   keyboardType: TextInputType.number,
                  //   validator: ValidateAccountNo,
                  // ),
                  SizedBox(height: 15),

                  Row(
                    children: [
                      Expanded(child: _buildTextField(labelText: 'Bank Code',
                          controller: bankCodeController,

                          validator: validateBankCode)),
                      SizedBox(width: 10),
                      Expanded(child: _buildTextField(labelText: 'Sabhasad No',
                          keyboardType: TextInputType.number,
                          controller: sabhasaadController,
                          validator: Validatesabhsaadnumber),
                      ),
                    ],
                  ),
                  SizedBox(height: 15),

                  _buildTextField(labelText: 'Bank Branch Name',
                      keyboardType: TextInputType.text,
                      controller: bankBranchController,
                      validator:validateBankName),
                  SizedBox(height: 15),

                  _buildTextField(labelText: 'Bank Account Number',
                      keyboardType: TextInputType.number,
                      controller: bankAccountNoController,
                      validator: ValidateBankAccountNo),
                  SizedBox(height: 15),

                  _buildTextField(labelText: 'IFSC Code',
                    controller: ifscCodeController,
                    keyboardType: TextInputType.text,
                    validator: validateIFSC,
                  ),
                  SizedBox(height: 15),

                  // Aadhar & PAN Fields
                  Row(
                    children: [
                      Expanded(child: _buildTextField(labelText: 'Aadhar Number'
                        ,controller: aadharController,
                        keyboardType: TextInputType.number,
                        validator: validateAadhar,)),
                      SizedBox(width: 10),
                      Expanded(
                        child: _buildTextField(
                          labelText: 'Pan Number',
                          controller: panController,
                          keyboardType: TextInputType.text,
                          validator: validatePAN,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 15),

                  Row(
                    children: [
                      Expanded(child: _buildTextField(labelText: 'Milk animal Count',
                          keyboardType: TextInputType.number,controller: animalCountController,
                          validator :validateanimalcount)),
                      SizedBox(width: 10),
                      Expanded(child: _buildTextField(labelText: 'Average Milk Production',
                          keyboardType: TextInputType.number,controller: averageMilkController,validator :validateavgmilk)),
                    ],
                  ),
                  SizedBox(height: 15),

                  // Submit Button
                  CustomWidgets.customButton(text:  "Submit",onPressed:  (){
                    if (_formKey.currentState!.validate()) {
                      print("validated all");
                      _saveCustomer();
                    }
                    else{
                      Fluttertoast.showToast(msg: "Add Validations");
                    }
                  })
                ],
              ),
            ),
          ),
        ),
          if (isLoading)
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
  // Improved _buildTextField function
  Widget _buildTextField({
    required String labelText,
    TextEditingController? controller,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
    bool readonly = false
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        readOnly: readonly,
        controller: controller,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          labelText: labelText,
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(),
        ),
     //   validator: validator,
        // Apply validation if provided
      ),
    );
  }

  // Dropdown Field Builder
  Widget _buildDropdownField(
      String label,
      List<String> items,
      String? currentValue, {
        String? Function(String?)? validator,
        void Function(String?)? onChanged,
      })  {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: DropdownButtonFormField<String>(
        value: currentValue,

        decoration: InputDecoration(
          labelText: label,
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(),
        ),
        items: items.map((String item) {
          return DropdownMenuItem<String>(
            value: item,
            child: Text(item),
          );
        }).toList(),
        onChanged: (String? value) {
          if(label == "Milk Type")
          {
            milkType = value;
          }
          else if(label == 'Class'){
            className = value;
          }
          else if(label == "Branch"){
            branch = value;
          }
          else if(label == "Gender")
          {
            gender = value;
          }
          else{
            caste = value;
          }
        },
        validator: validator,
      ),
    );
  }
}