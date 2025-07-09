import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_otp_text_field/flutter_otp_text_field.dart';
import 'package:fluttertoast/fluttertoast.dart';
import '../../screens/auth_screens/reset_password.dart';
import '../../service/sms_service.dart';
import '../../widgets/appbar.dart';

import 'admin_info.dart';

class OtpVerificationPage extends StatefulWidget {
  final String phoneNumber;
  String otp;
  bool isForgotPassword;

   OtpVerificationPage({Key? key, required this.phoneNumber,required this.otp,required this.isForgotPassword}) : super(key: key);

  @override
  _OtpVerificationPageState createState() => _OtpVerificationPageState();
}

class _OtpVerificationPageState extends State<OtpVerificationPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  late Timer _timer;
  int _countdown = 30;
  bool _isResendEnabled = false;
  final List<TextEditingController> _otpControllers =
  List.generate(4, (index) => TextEditingController());
  final List<FocusNode> _otpFocusNodes =
  List.generate(4, (index) => FocusNode());

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      FocusScope.of(context).requestFocus(_otpFocusNodes[0]);
    });
    _startCountdown();
  }



  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
  void _startCountdown() {
    _countdown = 30;
    _isResendEnabled = false;
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (_countdown > 0) {
          _countdown--;
        } else {
          _isResendEnabled = true;
          _timer.cancel();
        }
      });
    });
  }

  void _resendOtp() async{
    var isDeviceConnected = await  CustomWidgets.internetConnection();
    if(!isDeviceConnected){
      CustomWidgets.showDialogueBox(context : context);
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Resending OTP...")),
    );
    _startCountdown();
    String msg = "\nYour Otp to register for binary solution dairy app is : ";
    String otp = await SmsService.sendOtp(widget.phoneNumber,msg);
    if(otp.length == 4)
    {
      widget.otp = otp;
    }
    else{
      Fluttertoast.showToast(msg: "Error sending otp");
    }
  }
  void _verifyOtp() async {
    String otp = _otpControllers.map((controller) => controller.text).join();
    var isDeviceConnected = await  CustomWidgets.internetConnection();
    if(!isDeviceConnected){
      CustomWidgets.showDialogueBox(context : context);
      return;
    }
    if(otp == widget.otp)
    {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Phone number verified")));
      if(widget.isForgotPassword) {
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=>ResetPassword(phone: widget.phoneNumber,)));
      }
      else {
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=> AdminInfoScreen(widget.phoneNumber)));
      }
    }
    else{
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Wrong Otp,Re-Enter Otp"),));
    }

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue[50],
      appBar: AppBar(
        title: const Text('Verify OTP'),
        backgroundColor: const Color(0xFF24A1DE),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 50),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Center(
                child: Column(
                  children: [
                    Image.asset('assets/Enter OTP-bro.png', width: 150, height: 150), // ✅ OTP Image
                    const SizedBox(height: 10),
                  ],
                ),
              ),
              const SizedBox(height: 40),

              Text(
                'Enter OTP sent to ${widget.phoneNumber}',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[600],
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 30),
              // OTP Input Fields
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(4, (index) => _buildOtpBox(index)),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: _isResendEnabled ? _resendOtp : null,
                    child: Text(
                      "Resend OTP ${_isResendEnabled?"":"$_countdown"}",
                      style:  TextStyle(color: _isResendEnabled? Colors.blueAccent :Colors.blueGrey, fontSize: 16),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed:(){
                  _verifyOtp();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF24A1DE),
                  padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                ),
                child: const Text('Verify OTP', style: TextStyle(color: Colors.white)),
              ),


            ],
          ),
        ),
      ),
    );
  }
  Widget _buildOtpBox(int index) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: SizedBox(
        width: 50,
        child: TextField(
          controller: _otpControllers[index],
          focusNode: _otpFocusNodes[index],
          keyboardType: TextInputType.number,
          textAlign: TextAlign.center,
          maxLength: 1,
          decoration: const InputDecoration(
            counterText: "",
            border: OutlineInputBorder(),
            filled: true,
            fillColor: Colors.white,
          ),
          onChanged: (value) {
            if (value.isNotEmpty && index < 3) {
              FocusScope.of(context).requestFocus(_otpFocusNodes[index + 1]);
            }
            if (value.isEmpty && index > 0) {
              FocusScope.of(context).requestFocus(_otpFocusNodes[index - 1]);
            }
          },
        ),
      ),
    );
  }
}
