import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'package:provider/provider.dart';
import '../providers/buffalo_ratechart_provider.dart';
import '../providers/cow_ratechart_provider.dart';
import '../widgets/appbar.dart';
import 'excel_viewer.dart';


class UpdateRatechart extends StatefulWidget {
  const UpdateRatechart({super.key});

  @override
  State<UpdateRatechart> createState() => _UpdateRatechartState();
}


class _UpdateRatechartState extends State<UpdateRatechart> {
  int _selectedIndex = 0;
  // Controllers for Cow Inputs
  final TextEditingController minimumCowFatController = TextEditingController();
  final TextEditingController minimumCowSNFController = TextEditingController();
  final TextEditingController maximumCowFatController = TextEditingController();
  final TextEditingController maximumCowSNFController = TextEditingController();
  final TextEditingController minimumCowRateController = TextEditingController();
  final TextEditingController maximumCowRateController = TextEditingController();

  // Controllers for Buffalo Inputs
  final TextEditingController minimumBuffaloFatController = TextEditingController();
  final TextEditingController minimumBuffaloSNFController = TextEditingController();
  final TextEditingController maximumBuffaloFatController = TextEditingController();
  final TextEditingController maximumBuffaloSNFController = TextEditingController();
  final TextEditingController minimumBuffaloRateController = TextEditingController();
  final TextEditingController maximumBuffaloRateController = TextEditingController();

  FocusNode minimumCowFatFocusNode = FocusNode();
  FocusNode minimumCowSNFFocusNode = FocusNode();
  FocusNode maximumCowFatFocusNode = FocusNode();
  FocusNode maximumCowSNFFocusNode = FocusNode();
  FocusNode minimumCowRateFocusNode = FocusNode();
  FocusNode maximumCowRateFocusNode = FocusNode();
  FocusNode minimumBuffaloFatFocusNode = FocusNode();
  FocusNode minimumBuffaloSNFFocusNode = FocusNode();
  FocusNode maximumBuffaloFatFocusNode = FocusNode();
  FocusNode maximumBuffaloSNFFocusNode = FocusNode();
  FocusNode minimumBuffaloRateFocusNode = FocusNode();
  FocusNode maximumBuffaloRateFocusNode = FocusNode();
  FocusNode saveCowFocusNode = FocusNode();
  FocusNode saveBuffaloFocusNode = FocusNode();

  dynamic textToDouble(String text) {
    try {
      double result = double.parse(text);
      return result;
    } catch (e) {
      return "";
    }
  }

  bool checkDoubleValue(TextEditingController controller) {
    final text = controller.text;
    return RegExp(r'^\d+\.\d{1}\$').hasMatch(text);
  }

  bool checkDoubleValueForRate(TextEditingController controller) {
    final text = controller.text;
    return RegExp(r'^\d+\.\d{2}\$').hasMatch(text);
  }

  void addListener(TextEditingController controller, FocusNode focusNode) {
    return controller.addListener(() {
      if (checkDoubleValue(controller)) {
        FocusScope.of(context).requestFocus(focusNode);
      }
    });
  }

