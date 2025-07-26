// if (isLoading)
// Positioned.fill(
// child: Container(
// color: Colors.black.withOpacity(0.3),
// child: Center(child: CircularProgressIndicator()),
// ),
// ),
import 'package:DairySpace/providers/buffalo_ratechart_provider.dart';
import 'package:DairySpace/screens/auth_screens/login_screen.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../model/admin.dart';
import '../model/milk_collection.dart';
import '../providers/cow_ratechart_provider.dart';
import '../service/mik_collection_service.dart';
import '../widgets/appbar.dart';

import '../model/Customer.dart';

class TodaysCollectionScreen extends StatefulWidget {
  List<MilkCollection> currentCollection ;
  DateTime currentDate;
  TodaysCollectionScreen(this.currentCollection,this.currentDate);
  @override
  State<TodaysCollectionScreen> createState() => _TodaysCollectionScreenState();
}

class _TodaysCollectionScreenState extends State<TodaysCollectionScreen> {
  final DateTime today = DateTime.now();
  Admin admin = CustomWidgets.currentAdmin();
  late DateTime currentDate ;
  List<MilkCollection> currentDateCollection =[];
  bool isSearchLoading = false;
  final List<bool> _selectedTime = <bool>[true, false];
  final List<bool> _selectedMilkType = <bool>[true, false];
  bool isCowSelected = false;
  bool isBuffaloSelected = false;
  bool isMorningSelected = false;
  bool isEveningSelected = false;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    currentDateCollection.addAll(widget.currentCollection);
    currentDate =  widget.currentDate;
    sortList();
  }

  String extractDate(String date) {
    DateTime dateTime = DateTime.parse(date);
    return '${dateTime.day.toString().padLeft(2, '0')}/${dateTime.month.toString().padLeft(2, '0')}/${dateTime.year}';
  }

  void pickDate(BuildContext context, bool isFrom) async {
    DateTime? selectedDate = await showDatePicker(
      context: context,
      initialDate: currentDate,
      firstDate: DateTime(2000),
      lastDate: today,

      builder: (context, child) {
        return Theme(
          data: ThemeData.light().copyWith(
            primaryColor: Colors.deepPurple, // Changes header background color
            colorScheme: ColorScheme.light(primary: Color(0xFF24A1DE)), // Button colors
            buttonTheme: ButtonThemeData(textTheme: ButtonTextTheme.primary),
            dialogBackgroundColor: Colors.white, // Background color of the picker
            textTheme: TextTheme(
              bodyLarge: TextStyle(color: Colors.black), // General text color
              titleLarge: TextStyle(color: Colors.white), // Title text color
            ),
          ),
          child: child!,
        );
      },
    );
    if (selectedDate != null) {
      setState(() {
        currentDate = selectedDate;
      });
    }

  }
  void applyFiltersForMilkType()
  {
    List<MilkCollection> filteredList = [];

    setState(() {
      currentDateCollection.clear();
    });
    if(isBuffaloSelected && isCowSelected || (isBuffaloSelected == false && isCowSelected == false))
    {
      filteredList.addAll(widget.currentCollection);
      setState(() {
        currentDateCollection = filteredList;
      });
      print(filteredList.length);
      print(currentDateCollection.length);

      return;
    }
    if(isBuffaloSelected)
    {
      for(MilkCollection c in widget.currentCollection)
      {
        if(c.milkType == "buffalo") {
          filteredList.add(c);
        }
      }
      setState(() {
        currentDateCollection.addAll(filteredList);
      });
      return;
    }
    if(isCowSelected)
    {
      for(MilkCollection c in widget.currentCollection)
      {
        if(c.milkType == "cow") {
          filteredList.add(c);
        }
      }
      setState(() {
        currentDateCollection.addAll(filteredList);
      });
      return;
    }

  }
  void applyFiltersForTime()
  {


    if(isEveningSelected && isMorningSelected || (isEveningSelected == false && isMorningSelected == false))
    {
      return;
    }
    List<MilkCollection> filteredList = [...currentDateCollection];
    if(isEveningSelected)
    {
      for(MilkCollection c in widget.currentCollection)
      {
        if(c.time != "Evening") {
          filteredList.remove(c);
        }
      }
      setState(() {
        currentDateCollection = filteredList;
      });
      return;
    }
    if(isMorningSelected)
    {
      for(MilkCollection c in widget.currentCollection)
      {
        if(c.time != "Morning") {
          filteredList.remove(c);
        }
      }
      setState(() {
        currentDateCollection = filteredList;
      });
      return;
    }

  }

  void sortList(){
    currentDateCollection.sort((a,b)=>int.parse(a.customerId!).compareTo(int.parse(b.customerId!)));
  }

  void loadDataForCurrentDate()async{
    setState(() {
      isSearchLoading = true;
    });
    print(currentDate);
    String fromDate = DateTime(currentDate.year, currentDate.month, currentDate.day)
        .toIso8601String();

    String toDate = DateTime(currentDate.year, currentDate.month, currentDate.day)
        .add(Duration(days: 1))
        .subtract(Duration(milliseconds: 1))
        .toIso8601String();

    // List<MilkCollection> list = await MilkCollectionService.getAllForAdminWithFromAndTo(fromDate, toDate,admin.id! );
    List<MilkCollection>? list = await MilkCollectionService().getAllForAdminWithFromAndToAuth(fromDate, toDate,admin.id! );
    if(list == null)
    {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => LoginPage()),
            (route) => false, // Clears entire stack
      );
      return;
    }
    setState(() {
      widget.currentCollection.clear();
      widget.currentCollection.addAll(list);
      currentDateCollection.clear();
      currentDateCollection.addAll(list);
      isSearchLoading = false;
    });
    sortList();
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: CustomWidgets.buildAppBar("Collection History"),
      backgroundColor: Colors.blue[50],
      body: Padding(
        padding: const EdgeInsets.all(10.0),
        child: SingleChildScrollView(
          child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Card(
                    elevation: 10,
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              IconButton(onPressed: (){
                                setState(() {
                                  currentDate = currentDate.subtract(Duration(days: 1));
                                });
                              }, icon: Icon(Icons.arrow_back_ios)),
                              InkWell(
                                onTap: () => pickDate(context, false),
                                child: Container(
                                  width: 120, // Manually set width
                                  height: 40, // Reduce height
                                  padding: EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                                  decoration: BoxDecoration(
                                    border: Border.all(color: Colors.grey),
                                    borderRadius: BorderRadius.circular(6),
                                    color: Colors.grey[200],
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        extractDate(currentDate.toIso8601String()),
                                        style: TextStyle(fontSize: 20, color: Colors.black),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              IconButton(onPressed: (){

                                setState(() {
                                  if(currentDate.add(Duration(days: 1)).isBefore(today))
                                  {
                                    currentDate = currentDate.add(Duration(days: 1));
                                  }
                                  else {
                                    Fluttertoast.showToast(msg: "reached today");
                                  }
                                });
                              }, icon: Icon(Icons.arrow_forward_ios)),
                            ],
                          ),
                          CustomWidgets.buttonloader(isSearchLoading, loadDataForCurrentDate, "search")
                        ],
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 8,),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Text("Filters : ",style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),),
                    Container(

                      decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.all(Radius.circular(8))
                      ),
                      child: ToggleButtons(
                        onPressed: (int index) {
                          setState(() {
                            // The button that is tapped is set to true, and the others to false.
                            _selectedMilkType[index] =  !_selectedMilkType[index];
                            isBuffaloSelected = _selectedMilkType[0];
                            isCowSelected = _selectedMilkType[1];
                            // print("buffalo $isBuffaloSelected");
                            // print("coww $isCowSelected");
                            // print("morning $isMorningSelected");
                            // print("evening $isEveningSelected");
                            applyFiltersForMilkType();
                            applyFiltersForTime();
                            sortList();
                          });
                        },
                        borderRadius: const BorderRadius.all(Radius.circular(8)),
                        selectedBorderColor: Colors.black,
                        selectedColor: Colors.black,

                        fillColor: Colors.blue[100],
                        color: Colors.black,
                        isSelected: _selectedMilkType,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(left: 10,right: 10,),
                            child: Text("Buffalo"),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(left: 10,right: 10,),
                            child: Text("Cow"),
                          )
                        ],
                      ),
                    ),
                    Container(
                      decoration: BoxDecoration(

                          color: Colors.white,
                          borderRadius: BorderRadius.all(Radius.circular(8))
                      ),
                      child: ToggleButtons(
                        onPressed: (int index) {
                          setState(() {
                            _selectedTime[index] = !_selectedTime[index];
                            isMorningSelected = _selectedTime[0];
                            isEveningSelected = _selectedTime[1];
                            // print("buffalo $isBuffaloSelected");
                            // print("coww $isCowSelected");
                            // print("morning $isMorningSelected");
                            // print("evening $isEveningSelected");
                            applyFiltersForMilkType();
                            applyFiltersForTime();
                            sortList();
                          });
                        },
                        borderRadius: const BorderRadius.all(Radius.circular(8)),
                        selectedBorderColor: Colors.black,
                        selectedColor: Colors.black,
                        fillColor: Colors.blue[100],
                        color: Colors.black,
                        isSelected: _selectedTime,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(left: 10,right: 10,),
                            child: Text("Morning"),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(left: 10,right: 10,),
                            child: Text("Evening"),
                          )
                        ],
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 18,),
                currentDateCollection.isNotEmpty
                    ? _buildTable()
                    : Center(
                  child: Text(
                    "You have not made any collection current day",
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                  ),
                ),]
          ),
        ),
      ),
    );
  }
  void deleteCollection(MilkCollection collection)
  async{
    String? status = await MilkCollectionService().deleteCollection(collection.id!);
    Fluttertoast.showToast(msg: status??"Server Error");
    if(status == null)
    {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => LoginPage()),
            (route) => false, // Clears entire stack
      );
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error")));
      return;
    }
    if(status != "Unsuccessful")
    {
      currentDateCollection.remove(collection);
      if(collection.milkType == 'buffalo')
      {
        if(collection.time == 'Morning') {
          Provider.of<BuffaloRatechartProvider>(context, listen: false).morningBuffaloQuantity = Provider.of<BuffaloRatechartProvider>(context, listen: false).morningBuffaloQuantity  - collection.quantity!  ;
        }
        else{
          Provider.of<BuffaloRatechartProvider>(context, listen: false).eveningBuffaloQuantity = Provider.of<BuffaloRatechartProvider>(context, listen: false).eveningBuffaloQuantity  - collection.quantity!  ;

        }
      }
      else{
        if(collection.time == 'Morning') {
          Provider.of<CowRateChartProvider>(context, listen: false).morningCowQuantity = Provider.of<CowRateChartProvider>(context, listen: false).morningCowQuantity  - collection.quantity!  ;
        }
        else{
          Provider.of<CowRateChartProvider>(context, listen: false).eveningCowQuantity = Provider.of<CowRateChartProvider>(context, listen: false).eveningCowQuantity  - collection.quantity!  ;

        }
      }
      setState(() {
      });
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Changes saved!")));
    }


  }

  void _deleteCollectionDialog(MilkCollection collection){
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text("Save Confirmation"),
        content: Text("Are you sure you want to save the changes?"),
        actions: [
          TextButton(onPressed: () => Navigator.of(ctx).pop(), child: Text("Cancel")),
          CustomWidgets.customButton(text: "Delete", onPressed: () {
            Navigator.of(ctx).pop();
            deleteCollection(collection);
          }, buttonBackgroundColor: Colors.redAccent)

        ],
      ),
    );
  }
  String _getMilkType(Customer customer) {
    List<String> types = [];
    if (customer.buffalo!) types.add("Buffalo");
    if (customer.cow!) types.add("Cow");
    return types.join(", ");
  }

  Widget _buildTable() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: SingleChildScrollView(
            scrollDirection: Axis.vertical,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                headingRowColor: WidgetStateProperty.all(Colors.blue),
                border: TableBorder.all(),
                columnSpacing: 13,
                headingRowHeight: 30, // Match header height
                columns: _dataColumnWithoutDate(),
                rows: _dataRowsWithoutDate(),
              ),
            ),
          ),
        ),
      ],
    );
  }

