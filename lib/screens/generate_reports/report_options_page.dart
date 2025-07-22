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
              _buildReportOptions(
                icon: Icons.recent_actors,
                title: 'Aavak Report',
                onTap: () {
                  Navigator.push(context, MaterialPageRoute(
                    builder: (context) => ReportSpecificationsPage(title: 'Aavak Report', customerList: []),
                  ));
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Aavak Report')));
                },
              ),
              SizedBox(height: 16),

              // Search Customer Card
              _buildReportOptions(
                icon: Icons.receipt_long_sharp,
                title: 'Billing Report',
                onTap: () async {
                  var isDeviceConnected = await CustomWidgets.internetConnection();
                  if (!isDeviceConnected) {
                    CustomWidgets.showDialogueBox(context: context);
                  } else {
                    Navigator.push(context, MaterialPageRoute(
                      builder: (context) => SearchCustomerPage(agenda: "Customer Bill"),
                    ));
                  }
                },
              ),              SizedBox(height: 16),
              _buildReportOptions(
                icon: Icons.receipt_rounded,
                title: 'Summary Report',
                onTap: () async {
                  var isDeviceConnected = await CustomWidgets.internetConnection();
                  if (!isDeviceConnected) {
                    CustomWidgets.showDialogueBox(context: context);
                    return;
                  }
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ReportSpecificationsPage(
                        title: "Summary Report",
                        customerList: [],
                      ),
                    ),
                  );
                },
              ),
              SizedBox(height: 16),
              _buildReportOptions(
                icon: Icons.people_alt_sharp,
                title: 'Customer Summary Report',
                onTap: () async {
                  var isDeviceConnected = await CustomWidgets.internetConnection();
                  if (!isDeviceConnected) {
                    CustomWidgets.showDialogueBox(context: context);
                    return;
                  }
                  Navigator.push(context, MaterialPageRoute(
                    builder: (context) => SearchCustomerPage(agenda: "Customer Summary Report"),
                  ));
                },
              ),
              SizedBox(height: 16),
              _buildReportOptions(
                icon: Icons.feed,
                title: 'Ledger Report',
                onTap: () async {
                  var isDeviceConnected = await CustomWidgets.internetConnection();
                  if (!isDeviceConnected) {
                    CustomWidgets.showDialogueBox(context: context);
                    return;
                  }
                  Navigator.push(context, MaterialPageRoute(
                    builder: (context) => SearchCustomerPage(agenda: "Ledger Report"),
                  ));
                },
              ),
              SizedBox(height: 16),
              _buildReportOptions(
                icon: Icons.document_scanner_outlined,
                title: 'Local sale Report',
                onTap: () async {
                  var isDeviceConnected = await CustomWidgets.internetConnection();
                  if (!isDeviceConnected) {
                    CustomWidgets.showDialogueBox(context: context);
                    return;
                  }
                  Navigator.push(context, MaterialPageRoute(
                    builder: (context) => SearchCustomerPage(agenda: "Local sale Report"),
                  ));
                },
              ),
              SizedBox(height: 16),

            ],
          ),
        ),
      ),
    );
  }
    Widget _buildReportOptions(
       {required IconData icon, required String title, required VoidCallback onTap})
    {
   return Card(
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                Icon(icon, size: 50, color: Color(0xFF24A1DE)),
                SizedBox(height: 10),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }
}


