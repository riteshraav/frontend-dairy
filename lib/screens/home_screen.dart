import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:hive/hive.dart';
import 'package:provider/provider.dart';
import '../model/Customer.dart';
import '../model/admin.dart';
import '../model/buffalo_rate_data.dart';
import '../model/cattleFeedPurchase.dart';
import '../model/cow_rate_data.dart';
import '../providers/buffalo_ratechart_provider.dart';
import '../providers/cow_ratechart_provider.dart';
import 'auth_screens/login_screen.dart';
import 'cattlefeed_screens/cattleFeedSellScreen.dart';
import 'cattlefeed_screens/cattlefeed_options.dart';
import 'customer_advance_history.dart';
import 'customer_loan_history.dart';
import 'drawer_screens/contact_us_page.dart';
import 'customer_screens/add_customer.dart';
import 'customer_screens/customer_screen.dart';
import 'customer_screens/search_customer.dart';
import 'deduction_master.dart';
import 'drawer_screens/new_custom_drawer.dart';
import 'localMilkSalePage.dart';
import 'milk_collection_page.dart';
import 'drawer_screens/profile.dart';
import 'update_ratechart.dart';
import '../service/admin_service.dart';
import '../service/customer_service.dart';
import '../widgets/appbar.dart';
import 'advance_customer.dart';
import 'advance_organization.dart';
import 'generate_reports/report_options_page.dart';
import 'loan_customer.dart';

class HomeScreen extends StatefulWidget {
  bool isLoggedIn;
  HomeScreen(this.isLoggedIn);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool isLoading = false;
  final List<Map<String, dynamic>> services = [
    {
      "title": "Collection",
      "icon": 'assets/milk-can.png',
      "isImage": true,
      "route": MilkCollectionPage(),
      "color": Colors.lightBlueAccent
    },
    {
      "title": "Milk Sale",
      "icon": 'assets/milk-box.png',
      "isImage": true,
      "route": LocalMilkSalePage(),
      "color": Colors.greenAccent
    },
    {
      "title": "Deduction",
      "icon": 'assets/rupee.png',
      "isImage": true,
      "route": DeductionMasterScreen(),
      "color": Colors.orangeAccent
    },
    {
      "title": "Reports",
      "icon": 'assets/report.png',
      "isImage": true,
      "route": ReportGenerationPage(),
      "color": Colors.deepPurpleAccent
    },
    {
      "title": "Customer Master",
      "icon": 'assets/group.png',
      "isImage": true,
      "route": CustomerPage(),
      "color": Color(0xFFA47DAB)
    },
    {
      "title": "Rate Master",
      "icon": 'assets/rate.png',
      "isImage": true,
      "route": UpdateRatechart(),
      "color": Color(0xFFCF6DFC)
    },
    {
      "title": "Cattle Feed",
      "icon": 'assets/cattlefeed.png',
      "isImage": true,
      "route": CattleFeedOptions(),
      "color": Color(0xFF4272FF)
    },
    {
      "title": "Customer History",
      "icon": 'assets/history.png',
      "isImage": true,
      "route": SearchCustomerPage(agenda: "Search Customer"),
      "color": Color(0xFF6B403C)
    },
    {
      "title": "Advance",
      "icon": 'assets/advance.png',
      "isImage": true,
      "route": CustomerAdvanceHistory(),
      "color": Colors.redAccent
    },
    {
      "title": "Advance Organization",
      "icon": 'assets/advance organization.png',
      "isImage": true,
      "route": OrganizationScreen(),
      "color": Color(0xFFFFA896)
    },
    {
      "title": "Customer Loan",
      "icon": 'assets/customer loan.png',
      "isImage": true,

      "route": CustomerLoanHistory(),
      "color": Color(0xFF5C5C99)
    },
  ];

  @override
  void initState() {
    super.initState();
    if (widget.isLoggedIn) {
      loadData();
    }
  }

  void loadData() async {
    print("========== loadData START ==========");
    setState(() {
      isLoading = true;
    });

    // Step 1: Fetch Admin
    print("Fetching admin...");
    Admin? admin = await AdminService().searchAdminAuth();
    if (admin == null) {
      print("[ERROR] Admin is null!");
      Fluttertoast.showToast(msg: "Admin is null, redirecting to login.");
      setState(() {
        isLoading = false;
      });
      return;
    }
    print("Admin fetched: ${admin.id}, ${admin.name}");

    // Step 2: Open Hive Boxes
    print("Opening Hive boxes...");
    var adminBox = Hive.box<Admin>('adminBox');
    var customerBox = Hive.box<List<Customer>>('customerBox');
    var cowBox = Hive.box<CowRateData>('cowBox');
    var buffaloBox = Hive.box<BuffaloRateData>('buffaloBox');
    print("Hive boxes opened.");

    // Step 3: Fetch Customers
    print("Fetching customers...");
    List<Customer>? customerList = [];
    try {
      customerList = await CustomerService.findAllCustomersAuth();

      if (customerList == null || customerList.isEmpty) {
        print("[ERROR] Customer list is null or empty!");
        Fluttertoast.showToast(msg: "Customer list is null.");
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => LoginPage()),
              (route) => false,
        );
        setState(() {
          isLoading = false;
        });
        return;
      }

