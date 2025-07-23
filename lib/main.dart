
import 'package:DairySpace/providers/admin_provider.dart';
import 'package:DairySpace/providers/avatar_provider.dart';
import 'package:DairySpace/providers/customers_provider.dart';
import 'package:DairySpace/providers/quantity_provider.dart';
import 'package:DairySpace/screens/splash_screen.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:provider/provider.dart';


import 'model/Customer.dart';
import 'model/admin.dart';
import 'model/advancecustomerinfo.dart';
import 'model/advanceorganizationinfo.dart';
import 'model/buffalo_rate_data.dart';
import 'model/cattleFeedSupplier.dart';
import 'model/cow_rate_data.dart';
import 'model/customerqueue.dart';
import 'model/loancustomerinfo.dart';
import 'providers/buffalo_ratechart_provider.dart';
import 'providers/cow_ratechart_provider.dart';

import 'model/cattleFeedSupplierQueue.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  await Hive.initFlutter();
  Hive.registerAdapter(AdminAdapter());
  Hive.registerAdapter(CustomerAdapter());
  Hive.registerAdapter(CustomerQueueAdapter());
  Hive.registerAdapter(CattleFeedSupplierAdapter());
  Hive.registerAdapter(CattleFeedSupplierQueueAdapter());
  Hive.registerAdapter(AdvanceEntryAdapter());
  Hive.registerAdapter(AdvanceOrganizationAdapter());
  Hive.registerAdapter(LoanEntryAdapter());


  await Hive.openBox<Admin>('adminBox');
  await Hive.openBox<List<Customer>>('customerBox');
  await Hive.openBox<Map<String,List<dynamic>>>('customerQueueBox');
  await Hive.openBox<List<CattleFeedSupplier>>('cattleFeedSupplierBox');
  await Hive.openBox<Map<String,List<dynamic>>>('cattleFeedSupplierQueueBox');
  await Hive.openBox<List<AdvanceEntry>>('advanceBox');
  await Hive.openBox<List<AdvanceOrganization>>('advanceOrganizationBox');
  await Hive.openBox<List<LoanEntry>>('loanEntryBox');
  
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => CowRateChartProvider()),
        ChangeNotifierProvider(create: (context) => BuffaloRatechartProvider()),
        ChangeNotifierProvider(create: (_) => AdminProvider()),
        ChangeNotifierProvider(create: (_) => AvatarProvider()),
        ChangeNotifierProvider(create: (_)=>CustomerProvider()),
        ChangeNotifierProvider(create: (_)=>QuantityProvider())
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Login Page',
        theme: ThemeData(
          primaryColor: Color(0xFF9D4EDD),
        ),
        home: SplashScreen(),
      ),
    );
  }
}