// Columns excluding the Date column
  List<DataColumn> _dataColumnWithoutDate() {
    DateTime currentDate = DateTime.parse(currentDateCollection.first.date!);
    bool showDelete = currentDate.day == today.day  && currentDate.month == today.month && currentDate.year == today.year;
    return [
      DataColumn(label: Text('Code', style: TextStyle(fontWeight: FontWeight.bold,color: Colors.white))),
      DataColumn(label: Text('C/B', style: TextStyle(fontWeight: FontWeight.bold,color: Colors.white))),
      DataColumn(label: Text('M/E', style: TextStyle(fontWeight: FontWeight.bold,color: Colors.white))),
      DataColumn(label: Text('Qty', style: TextStyle(fontWeight: FontWeight.bold,color: Colors.white))),
      DataColumn(label: Text('Fat', style: TextStyle(fontWeight: FontWeight.bold,color: Colors.white))),
      DataColumn(label: Text('SNF', style: TextStyle(fontWeight: FontWeight.bold,color: Colors.white))),
      DataColumn(label: Text('Rate', style: TextStyle(fontWeight: FontWeight.bold,color: Colors.white))),
      DataColumn(label: Text('Total', style: TextStyle(fontWeight: FontWeight.bold,color: Colors.white))),
      if(showDelete)
        DataColumn(label: Text('Delete', style: TextStyle(fontWeight: FontWeight.bold,color: Colors.white))),
    ];
  }

// Rows excluding the Date column
  List<DataRow> _dataRowsWithoutDate() {
    DateTime currentDate = DateTime.parse(currentDateCollection.first.date!);
    bool showDelete = currentDate.day == today.day  && currentDate.month == today.month && currentDate.year == today.year;
    return  currentDateCollection.map((collection) {
      return DataRow(
          color: WidgetStateProperty.all(Colors.white),
          selected: true,
          cells: [
            DataCell(Text(collection.customerId!)),
            DataCell(Text((collection.milkType! =="buffalo")?"B":"C")),
            DataCell(Text((collection.time! == "Morning")?"M":"E")),
            DataCell(Text('${collection.quantity} ')),
            DataCell(Text('${collection.fat}')),
            DataCell(Text('${collection.snf}')),
            DataCell(Text('${collection.rate}')),
            DataCell(Text('${collection.totalValue}')),
            if(showDelete)
              DataCell(IconButton(icon: Icon(Icons.delete), onPressed: (){
                _deleteCollectionDialog(collection);
              },)),
          ]);
    }).toList();
  }
}