      print("Customer list fetched. Total: ${customerList.length}");
      int i = 0;
      for (var c in customerList) {
        print("Customer[$i]: Name=${c.name}, Code=${c.code}");
        i++;
      }

      print("Sorting customer list...");
      customerList.sort((a, b) => int.parse(a.code!).compareTo(int.parse(b.code!)));
      print("Customer list sorted.");

      // Step 4: Save to Hive
      print("Saving admin and customer list to Hive...");
      adminBox.put('admin', admin);
      customerBox.put('customers', customerList);
      print("Data saved to Hive successfully.");

      // Step 5: Cow Rate Data
      print("Fetching CowRateData from cowBox for adminId: ${admin.id}");
      CowRateData? cowRateData = cowBox.get('cowRateData_${admin.id}');
      if (cowRateData != null) {
        print('${cowRateData.filePicked} filepicked for cow for ${admin.id}');

        print("CowRateData found. Updating Provider...");
        Provider.of<CowRateChartProvider>(context, listen: false).updateAll(cowRateData);
      } else {
        print("[WARN] CowRateData not found for admin.");
      }

      // Step 6: Buffalo Rate Data
      print("Fetching BuffaloRateData from buffaloBox for adminId: ${admin.id}");
      BuffaloRateData? buffaloRateData = buffaloBox.get('buffaloRateData_${admin.id}');
      if (buffaloRateData != null) {
        print('${buffaloRateData.filePicked} filepicked for buffalo for ${admin.id}');

        print("BuffaloRateData found. Updating Provider...");
        Provider.of<BuffaloRatechartProvider>(context, listen: false).updateAll(buffaloRateData);
      } else {
        print("[WARN] BuffaloRateData not found for admin.");
      }

    } catch (e, stacktrace) {
      print("[EXCEPTION] in loadData: $e");
      print("Stacktrace:\n$stacktrace");
    } finally {
      print("========== loadData END ==========");
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomWidgets.buildAppBar("New Binary Solution"),
      drawer: NewCustomDrawer(),
      backgroundColor: Colors.blue[50],
      body: Stack(
        children:[ SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              children: [
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 1.5,
                    mainAxisSpacing: 8,
                    crossAxisSpacing: 8,
                  ),
                  itemCount: 4,
                  itemBuilder: (context, index) {
                    return InkWell(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => services[index]["route"]),
                        );
                      },
                      child: _buildServiceCard(
                        services[index]["title"],
                        services[index]["icon"],
                        services[index]["isImage"],
                        color: services[index]["color"],
                        isLarge: true,
                      ),
                    );
                  },
                ),
                const SizedBox(height: 25.0),
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 4,
                    childAspectRatio: 1.0,
                    mainAxisSpacing: 8,
                    crossAxisSpacing: 8,
                  ),
                  itemCount: services.length - 4,
                  itemBuilder: (context, index) {
                    return InkWell(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => services[index + 4]["route"]),
                        );
                      },
                      child: _buildServiceCard(
                        services[index + 4]["title"],
                        services[index + 4]["icon"],
                        services[index + 4]["isImage"],
                        color: services[index + 4]["color"],
                        isLarge: false,
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
          if (isLoading)
            Positioned.fill(
              child: Container(
                color: Colors.black.withOpacity(0.3),
                child: Center(child: CircularProgressIndicator()),
              ),
            ),
        ]
      ),
    );
  }

  Widget _buildServiceCard(
      String title,
      dynamic icon,
      bool isImage, {
        required bool isLarge,
        required Color color,
      }) {
    double iconSize = isLarge ? 65.0 : 32.0;
    double fontSize = isLarge ? 14.0 : 10.0;
    return Card(
      elevation: 7,
      color: color,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: Padding(
        padding: const EdgeInsets.all(6.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            isImage
                ? Image.asset(icon, width: iconSize, height: iconSize)
                : Icon(icon, size: iconSize),
            const SizedBox(height: 6.0),
            Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: fontSize,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}