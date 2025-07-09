import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import '../../model/cattleFeedSupplier.dart';
import '../../screens/drawer_screens/new_custom_drawer.dart';
import '../../service/cattleFeedSupplierService.dart';
import '../../widgets/appbar.dart';
import 'package:hive/hive.dart';
import '../../model/admin.dart';
import '../auth_screens/login_screen.dart';

class AddSupplierScreen extends StatefulWidget {
  AddSupplierScreen({Key? key}) : super(key: key);
  Admin admin = CustomWidgets.currentAdmin();
  CattleFeedSupplier? cattleFeedSupplier;
// AddSupplierScreen(this.cattleFeedSupplier) ;


  @override
  _AddSupplierScreenState createState() => _AddSupplierScreenState();
}

class _AddSupplierScreenState extends State<AddSupplierScreen>{
  Admin admin = CustomWidgets.currentAdmin();
  final _formKey = GlobalKey<FormState>();
  final TextEditingController codeController = TextEditingController();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController mobileController = TextEditingController();
  final TextEditingController alternativemobileController = TextEditingController();
  final TextEditingController panController = TextEditingController();
  final TextEditingController aadharController= TextEditingController();
  //final TextEditingController accountNumberController= TextEditingController();
  final TextEditingController ifscCodeController= TextEditingController();
  final TextEditingController bankCodeController = TextEditingController();
  final TextEditingController sabhasadNumberController = TextEditingController();
  final TextEditingController bankBranchNameController = TextEditingController();
  final TextEditingController bankAccountNumberController = TextEditingController();

  String ? gender;

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

  String? validatesuppliername(String? value){
    if (value==null || value.isEmpty){
      return 'Please enter suppliername';
    }
  }
  void clearForm() {
    print('making code ${(admin.supplierSequence! + 1)}');
    codeController.text = (admin.supplierSequence!).toString();
    // nameController.clear();
    // emailController.clear();
    // mobileController.clear();
    // alternativemobileController.clear();
    // panController.clear();
    // aadharController.clear();
    // ifscCodeController.clear();
    // bankCodeController.clear();
    // sabhasadNumberController.clear();
    // bankBranchNameController.clear();
    // bankAccountNumberController.clear();
    // _formKey.currentState?.reset(); // This will also reset form-level validators
  }

  String ? validateBankbranchname(String? value){
    if(value==null || value.isEmpty){
      return 'please enter bank branch Name';
    }
  }

  String ? validatesabhasaadnumber(String? value) {
    if (value == null || value.isEmpty) {
      return 'please enter valid sabhasaadnumber';
    }
    final regex = RegExp(r'^(?:[1-9][0-9]{0,3})$');
    if (!regex.hasMatch(value)) {
      return 'Enter a valid number between 1 and 9999';
    }
    return null;
  }

  String? validateIFSC(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter an IFSC code';
    }
    String pattern = r'^[A-Z]{4}0[A-Z0-9]{6}$';

