import 'package:flutter/material.dart';
import 'package:take8/model/cattleFeedSupplier.dart';
import 'package:take8/screens/cattlefeed_screens/cattlefeed_purchase_history.dart';
import 'package:take8/screens/cattlefeed_screens/cattlefeed_sell_history.dart';
import 'package:take8/service/cattleFeedSupplierService.dart';
import '../../screens/cattlefeed_screens/addCattleFeedSupplier.dart';
import '../../screens/cattlefeed_screens/cattleFeedPurchaseScreen.dart';
import '../../screens/drawer_screens/new_custom_drawer.dart';

import '../../model/admin.dart';
import '../../model/cattleFeedPurchase.dart';
import '../../service/cattleFeedPurchaseService.dart';
import '../../widgets/appbar.dart';
import '../drawer_screens/drawer_screen.dart';
import 'cattleFeedSellScreen.dart';

class CattleFeedOptions extends StatelessWidget {
  Admin admin = CustomWidgets.currentAdmin();
  CattleFeedOptions({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomWidgets.buildAppBar('Cattle Feed Page'),
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
                  onTap: () {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => AddSupplierScreen()));
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        Icon(Icons.person_add, size: 50, color: Color(0xFF24A1DE)),
                        SizedBox(height: 10),
                        Text(
                          'Add Supplier',
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
                      Navigator.push(context, MaterialPageRoute(builder: (context) => CattleFeedPurchaseHistory()));
                    }
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        Image.asset("assets/sell.png", width: 80, height: 80,),
                        SizedBox(height: 10),
                        Text(
                          'Purchase Cattle Feed',
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
                      Navigator.push(context, MaterialPageRoute(builder: (context) => CattleFeedSellHistory()));
                    }
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        Image.asset("assets/purchase.png", width: 60, height: 60,),
                        SizedBox(height: 10),
                        Text(
                          'Sell Cattle Feed',
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
      ),
    );
  }
}
