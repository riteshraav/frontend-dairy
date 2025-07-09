import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import '../../widgets/appbar.dart';
import '../../model/admin.dart';
import '../../service/admin_service.dart';
import 'login_screen.dart';

class ResetPassword extends StatefulWidget {
  final String phone;

  const ResetPassword( {super.key,required this.phone});

  @override
  State<ResetPassword> createState() => _ResetPasswordState();
}

class _ResetPasswordState extends State<ResetPassword> {
  TextEditingController _passwordController = TextEditingController();
  TextEditingController _nameController = TextEditingController();
  TextEditingController _confirmPasswordController = TextEditingController();
  bool _isPasswordVisible = false;
  AdminService adminService = AdminService();
  bool _isConfirmPasswordVisible = false;
  void updatePass () async{
    if( _passwordController.text.isEmpty ||_confirmPasswordController.text.isEmpty)
    {
      Fluttertoast.showToast(msg: "Enter all fields");
      return ;
    }
    else if(_passwordController.text != _confirmPasswordController.text)
    {
      Fluttertoast.showToast(msg: "password and confirm password are not matching");
    }
    else{
      final admin =  Admin(
          password: _passwordController.text,
          id: widget.phone,);
      bool? isRegisteredSuccessfully = await adminService.updateAdmin(admin);
      if(isRegisteredSuccessfully)
      {
        Fluttertoast.showToast(msg: "Password Updated successfully");
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=>LoginPage()));
      }
      else{
        Fluttertoast.showToast(msg: "Password update Failed");
      }
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomWidgets.buildAppBar("Reset Password"),
        body: Center(
            child: SingleChildScrollView(
                child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Reset Password',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF9D4EDD),
                            ),
                          ),
                          SizedBox(height: 16),
                          TextFormField(
                            controller: TextEditingController(
                                text: widget.phone),
                            enabled: false,
                            decoration: InputDecoration(
                              labelText: 'Phone Number',
                              border: OutlineInputBorder(),
                            ),
                          ),
                          SizedBox(height: 16),
                          TextField(
                            controller: _passwordController,
                            obscureText: !_isPasswordVisible,
                            decoration: InputDecoration(
                              labelText: 'Password',
                              border: OutlineInputBorder(),
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _isPasswordVisible
                                      ? Icons.visibility
                                      : Icons.visibility_off,
                                ),
                                onPressed: () {
                                  setState(() {
                                    _isPasswordVisible = !_isPasswordVisible;
                                  });
                                },
                              ),
                            ),
                          ),
                          SizedBox(height: 16),
                          TextField(
                            controller: _confirmPasswordController,
                            obscureText: !_isConfirmPasswordVisible,
                            decoration: InputDecoration(
                              labelText: 'Confirm Password',
                              border: OutlineInputBorder(),
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _isConfirmPasswordVisible
                                      ? Icons.visibility
                                      : Icons.visibility_off,
                                ),
                                onPressed: () {
                                  setState(() {
                                    _isConfirmPasswordVisible =
                                    !_isConfirmPasswordVisible;
                                  });
                                },
                              ),
                            ),
                          ),
                          SizedBox(height: 16),
                          OutlinedButton(
                            onPressed: () {
                              updatePass();
                            },
                            style: CustomWidgets.elevated(),
                            child: Text(
                              'Change Password',

                            ),
                          ),
                        ]
                    )
                )

            )
        )
    );
  }
}
