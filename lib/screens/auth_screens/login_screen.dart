import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:hive/hive.dart';
import '../../model/Customer.dart';
import '../../model/admin.dart';
import '../../service/admin_service.dart';
import '../../service/customer_service.dart';
import '../../widgets/appbar.dart';
import '../home_screen.dart';
import '../milk_collection_page.dart';
import 'check_phone.dart';


class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool _isPasswordVisible = false;
  var adminService = AdminService();
  bool isLoading =false;
  void login() async {
    setState(() =>isLoading=true);

    var isDeviceConnected = await CustomWidgets.internetConnection();
    if (!isDeviceConnected) {
      CustomWidgets.showDialogueBox(context: context);
      setState(() =>isLoading =false);
      return;
    }
    if (_formKey.currentState!.validate()) {
      // Open Hive boxes for caching admin and customer data
      var adminBox = Hive.box<Admin>('adminBox');
      var customerBox = Hive.box<List<Customer>>('customerBox');

      //  Admin admin = await adminService.loginUser(_phoneController.text);
      Admin admin = Admin(password: _passwordController.text,id: _phoneController.text);
      String loginStatus;
      try{
         loginStatus  = await adminService.loginUserAuth(admin);
      }
      catch(e)
    {
      Fluttertoast.showToast(
            msg:"Error",
            timeInSecForIosWeb: 2);
        return;
    }
    finally{
      setState(() {
        isLoading = false;
      });
    }
      if (loginStatus != "Successful") {
        Fluttertoast.showToast(
            msg:loginStatus,
            timeInSecForIosWeb: 2);
      }
      else {
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (_)=>HomeScreen(true)));
        Fluttertoast.showToast(msg: "User logged in");
      }
      //admin =await adminService.loginUserAuth(_phoneController.text);
      // if (admin.name == "N/A") {
      //   Fluttertoast.showToast(
      //       msg: "User does not exist, sign up first and then log in",
      //       timeInSecForIosWeb: 2);
      // } else if (admin.password == _passwordController.text) {
      //   List<Customer>customerList =[];
      //   try{
      //     customerList  = await CustomerService.findAllCustomers(admin.id!);
      //     customerList.sort((a, b) => int.parse(a.code!).compareTo(int.parse(b.code!)));
      //
      //     // Store fetched admin and customer list into Hive for caching
      //     adminBox.put('admin', admin);
      //     customerBox.put('customers', customerList);
      //     // List<Customer>  c = customerBox.get('customers')??[];
      //     // c.forEach((a) => print(a.id));
      //
      //   }
      //   catch(e){
      //     setState(() =>isLoading =false);
      //     print(e.toString());
      //     throw e;
      //   }
      //   setState(() =>isLoading =false);
      //   Navigator.pushReplacement(context, MaterialPageRoute(builder: (_)=>HomeScreen()));
      //   Fluttertoast.showToast(msg: "User logged in");
      // } else {
      //   Fluttertoast.showToast(msg: "Invalid username or password");
      //   setState(() =>isLoading =false);
      // }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue[50],
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 50),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Logo and Title
                Center(
                  child: Column(
                    children: [
                      Image.asset('assets/logo.png', width: 100, height: 100),
                      const SizedBox(height: 10),
                      const Text(
                        'New Binary Solutions',
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

                const Text(
                  'Login to access your account',
                  style: TextStyle(color: Colors.grey),
                ),
                const SizedBox(height: 30),

                // Phone Number Field
                TextField(
                  controller: _phoneController,
                  keyboardType: TextInputType.phone,
                  decoration: const InputDecoration(
                    labelText: 'Phone Number',
                    border: OutlineInputBorder(),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                ),
                const SizedBox(height: 20),

                // Password Field
                TextFormField(
                  controller: _passwordController,
                  obscureText: !_isPasswordVisible,
                  decoration: InputDecoration(
                    suffixIcon: IconButton( // ✅ Moved inside InputDecoration
                      icon: Icon(
                        _isPasswordVisible ? Icons.visibility : Icons.visibility_off,
                      ),
                      onPressed: () {
                        setState(() {
                          _isPasswordVisible = !_isPasswordVisible;
                        });
                      },
                    ),
                    labelText: 'Password',
                    border: const OutlineInputBorder(),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                ),
                const SizedBox(height: 20),

                // Forgot Password & Login Button
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => CheckPhonePage(true)),
                        );
                      },

                      child: const Text(
                        'Forgot Password?',
                        style: TextStyle(color: Color(0xFF24A1DE)),
                      ),
                    ),
                  CustomWidgets.buttonloader( isLoading, login,'Login' ),
                  ],
                ),
                const SizedBox(height: 8),

                // Navigate to Signup Page
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      "Don't have an account? ",
                      style: TextStyle(color: Colors.grey),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => CheckPhonePage(false)),
                        );
                      },
                      child: const Text(
                        'Create',
                        style: TextStyle(color: Color(0xFF24A1DE)),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
