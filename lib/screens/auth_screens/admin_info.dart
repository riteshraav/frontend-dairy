import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import '../../screens/auth_screens/login_screen.dart';
import '../../service/admin_service.dart';
import '../../service/sms_service.dart';
import '../../widgets/appbar.dart';

import '../../model/admin.dart';

class AdminInfoScreen extends StatefulWidget {
  final String phone;
   AdminInfoScreen(this.phone);

  @override
  State<AdminInfoScreen> createState() => _AdminInfoScreenState();
}

class _AdminInfoScreenState extends State<AdminInfoScreen> {
  TextEditingController _emailController = TextEditingController();
  TextEditingController _dairyController = TextEditingController();
  TextEditingController _subDistrictController = TextEditingController();
  TextEditingController _stateController = TextEditingController();
  TextEditingController _passwordController = TextEditingController();
  TextEditingController _nameController = TextEditingController();
  TextEditingController _confirmPasswordController = TextEditingController();
  TextEditingController _cityController =TextEditingController();
  TextEditingController _districtController = TextEditingController();

  final FocusNode _nameFocusNode = FocusNode();
  Map<String, String> stateSuggestions = {
    "MH": "Maharashtra",
    "G": "Goa",
    "K": "Karnataka"
  };
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  void _updateStateSuggestion(String input) {
    String upperInput = input.toUpperCase();
    if (stateSuggestions.containsKey(upperInput)) {
      setState(() {
        _stateController.text = stateSuggestions[upperInput]!;
      });
    }
  }
  AdminService adminService = AdminService();
  void _validateAndProceed() {
    if (_nameController.text.isEmpty ||
        _emailController.text.isEmpty ||
        _dairyController.text.isEmpty ||
        _cityController.text.isEmpty ||
        _subDistrictController.text.isEmpty ||
        _districtController.text.isEmpty ||
        _stateController.text.isEmpty ||
        _passwordController.text.isEmpty ||
        _confirmPasswordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please fill all the fields")),
      );
    } else if (_passwordController.text != _confirmPasswordController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Passwords do not match")),
      );
    } else {
      FocusScope.of(context).unfocus(); // Hide keyboard
      _showConfirmationDialog();
    }
  }

  void _showConfirmationDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Confirm Details"),
          content: const Text("Are you sure you want to sign up with these details?"),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel"),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                signup();
              },
              child: const Text("Confirm"),
            ),
          ],
        );
      },
    );
  }
  void signup () async{
    var isDeviceConnected = await  CustomWidgets.internetConnection();
    if(!isDeviceConnected){
      CustomWidgets.showDialogueBox(context : context);
      return;
    }
     final admin =  Admin(dairyName: _dairyController.text,
          name: _nameController.text,
          password: _passwordController.text,
          id: widget.phone,
          city: _cityController.text,
          district: _districtController.text,
          subDistrict: _subDistrictController.text,
          state: _stateController.text);
      bool isRegisteredSuccessfully = await adminService.signupUser(admin);
      if(isRegisteredSuccessfully)
        {
          Fluttertoast.showToast(msg: "Registered successfully");
          String msg = "\n Dear Dairy owner!\n"
              "Your registration for binary solutions app is successful";
          SmsService.sendSms(widget.phone, msg);
          Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=>LoginPage()));
        }
      else{
        Fluttertoast.showToast(msg: "Registration Failed");
      }

  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue[50],
      appBar: AppBar(
        title: const Text('Enter Info', style: TextStyle(color: Colors.white)),
        backgroundColor: const Color(0xFF24A1DE),
      ),
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            children: [
              _buildTextField(controller: TextEditingController(text: widget.phone), label: 'Phone Number', readOnly: true),
              SizedBox(height: 10,),
              _buildTextField(controller: _nameController, label: 'Name', focusNode: _nameFocusNode),
              SizedBox(height: 10,) ,
              _buildTextField(controller: _emailController, label: 'Email', keyboardType: TextInputType.emailAddress),
              SizedBox(height: 10,),
              _buildTextField(controller: _dairyController, label: 'Dairy Name'),
              SizedBox(height: 10,),
              _buildTextField(controller: _cityController, label: 'City/Village'),
              SizedBox(height: 10,),
              _buildTextField(controller: _subDistrictController, label: 'Taluka'),
              SizedBox(height: 10,),
              _buildTextField(controller: _districtController, label: 'District'),
              SizedBox(height: 10,),
              _buildTextField(controller: _stateController, label: 'State', onChanged: _updateStateSuggestion),
              SizedBox(height: 10,),
              _buildPasswordField(_passwordController, 'Password', _obscurePassword, () {
                setState(() {
                  _obscurePassword = !_obscurePassword;
                });
              }),
              _buildPasswordField(_confirmPasswordController, 'Confirm Password', _obscureConfirmPassword, () {
                setState(() {
                  _obscureConfirmPassword = !_obscureConfirmPassword;
                });
              }),
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: _validateAndProceed,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF24A1DE),
                  padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 10),
                ),
                child: const Text('Sign up', style: TextStyle(color: Colors.white, fontSize: 16)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    FocusNode? focusNode,
    bool readOnly = false,
    TextInputType keyboardType = TextInputType.text,
    Function(String)? onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: TextField(
        controller: controller,
        focusNode: focusNode, // 🔹 Added FocusNode support
        readOnly: readOnly,
        keyboardType: keyboardType,
        onChanged: onChanged,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          filled: true,
          fillColor: Colors.white,
        ),
      ),
    );
  }

  Widget _buildPasswordField(TextEditingController controller, String label, bool obscureText, VoidCallback toggleVisibility) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: TextField(
        controller: controller,
        obscureText: obscureText,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          filled: true,
          fillColor: Colors.white,
          suffixIcon: IconButton(
            icon: Icon(obscureText ? Icons.visibility_off : Icons.visibility, color: Colors.grey[700]),
            onPressed: toggleVisibility,
          ),
        ),
      ),
    );
  }
}
