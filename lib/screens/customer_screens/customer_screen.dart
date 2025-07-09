import 'package:flutter/material.dart';
import '../../screens/customer_screens/add_customer.dart';
import '../../screens/customer_screens/search_customer.dart';
import '../../service/customer_service.dart';
import '../../widgets/appbar.dart';

import '../../model/Customer.dart';
import '../../model/admin.dart';
import '../drawer_screens/drawer_screen.dart';

class CustomerPage extends StatelessWidget {
  CustomerPage({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomWidgets.buildAppBar('Customer Page'),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Show Customers Card


            // Add Customer Card
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              child: InkWell(
                onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => AddCustomerPage(null)));

                },
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      Icon(Icons.person_add, size: 50, color: Color(0xFF24A1DE)),
                      SizedBox(height: 10),
                      Text(
                        'Add Customer',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            SizedBox(height: 16),

            // Search Customer Card
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              child: InkWell(
                onTap: () async{
                  var isDeviceConnected = await  CustomWidgets.internetConnection();
                  if(!isDeviceConnected){
                    CustomWidgets.showDialogueBox(context : context);
                    return;
                  }
                  else{
                    // List<Customer>list =[];
                    // try{
                    //   list  = await CustomerService.findAllCustomer(admin.id!);
                    //   if(list.isNotEmpty) {
                    //     list.sort((a, b) => int.parse(a.id!).compareTo(int.parse(b.id!)));
                    //   }
                    //
                    // }
                    // catch(e){
                    //   print(e.toString());
                    //   throw e;
                    // }

                    Navigator.push(context, MaterialPageRoute(builder: (context)=>SearchCustomerPage( agenda:"Search Customer",)));
                  }
                },
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      Icon(Icons.search, size: 50, color: Color(0xFF24A1DE)),
                      SizedBox(height: 10),
                      Text(
                        'Search Customer',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
