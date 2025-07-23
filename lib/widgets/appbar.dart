import 'dart:core';
import 'dart:io';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:hive/hive.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import '../model/admin.dart';
import '../model/Customer.dart';
import '../screens/auth_screens/login_screen.dart';
import '../service/admin_service.dart';
import '../service/customer_service.dart';

class CustomWidgets {
  static void logout(BuildContext context,[String msg = "Something went wrong"]){

    Fluttertoast.showToast(msg: msg);
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => LoginPage()),
          (route) => false, // Clears entire stack
    );
    return;
  }
  // Function to return the custom AppBar
  static Widget searchCustomer(BuildContext context,TextEditingController customerNameController,TextEditingController codeController,List<Customer> customerList)
  {
    return  Row(
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
              customerNameController.text = selection.name!;
              FocusScope.of(context).unfocus(); // Hide suggestions
            },
            fieldViewBuilder: (context, controller, focusNode, onEditingComplete) {
              codeController = controller;
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
                  .where((supplier) => supplier.name!.toLowerCase().contains(textEditingValue.text.toLowerCase()))
                  .toList();
            },
            displayStringForOption: (Customer option) => "${option.code!} - ${option.name!}",
            onSelected: (Customer selection) {
              codeController.text = selection.code!;
              customerNameController.text = selection.name!;
              FocusScope.of(context).unfocus(); // Hide suggestions
            },
            fieldViewBuilder: (context, controller, focusNode, onEditingComplete) {
              customerNameController = controller;
              return TextField(
                controller: controller,
                focusNode: focusNode,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.white,
                  labelText: "Supplier Name",
                  border: OutlineInputBorder(),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
  static Widget customButton({
    required String text,
    required void Function() onPressed,
    Color buttonBackgroundColor = const Color(0xFF24A1DE),
    FocusNode? focusNode,
  }){
    return ElevatedButton(
      onPressed: onPressed,
      focusNode: focusNode,
      style: ElevatedButton.styleFrom(backgroundColor:buttonBackgroundColor ),
      child:  Text(text, style: TextStyle(color: Colors.white)),
    );
  }

  static buttonloader(bool isLoading, VoidCallback onPressed, String label){
    return ElevatedButton(
      onPressed: isLoading? null :onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: Color(0xFF24A1DE)
      ),
      child: isLoading
        ? const SizedBox(
        width: 20,
        height: 20,
        child: CircularProgressIndicator(
          strokeWidth: 2,
          color: Colors.white,
        ),
      )
          : Text(label, style: TextStyle(color:Colors.white)),
    );
  }
  static String extractDate(dynamic date) {
    try {
      DateTime dateTime;
      if (date is String) {
        // Parse the string and handle invalid formats
        dateTime = DateTime.parse(date);
      } else if (date is DateTime) {
        dateTime = date;
      } else {
        throw FormatException("Unsupported date format");
      }
      // Format the date as day/month/year
      return '${dateTime.day.toString().padLeft(2, '0')}/'
          '${dateTime.month.toString().padLeft(2, '0')}/'
          '${dateTime.year}';
    } catch (e) {
      return "Invalid Date";
    }
  }
  static AppBar buildAppBar(String title, [List<Widget>? actions,Widget? leading]) {
    return AppBar(

      leading:leading ,
      actions: actions,
      iconTheme: const IconThemeData(color: Colors.white),
      title: Text(
        title,
        style: const TextStyle(color: Colors.white, fontSize: 21),
      ),
      backgroundColor: const Color(0xFF24A1DE),
    );
  }

  static ButtonStyle elevated() {
    return ElevatedButton.styleFrom(
   backgroundColor: const Color(0xFF24A1DE),
    );
  }
  // Show custom Snackbar
  static void showCustomSnackBar(String msg, BuildContext context, int duration) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        showCloseIcon: true,
        duration: Duration(seconds: duration),
      ),
    );
  }

 // Check internet connection
  static Future<bool> internetConnection() async {
    if (kIsWeb) {
      // For Web, assume online (or use a different approach)
      return true;
    } else {
      print("this is mobile");
      InternetConnectionChecker i = InternetConnectionChecker.createInstance();
      return await i.hasConnection;
    }
  }
  static Widget noInternetWidget(){
    return Container(
      width: double.infinity,
      color: Colors.red,
      padding: EdgeInsets.all(8),
      child: Text(
        "No Internet Connection",
        textAlign: TextAlign.center,
        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
      ),
    );
  }
  static Admin currentAdmin(){
    return  Hive.box<Admin>('adminBox').get('admin')!;
  }
  Admin currentAdminNonStatic(){
    return  Hive.box<Admin>('adminBox').get('admin')!;
  }
  static Widget buildInternetChecker(BuildContext context) {
    // return StreamBuilder<ConnectivityResult>(
    //   stream: Connectivity().onConnectivityChanged,
    //   builder: (context, snapshot)  {
    //     if (!snapshot.hasData || snapshot.data == ConnectivityResult.none) {
    //       return noInternetWidget();
    //     }
    return StreamBuilder<ConnectivityResult>(
      stream: Connectivity().onConnectivityChanged.map((results) =>
      results.isNotEmpty ? results.first : ConnectivityResult.none),
      builder: (context, snapshot) {
        if (!snapshot.hasData || snapshot.data == ConnectivityResult.none) {
          return noInternetWidget();
        }
        // Replace with your actual widget for internet connection



        var customerQueueBox = Hive.box<Map<String,List<dynamic>>>('customerQueueBox');
        Map<String,List<dynamic>> customerQueue = customerQueueBox.get('customerQueue')??{};
        for(String key in customerQueue.keys.toList())
        {
          List<dynamic> list = customerQueue[key]!;
          Customer customer = Customer(
              code: list[0],
              name: list[1],
              phone: list[2],
              buffalo: list[3],
              cow: list[4],
              adminId: list[5],
              classType: list[6],
              branchName: list[7],
              gender: list[8],
              caste: list[9],
              alternateNumber: list[10],
              email: list[11],
              accountNo: list[12],
              bankCode: list[13],
              sabhasadNo: list[14],
              bankBranchName: list[15],
              bankAccountNo: list[16],
              ifscNo: list[17],
              aadharNo: list[18],
              panNo: list[19],
              animalCount: list[20],
              averageMilk: list[21]

          );
          if (!snapshot.hasData || snapshot.data == ConnectivityResult.none) {
            customerQueueBox.put('customerQueue', customerQueue);
            return noInternetWidget();
          }
          try{
            CustomerService.updateCustomer(customer);
            customerQueue.remove(key);
          }
          catch(e){
            print(e);
          }
        }
        return SizedBox.shrink(); // Hide when connected
      },
    );
  }
  //strip for no internet connection
  // Show alert box for no internet
  static void showDialogueBox({required BuildContext context}) {
    showCupertinoDialog(
      context: context,
      builder: (BuildContext context) {
        return CupertinoAlertDialog(
          title: const Text("No Internet"),
          content: const Text("Please check your internet connection"),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text("OK"),
            ),
          ],
        );
      },
    );
  }

  // Get IP method (unchanged as requested)
  static String getIp() {
 //  return "https://backend-dairy-nefj.onrender.com";
 return "http://192.168.43.55:8080";
  }

  static Future<bool?> updateAdmin(Admin admin,BuildContext context) async{

   bool? adminUpdatedInDb = await AdminService().updateAdminAuth(admin);
    if(adminUpdatedInDb == null)
      {
        return null;
      }
    else if(adminUpdatedInDb == false){
      return false;
    }
    else{
      var adminBox = Hive.box<Admin>('adminBox');
      adminBox.put('admin', admin);
      return true;
    }
  }
  static String searchCustomerName(String customerId){
    List<Customer> customerList = allCustomers();
    for(Customer c in customerList){
      if(c.code == customerId)
        return c.name!;
    }
    return "";
  }
  // Convert customer code to customer ID
  static String customerCodeToCustomerId(int adminCode, String customerCode) {
    return adminCode.toString() + customerCode;
  }
  static List<Customer> allCustomers()
  {
    var customerBox = Hive.box<List<Customer>>('customerBox');
    List<Customer> customerList = customerBox.get('customers')??[];
    return customerList;
  }
  static List<Customer> searchCustomerById(String search,String modeOfSearch)
  {
    List<Customer> list = allCustomers();
    if(modeOfSearch == "Code") {
      for (Customer c in list) {
        if (c.code == search) return [c];
      }
      return [];
    }
    else{
      search = search.toUpperCase().trim();
      List<Customer> result =  list.where((customer) {
        if (customer.name == null) return false; // Handle null safety
        print(customer.name);
        List<String> nameParts = customer.name!.split(' '); // Split name into parts
        print(nameParts);
        return nameParts.any((part) {
          print(part);
          bool found = part.contains(modeOfSearch);

          return found;}); // Check if any part contains query
      }).toList();
      print(result);
      return result;
    }
  }

}

// Internet Speed Checker Class (Moved outside CustomWidgets)
class InternetSpeedChecker {
  // Check if the internet is slow
  static Future<bool> isInternetSlow() async {
    final stopwatch = Stopwatch()..start();

    try {
      final result = await InternetAddress.lookup('google.com');
      stopwatch.stop();

      if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
        final latency = stopwatch.elapsedMilliseconds;
        print("Latency: $latency ms");

        // Define slow internet if latency > 200ms
        return latency > 200;
      }
    } catch (e) {
      return true; // Assume slow internet if an error occurs
    }
    return true;
  }

  // Show an alert box for slow internet
  static void showSlowInternetDialog({required BuildContext context}) {
    showCupertinoDialog(

      context: context,
      builder: (BuildContext context) {
        return CupertinoAlertDialog(
          title: const Text("Slow Internet"),
          content: const Text("Your internet connection is slow. Please check your network."),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text("OK"),
            ),
          ],
        );
      },
    );
  }
}