  void addListenerForRate(TextEditingController controller, FocusNode focusNode) {
    return controller.addListener(() {
      if (checkDoubleValueForRate(controller)) {
        FocusScope.of(context).requestFocus(focusNode);
      }
    });
  }

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      final buffaloList = Provider.of<BuffaloRatechartProvider>(context, listen: false).getBuffaloValues();
      final cowList = Provider.of<CowRateChartProvider>(context, listen: false).getCowValues();
      setState(() {
        minimumBuffaloFatController.text = buffaloList[0].toString();
        minimumBuffaloSNFController.text = buffaloList[1].toString();
        minimumBuffaloRateController.text = buffaloList[2].toString();
        maximumBuffaloFatController.text = buffaloList[3].toString();
        maximumBuffaloSNFController.text = buffaloList[4].toString();
        maximumBuffaloRateController.text = buffaloList[5].toString();
        minimumCowFatController.text = cowList[0].toString();
        minimumCowSNFController.text = cowList[1].toString();
        minimumCowRateController.text = cowList[2].toString();
        maximumCowFatController.text = cowList[3].toString();
        maximumCowSNFController.text = cowList[4].toString();
        maximumCowRateController.text = cowList[5].toString();
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> screens = [
      SingleChildScrollView(
        child: Consumer<CowRateChartProvider>(
          builder: (context, rateChartModel, child) => Column(
            children: [
              Container(
                padding: EdgeInsets.all(10),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildRateChartSection<CowRateChartProvider>(
                      "Cow Rate Chart",
                      minimumCowFatController,
                      minimumCowSNFController,
                      maximumCowFatController,
                      maximumCowSNFController,
                      minimumCowRateController,
                      maximumCowRateController,
                      minimumCowFatFocusNode,
                      minimumCowSNFFocusNode,
                      minimumCowRateFocusNode,
                      maximumCowFatFocusNode,
                      maximumCowSNFFocusNode,
                      maximumCowRateFocusNode,
                      saveCowFocusNode,
                    ),
                    SizedBox(height: 20),
                    CustomWidgets.customButton(text: "save", onPressed: () {
                      rateChartModel.setValues(
                        minimumCowFatController.text == "" ? "" : textToDouble(minimumCowFatController.text),
                        textToDouble(minimumCowSNFController.text),
                        textToDouble(minimumCowRateController.text),
                        textToDouble(maximumCowFatController.text),
                        textToDouble(maximumCowSNFController.text),
                        textToDouble(maximumCowRateController.text),
                      );
                      Fluttertoast.showToast(msg: "saved",backgroundColor: Colors.green);
                    })
                  ],
                ),
              ),
              Divider(),
              Center(
                child: Text(
                  rateChartModel.filePicked ? "Rate chart for cow is uploaded" : "RateChart for cow is not uploaded",
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
              ),
              SizedBox(height: 20),
              Column(
                children: [
                  CustomWidgets.customButton(text: "Upload Rate chart", onPressed: (){
                    rateChartModel.pickExcelFile();
                  }),
                  SizedBox(height: 10),
                  CustomWidgets.customButton(text: "Open File", onPressed: () {
                    // TODO: Add logic to open the file if needed
                    if(rateChartModel.filePicked) {
                      Navigator.push(context, MaterialPageRoute(builder: (
                          context) => ExcelViewer('cow')));
                    }
                    else{
                      Fluttertoast.showToast(msg: "Upload rate chart first");
                    }
                  }),
                ],
              ),
            ],
          ),
        ),
      ),
      SingleChildScrollView(
        child: Consumer<BuffaloRatechartProvider>(
          builder: (context, rateChartModel, child) => Column(
            children: [
              Container(
                padding: EdgeInsets.all(10),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildRateChartSection<BuffaloRatechartProvider>(
                      "Buffalo Rate Chart",
                      minimumBuffaloFatController,
                      minimumBuffaloSNFController,
                      maximumBuffaloFatController,
                      maximumBuffaloSNFController,
                      minimumBuffaloRateController,
                      maximumBuffaloRateController,
                      minimumBuffaloFatFocusNode,
                      minimumBuffaloSNFFocusNode,
                      minimumBuffaloRateFocusNode,
                      maximumBuffaloFatFocusNode,
                      maximumBuffaloSNFFocusNode,
                      maximumBuffaloRateFocusNode,
                      saveBuffaloFocusNode,
                    ),
                    SizedBox(height: 20),
                    CustomWidgets.customButton(text: "save", onPressed: () {
                      rateChartModel.setValues(
                        textToDouble(minimumBuffaloFatController.text),
                        textToDouble(minimumBuffaloSNFController.text),
                        textToDouble(minimumBuffaloRateController.text),
                        textToDouble(maximumBuffaloFatController.text),
                        textToDouble(maximumBuffaloSNFController.text),
                        textToDouble(maximumBuffaloRateController.text),
                      );
                      Fluttertoast.showToast(msg: "saved",backgroundColor: Colors.green);
                    }),
                  ],
                ),
              ),
              Divider(),
              Center(
                child: Text(
                  rateChartModel.filePicked ? "Rate chart for buffalo is uploaded" : "RateChart for buffalo is not uploaded",
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
              ),
              SizedBox(height: 20),
              Column(
                children: [
                  CustomWidgets.customButton(text: "Upload rate chart", onPressed: rateChartModel.pickExcelFile),
                  SizedBox(height: 10),
                  CustomWidgets.customButton(text: "Open File", onPressed: () {
                    // TODO: Add logic to open the file if needed
                    if(rateChartModel.filePicked)
                      {
                        Navigator.push(context, MaterialPageRoute(builder: (context) => ExcelViewer('buffalo')));
                      }
                    else{
                      Fluttertoast.showToast(msg: "Upload file first");
                    }

                  }),

                ],
              ),
            ],
          ),
        ),
      ),
    ];
    return Scaffold(
      appBar: CustomWidgets.buildAppBar('Update RateChart'),
      body: screens[_selectedIndex],
      backgroundColor: Colors.blue[50],
      bottomNavigationBar: Container(
        color: Colors.blue[50],
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
          child: GNav(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            tabBorder: Border.all(),
            gap: 8,
            color: Colors.grey,
            iconSize: 30,
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 5),
            tabBackgroundColor: Colors.white,
            tabs: [
              GButton(
                icon: Icons.pets,
                text: 'Cow',
                iconSize: 40,
                leading: Image.asset("assets/cow.png", height: 40, width: 40),
              ),
              GButton(
                icon: Icons.agriculture,
                text: 'Buffalo',
                iconSize: 40,
                leading: Image.asset("assets/buffalo.png", height: 40, width: 40),
              ),
            ],
            selectedIndex: _selectedIndex,
            onTabChange: (index) {
              setState(() {
                _selectedIndex = index;
              });
            },
          ),
        ),
      ),
    );
  }

  Widget _buildRateChartSection<T>(
      String title,
      TextEditingController minFatController,
      TextEditingController minSNFController,
      TextEditingController maxFatController,
      TextEditingController maxSNFController,
      TextEditingController minRateController,
      TextEditingController maxRateController,
      FocusNode minFatFocusNode,
      FocusNode minSNFFocusNode,
      FocusNode minRateFocusNode,
      FocusNode maxFatFocusNode,
      FocusNode maxSNFFocusNode,
      FocusNode maxRateFocusNode,
      FocusNode saveFocusNode,
      ) {
    return Consumer<T>(
      builder: (context, rateChartProvider, child) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Text(
              title,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Container(
                  padding: EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    border: Border.all(),
                  ),
                  child: Column(
                    children: [
                      _buildTextField("Minimum Fat", minFatController, minFatFocusNode),
                      const SizedBox(height: 10),
                      _buildTextField("Minimum SNF", minSNFController, minSNFFocusNode),
                      const SizedBox(height: 10),
                      _buildTextField("Rate", minRateController, minRateFocusNode),
                    ],
                  ),
                ),
              ),
              Expanded(
                child: Container(
                  padding: EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    border: Border.all(),
                  ),
                  child: Column(
                    children: [
                      _buildTextField("Maximum Fat", maxFatController, maxFatFocusNode),
                      const SizedBox(height: 10),
                      _buildTextField("Maximum SNF", maxSNFController, maxSNFFocusNode),
                      const SizedBox(height: 10),
                      _buildTextField("Rate", maxRateController, maxRateFocusNode),
                    ],
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 10),
        ],
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller, FocusNode focusNode) {
    return TextField(
      focusNode: focusNode,
      controller: controller,
      keyboardType: TextInputType.numberWithOptions(decimal: true),
      decoration: InputDecoration(
        filled: true,
        fillColor: Colors.white,
        labelText: label,
        border: OutlineInputBorder(),
      ),
    );
  }
}

