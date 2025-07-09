import 'package:flutter/material.dart';
import '../../screens/customer_screens/search_customer.dart';
import '../../screens/drawer_screens/new_custom_drawer.dart';
import '../../screens/generate_reports/aavak_report.dart';

import '../../model/admin.dart';
import '../../model/milk_collection.dart';
import '../../service/mik_collection_service.dart';
import '../../widgets/appbar.dart';
import '../drawer_screens/drawer_screen.dart';

class ReportGenerationPage extends StatelessWidget {
  Admin admin = CustomWidgets.currentAdmin();
  ReportGenerationPage({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomWidgets.buildAppBar('Reports'),
      drawer: NewCustomDrawer(),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                child: InkWell(
                  onTap: () async {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => ReportSpecificationsPage(title: 'Aavak Report', customerList: [],)));
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Aavak Report')),
                    );
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        Icon(Icons.recent_actors, size: 50, color: Color(0xFF24A1DE)),
                        SizedBox(height: 10),
                        Text(
                          'Aavak Report',
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
                      Navigator.push(context, MaterialPageRoute(builder: (context) => SearchCustomerPage(agenda: "Customer Bill",)));
                    }
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        Icon(Icons.receipt_long_sharp,size: 50, color: Color(0xFF24A1DE)),
                        SizedBox(height: 10),
                        Text(
                          'Billing Report',
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
                      Navigator.push(context, MaterialPageRoute(builder: (context) => ReportSpecificationsPage( title: "Summary Report", customerList: [],)));
                    }
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        Icon(Icons.receipt_rounded,size: 50, color: Color(0xFF24A1DE)),
                        SizedBox(height: 10),
                        Text(
                          'Summary Report',
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
                      Navigator.push(context, MaterialPageRoute(builder: (context) => SearchCustomerPage(agenda: "Customer Summary Report")));
                    }
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        Icon(Icons.people_alt_sharp,size: 50, color: Color(0xFF24A1DE)),
                        SizedBox(height: 10),
                        Text(
                          'Customer Summary Report',
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
                      Navigator.push(context, MaterialPageRoute(builder: (context) => SearchCustomerPage(agenda: "Ledger Report",)));
                    }
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        Icon(Icons.feed,size: 50, color: Color(0xFF24A1DE)),
                        SizedBox(height: 10),
                        Text(
                          'Ledger Report',
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
        
            ],
          ),
        ),
      ),
    );
  }

}
