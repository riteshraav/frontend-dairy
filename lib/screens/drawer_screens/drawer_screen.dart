import 'package:flutter/material.dart';
import 'package:take8/screens/customer_advance_history.dart';
import 'package:take8/screens/customer_loan_history.dart';
import '../../model/cattleFeedPurchase.dart';
import '../../model/cattleFeedSupplier.dart';
import '../../model/milk_collection.dart';
import '../../screens/advance_customer.dart';
import '../../screens/cattlefeed_screens/cattleFeedPurchaseScreen.dart';
import '../../screens/cattlefeed_screens/addCattleFeedSupplier.dart';
import '../../screens/cattlefeed_screens/cattleFeedSellScreen.dart';
import '../../screens/customer_screens/customer_screen.dart';
import '../../screens/auth_screens/login_screen.dart';
import '../../screens/generate_reports/aavak_report.dart';
import '../../screens/home_screen.dart';
import '../../screens/loan_customer.dart';
import '../../screens/milk_collection_page.dart';
import '../../screens/localMilkSalePage.dart';
import '../../screens/update_ratechart.dart';
import '../../service/cattleFeedPurchaseService.dart';
import '../../model/cattleFeedSell.dart';
import '../../model/Customer.dart';
import '../../model/admin.dart';
import '../../service/cattleFeedSupplierService.dart';
import '../../service/mik_collection_service.dart';
import '../../widgets/appbar.dart';
import '../advance_organization.dart';

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