    RegExp regex = RegExp(pattern);
    if (!regex.hasMatch(value)) {
      return 'Enter a valid IFSC code (e.g., SBIN0123456)';
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

  String? ValidateAccountNo(String? value) {
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
    if(value==null ||value.isEmpty){
      return 'please enter a valid bank code';
    }
    final regex =RegExp(r'^[A-Z]{4}$');
    if(!regex.hasMatch(value)){
      return 'Only 4 captial letters are allowed';
    }
    return null;

  }
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    codeController.text =(admin.supplierSequence!).toString();
  }
  void registerCattleFeedSupplier()async{
    var isDeviceConnected =  await CustomWidgets.internetConnection();

    if (_formKey.currentState!.validate()) {
      String code = codeController.text;
      CattleFeedSupplier cattleFeedSupplier = CattleFeedSupplier(
          code: code,
          name : nameController.text,
          gender: gender,
          phoneNo: mobileController.text,
          alternatePhoneNo: alternativemobileController.text,
          email: emailController.text,
          //accountNo: accountNumberController.text,
          bankCode: bankCodeController.text,
          sabhasadNo: sabhasadNumberController.text,
          bankBranchName: bankBranchNameController.text,
          bankAccountNo: bankAccountNumberController.text,
          ifscCode: ifscCodeController.text,
          adharNo: aadharController.text,
          panNo:panController.text
      );
      if( isDeviceConnected) {
        if(await CattleFeedSupplierService.addCattleFeedSupplier(cattleFeedSupplier))
        {
          print('suplier saved');
          setState(() {
            admin.supplierSequence = admin.supplierSequence!+1;
          });
          updateAdmin();
          clearForm();
          Fluttertoast.showToast(
            msg: "Supplier successfully added!",
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.CENTER,
            backgroundColor: Colors.green,
            textColor: Colors.white,
          );
        }
      } else{
        var cattleFeedSupplierQueueBox = Hive.box<Map<String,List<CattleFeedSupplier>>>('cattleFeedSupplierBox');
        Map<String,List<dynamic>> cattleFeedSupplierList = cattleFeedSupplierQueueBox.get('cattleFeedSupplier')??{};

        List<dynamic>list =[cattleFeedSupplier.code,cattleFeedSupplier.name,cattleFeedSupplier.gender,
          cattleFeedSupplier.phoneNo,cattleFeedSupplier.alternatePhoneNo,
          cattleFeedSupplier.email,cattleFeedSupplier.accountNo,cattleFeedSupplier.bankCode,
          cattleFeedSupplier.sabhasadNo,cattleFeedSupplier.bankBranchName,cattleFeedSupplier.bankAccountNo,cattleFeedSupplier.adminId];
        cattleFeedSupplierList.putIfAbsent(cattleFeedSupplier.code!,()=>list );
      }
      var cattleFeedSupplierBox = Hive.box<List<CattleFeedSupplier>>('cattleFeedSupplierBox');
      List <CattleFeedSupplier> cattleFeedSupplierList = cattleFeedSupplierBox.get('cattleFeedSupplier')??[];
      cattleFeedSupplierList.add(cattleFeedSupplier);
      cattleFeedSupplierBox.put('cattleFeedSupplier', cattleFeedSupplierList);


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
      Fluttertoast.showToast(msg: "failed to update admin");
    }
  }
  @override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor: Colors.blue[50],
      drawer: NewCustomDrawer(),
      appBar: CustomWidgets.buildAppBar('Add Supplier'),
      body: SingleChildScrollView(
        child: Column(
          children: [
            CustomWidgets.buildInternetChecker(context),
            Padding(
              padding: EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    _buildTextField(labelText: 'Code',controller: codeController,isEnable: false,
                      keyboardType: TextInputType.number,),
                    _buildTextField(labelText: 'Supplier Name',controller: nameController,validator: validatesuppliername ),
                    SizedBox(height: 20),

                    Row(
                      children: [
                        Expanded(
                          child: _buildDropdownField(
                            'Gender',
                            ['Male', 'Female'],
                            widget.cattleFeedSupplier?.gender, // ✅ Correct reference
                            validator: (value) => value == null ? 'Please select gender' : null,
                          ),
                        ),
                        //Expanded(child: _buildDropdownField('Gender', ['Male', 'Female'],widget.cattleFeedsupplier?.gender,validator: (value)=>value==null?'please select gender':null),),
                        SizedBox(width: 10),
                      ],
                    ),
                    SizedBox(height: 20),

                    // Mobile Fields
                    Row(
                      children: [
                        Expanded(
                          child: _buildTextField(
                            labelText: 'Mobile Number',
                            controller: mobileController,
                            keyboardType: TextInputType.phone,
                            validator: validateMobile,
                          ),
                        ),
                        SizedBox(width: 10),

                      ],
                    ),
                    SizedBox(height: 20),
                    Row(
                      children: [
                        Expanded(child: _buildTextField(labelText: 'Alternative Mobile Number',
                            controller: alternativemobileController,
                            keyboardType: TextInputType.phone,
                            validator: validateAlternativemobile
                        ),
                        )],

                    ),
                    SizedBox(height:20),
                    // Email Field
                    _buildTextField(
                        labelText: 'Email',
                        controller: emailController,
                        keyboardType: TextInputType.emailAddress,
                        validator: validateEmail
                    ),
                    // SizedBox(height: 20),
                    //
                    // // Account & Bank Fields
                    // _buildTextField(labelText: 'Account No',controller: accountNumberController,
                    //   keyboardType: TextInputType.number,
                    //
                    // ),
                    SizedBox(height: 20),

                    Row(
                      children: [
                        Expanded(child: _buildTextField(labelText: 'Bank Code',controller: bankCodeController,
                          validator: validateBankCode,
                        )),
                        SizedBox(width: 10),
                        Expanded(child: _buildTextField(labelText: 'Sabhasad No',controller: sabhasadNumberController,
                            keyboardType: TextInputType.number, validator: validatesabhasaadnumber
                        )),
                      ],
                    ),
                    SizedBox(height: 20),

                    _buildTextField(labelText: 'Bank Branch Name',controller: bankBranchNameController,
                        keyboardType: TextInputType.text,validator: validateBankbranchname),
                    SizedBox(height: 20),

                    _buildTextField(labelText: 'Bank Account Number',
                      keyboardType: TextInputType.number,
                      controller: bankAccountNumberController,
                      validator: ValidateAccountNo,
                    ),
                    SizedBox(height: 20),

                    _buildTextField(labelText: 'IFSC Code',
                      controller: ifscCodeController,
                      keyboardType: TextInputType.text,
                      validator: validateIFSC,
                    ),
                    SizedBox(height: 20),

                    // Aadhar & PAN Fields
                    Row(
                      children: [
                        Expanded(child: _buildTextField(labelText: 'Aadhar Number'
                          ,controller: aadharController,
                          keyboardType: TextInputType.number,
                          validator: validateAadhar,
                        )),
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

                    SizedBox(height: 20),

                    // Submit Button
                    CustomWidgets.customButton(text:  "Submit",onPressed: registerCattleFeedSupplier),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Improved _buildTextField function
  Widget _buildTextField({
    required String labelText,
    required TextEditingController? controller,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
    bool isEnable = true
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
       readOnly: !isEnable,
        controller: controller,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          labelText: labelText,
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(),
        ),
        validator: validator, // Apply validation if provided
      ),
    );
  }

  // Dropdown Field Builder
  Widget _buildDropdownField(String label,
      List<String> items,
      String? currentValue,{
        String? Function(String?)? validator,
        void Function (String?)? onChanged,
      }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: DropdownButtonFormField<String>(
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
          setState(() {
            gender = value!;
          });
        },
        validator: validator,
      ),
    );
  }
}
