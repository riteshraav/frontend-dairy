import 'package:flutter/material.dart';
import '../../screens/home_screen.dart';

import '../../model/admin.dart';

import '../../widgets/appbar.dart';
import '../advance_organization.dart';
import '../customer_advance_history.dart';
import '../customer_loan_history.dart';

class CustomDrawer extends StatelessWidget {
  Admin admin = CustomWidgets.currentAdmin();
  CustomDrawer({super.key});
  DateTime nowTime = DateTime.now();
  String greeting(){
    int hour = DateTime.now().hour;
    String greetingMsg ;
    if(hour<12)
      greetingMsg= "Good Morning!";
    else if(hour < 17)
      greetingMsg = "Good Afternoon!";
    else{
      greetingMsg = "Good Evening!";
    }
    String result = "$greetingMsg \n${admin.name}..\n${admin.dairyName}";
    return result;
  }
  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          // Drawer Header
          DrawerHeader(
            decoration: BoxDecoration(
              color: Color(0xFF24A1DE), // Theme color
            ),
            child: Text(
              greeting(),
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
              ),
            ),
          ),
          // Home Option
          ListTile(
            leading: Icon(Icons.home_filled),
            title: Text('Home'),
            onTap: () {
              Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => HomeScreen(false)));
            },
          ),

          ListTile(
            leading: Icon(Icons.sell_rounded),
            title: Text('Advance'),
            onTap: ()async {
              Navigator.push(context, MaterialPageRoute(builder: (context) => CustomerAdvanceHistory()));

            },

          ),
          ListTile(
            leading: Icon(Icons.sell_rounded),
            title: Text('Advance organization'),
            onTap: ()async {
              Navigator.push(context, MaterialPageRoute(builder: (context) => OrganizationScreen()));

            },
          ),
          ListTile(
            leading: Icon(Icons.sell_rounded),
            title: Text('Customer Loan'),
            onTap: ()async {
              Navigator.push(context, MaterialPageRoute(builder: (context) => CustomerLoanHistory()));
            },
          ),


        ],
      ),
    );
  }
}
