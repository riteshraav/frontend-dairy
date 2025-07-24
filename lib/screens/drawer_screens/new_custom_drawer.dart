import 'package:DairySpace/providers/cow_ratechart_provider.dart';
import 'package:DairySpace/service/AdminAuthService.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:provider/provider.dart';
import '../../providers/admin_provider.dart';
import '../../providers/avatar_provider.dart';
import '../../providers/buffalo_ratechart_provider.dart';
import '../../screens/drawer_screens/profile.dart';
import '../../model/admin.dart';
import '../../widgets/privacypolicy.dart';
import '../auth_screens/login_screen.dart';
import '../home_screen.dart';
import 'contact_us_page.dart';

class NewCustomDrawer extends StatelessWidget {
   NewCustomDrawer({super.key});
  @override
  Widget build(BuildContext context) {
    final adminProvider = Provider.of<AdminProvider>(context);
    Admin? admin = adminProvider.admin;
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration:
            BoxDecoration(
              color: Color(0xFF24A1DE), // Theme color
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundImage: AssetImage(context.watch<AvatarProvider>().avatarPath),
                ),
                const SizedBox(height: 10),
                Text(admin.name!, style: TextStyle(color: Colors.white, fontSize: 25)),
              Text(admin.dairyName!, style: TextStyle(color: Colors.white70, fontSize: 20)),
              ],
            ),
          ),
          ListTile(
            leading: const Icon(Icons.home),
            title: const Text("Home"),
            onTap: () =>  Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(builder: (context) => HomeScreen(false)),
                  (route) => false, // Clears entire stack
            )
          ),
          ListTile(
            leading: const Icon(Icons.person),
            title: const Text("Profile"),
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => ProfileScreen())),
          ),
          ListTile(
            leading: const Icon(Icons.contact_page_outlined),
            title: const Text("Contact us"),
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => ContactProfilePage())),
          ),
          ListTile(
            leading: const Icon(Icons.privacy_tip),
            title: const Text("Privacy Policy"),
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => PrivacyPolicy())),
          ),
          const Divider(),
          ListTile(
            leading: Icon(Icons.exit_to_app, color: Colors.red),
            title: Text(
              'Log Out',
              style: TextStyle(
                color: Colors.red,
                fontWeight: FontWeight.bold,
              ),
            ),
            onTap: () {
              AdminAuthService().deleteTokens();
              Provider.of<BuffaloRatechartProvider>(context, listen: false).clearAllData();
              Provider.of<CowRateChartProvider>(context, listen: false).clearAllData();

              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (context) => LoginPage()),
                    (route) => false, // Clears entire stack
              );
            },
          ),
        ],
      ),
    );
  }
}
