
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import '../../model/admin.dart';
import '../../screens/auth_screens/login_screen.dart';
import '../../screens/auth_screens/otp_screen.dart';
import '../../service/admin_service.dart';
import '../../service/sms_service.dart';
import '../../widgets/appbar.dart';

class CheckPhonePage extends StatefulWidget {
   bool forgotPassword;
  CheckPhonePage(this.forgotPassword);
  @override
  _CheckPhonePageState createState() => _CheckPhonePageState();
}

class _CheckPhonePageState extends State<CheckPhonePage> {
  final TextEditingController _phoneController = TextEditingController();
  final FocusNode _phoneFocusNode = FocusNode();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  AdminService adminService = AdminService();
  Future<bool> checkAdmin()
  async {
      Admin userExist = await  adminService.loginUser(_phoneController.text);
      if(userExist.name != null)
      {
        return true;
      }
      else{
        return false;
      }
  }
  Future<String> sendOtp()
  async{
    var isDeviceConnected = await  CustomWidgets.internetConnection();
    if(!isDeviceConnected){
      CustomWidgets.showDialogueBox(context : context);
      return "";
    }
    String registerMsg = "\nYour Otp to register for binary solution dairy app is : ";
    String forgotMsg = "\nYour Otp to reset password for binary solution dairy app is : ";
    try{
      String otp = await SmsService.sendOtp(_phoneController.text, (widget.forgotPassword)? forgotMsg:registerMsg);
      if(otp.isNotEmpty)
      {
        return otp;
      }
      else{
        Fluttertoast.showToast(msg: "Error in sending otp");
        return "";
      }
    }
    catch (e)
    {
      Fluttertoast.showToast(msg: "Client execption");
      return "";
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: AppBar(
      //   title: const Text('Forgot Password', style: TextStyle(color: Colors.white)),
      //   backgroundColor: const Color(0xFF24A1DE),
      // ),
      appBar: CustomWidgets.buildAppBar("Signup Page"),
      backgroundColor: Colors.blue[50], // ✅ Restored original screen color
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ✅ Replacing New Binary Solutions logo & text with forgot_pass.png
            Center(
              child: Column(
                children: [
                  Image.asset('assets/forgot_pass.png', width: 150, height: 150), // ✅ Updated image
                  const SizedBox(height: 10),
                  const Text(
                    'Phone Verification', // ✅ Updated text
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF24A1DE),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30),

            Text(
              'Enter your phone number to receive OTP',
              style: TextStyle(fontSize: 16, color: Colors.grey[600]),
            ),
            const SizedBox(height: 20),

            TextField(
              controller: _phoneController,
              focusNode: _phoneFocusNode,
              keyboardType: TextInputType.phone,
              decoration: const InputDecoration(
                labelText: 'Phone Number',
                border: OutlineInputBorder(),
                filled: true,
                fillColor: Colors.white,
              ),
            ),
            const SizedBox(height: 20),

            Center(
              child: ElevatedButton(
                onPressed: () async {
                  if ( _phoneController.text.isEmpty) {
                    Fluttertoast.showToast(msg: "Please enter your phone number");
                  }
                  else if(!RegExp(r'^[0-9]{10}$').hasMatch(_phoneController.text))
                  {
                    Fluttertoast.showToast(msg: "Enter valid phone number");
                  }
                  else {
                    Admin userExist = await  adminService.loginUser(_phoneController.text);
                    if(widget.forgotPassword ){
                      if(userExist.name != null) {
                        showDialog(
                          context: context,
                          builder: (context)  {
                            return AlertDialog(
                              title: const Text('Confirmation'),
                              content: Text('We will send OTP to ${_phoneController.text}. Continue if the number is correct.'),
                              actions: [
                                TextButton(
                                  onPressed: () {
                                    Navigator.pop(context);
                                    _phoneFocusNode.requestFocus();
                                  },
                                  child: const Text('Edit Number', style: TextStyle(color: Colors.grey)),
                                ),
                                ElevatedButton(
                                  onPressed: () async {
                                    Navigator.pop(context);
                                    String otp = await sendOtp();
                                    if (otp.isNotEmpty)
                                      Navigator.pop(context);
                                    Navigator.push(context,
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                OtpVerificationPage(
                                                  phoneNumber: _phoneController
                                                      .text,
                                                  otp: "1234",
                                                  isForgotPassword: widget
                                                      .forgotPassword,)));
                                  },

                                  style: ElevatedButton.styleFrom(backgroundColor:Colors.black54, ),
                                  child: const Text('Confirm', style: TextStyle(color: Colors.white)),
                                ),
                              ],
                            );
                          },

                        );
                      }
                      else{
                        Fluttertoast.showToast(msg:
                        "User do not exist of this number");
                      }
                    }
                    else if(userExist.name != null){
                      Fluttertoast.showToast(msg:
                      "User already exist! You can login directly");
                    }
                    else{
                      showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: Text('Confirmation'),
                          content: Text(
                              'We will send Otp to ${_phoneController.text} for confirmation '
                                  'Continue if number is correct.'),
                          actions: [
                            TextButton(
                              onPressed: () {
                                Navigator.of(context)
                                    .pop(); // Dismiss dialog
                              },
                              child: Text('Edit Number'),
                            ),
                            OutlinedButton(
                              onPressed: () async {
                                String otp = await sendOtp();
                                  Navigator.pop(context);
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) =>
                                              OtpVerificationPage(
                                                phoneNumber:
                                                    _phoneController.text,
                                                otp: "1234",
                                                isForgotPassword: false,
                                              )));

                              },
                              child: Text('Confirm'),
                            ),
                          ],
                        ),
                      );
                    }
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF24A1DE),
                  padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                ),
                child: const Text('Send OTP', style: TextStyle(color: Colors.white)),
              ),
            ),
            const SizedBox(height: 20),

            Center(
              child: TextButton(
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => LoginPage()),
                  );
                },
                child: const Text(
                  'Back to Login',
                  style: TextStyle(color: Color(0xFF24A1DE), fontSize: 16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
