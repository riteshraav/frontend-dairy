import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:provider/provider.dart';
import '../../main.dart';
import '../../model/Customer.dart';
import '../../screens/customer_screens/view_history.dart';
import '../../screens/generate_reports/aavak_report.dart';
import '../../service/customer_service.dart';
import '../../widgets/appbar.dart';
import '../../screens/drawer_screens/new_custom_drawer.dart';
import '../../model/admin.dart';
import '../../model/milk_collection.dart';
import '../../service/mik_collection_service.dart';
import 'add_customer.dart';

class SearchCustomerPage extends StatefulWidget {
  String agenda;
  SearchCustomerPage({super.key,required this.agenda});
  @override
  _SearchCustomerPageState createState() => _SearchCustomerPageState();
}

class _SearchCustomerPageState extends State<SearchCustomerPage> with TickerProviderStateMixin, RouteAware {
  final TextEditingController _searchController = TextEditingController();
  List<Customer> customers =[];
  List<Customer> store = [];
  List<Customer> selectedCustomers = [];
  bool isSelectionMode = false;
  int? selectedCardIndex;
  bool areAllSelected = false;
  Admin admin = CustomWidgets.currentAdmin();
  List<Widget> actions = [];
  List<Widget> initialActions = [];
  List<String> customerCodeList = [];
  String reportType = "";
  @override
  void initState() {
    super.initState();
    customers = CustomWidgets.allCustomers();
    store.addAll(customers);
    initialActions.add(IconButton(onPressed: (){
      if(isSelectionMode) {
        Navigator.push(context, MaterialPageRoute(builder: (context)=>ReportSpecificationsPage(title:widget.agenda , customerList: selectedCustomers,)));
      }
    }, icon: Icon(Icons.local_printshop_sharp)));
    if(widget.agenda == "Search Customer")
      {
        initialActions.add(Builder(
          builder: (context) {
            return IconButton(
              icon: Icon(Icons.more_vert), // Three dots icon
              onPressed: ( ) async {
                final RenderBox button = context.findRenderObject() as RenderBox;
                final Offset offset = button.localToGlobal(Offset.zero);
                await showMenu(
                  context: context,
                  position: RelativeRect.fromLTRB(
                    offset.dx, // X position of the button
                    offset.dy + button.size.height, // Below the button
                    offset.dx + button.size.width, // Align right
                    offset.dy + button.size.height + 100, // Prevent overflow
                  ),
                  items: [
                    PopupMenuItem(
                      onTap: ()=>{
                        reportOptions("Ledger Report")
                      },
                      child: Text("Ledger Report"),
                    ),
                    PopupMenuItem(
                      onTap: ()=>{
                        reportOptions("Customer Summary Report")
                      },
                      child: Text("Customer Summary Report"),
                    ),
                    PopupMenuItem(
                      onTap: ()=>{
                        reportOptions("Customer Bill Report")
                      },
                      child: Text("Customer Bill Report"),
                    ),
                  ],
                );
              },
            );
          },
        ),);
  }
  actions.addAll(initialActions);
    _searchController.addListener(_searchCustomer);
  }
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Subscribe to route observer
    routeObserver.subscribe(this, ModalRoute.of(context)!);
  }
  @override
  void dispose() {
    routeObserver.unsubscribe(this);
    super.dispose();
  }
  @override
  void didPopNext() {
    // Called when returning to this screen
    print("Returned to HomeScreen from another screen");
    // ✅ Call your desired method here
    customers = CustomWidgets.allCustomers();
    store.clear();
    store.addAll(customers);
    setState(() {

    });
  }
  void generateCustomerCodeList(){
    for(Customer c in selectedCustomers)
    {
      customerCodeList.add(c.code!);
    }
  }
  void _searchCustomer() {
    if (_searchController.text.isNotEmpty) {
      List<Customer> foundCustomer =
      CustomWidgets.searchCustomerById(_searchController.text.trim(), 'Code');
      if (foundCustomer.isNotEmpty) {
        setState(() {
          store = foundCustomer;
        });
      } else {
        CustomWidgets.showCustomSnackBar(
            "No customer found with ${_searchController.text}", context, 2);
      }
    } else {
     setState(() {
       store = customers;
     });
    }
  }
  void selectAll(){
    isSelectionMode = true;
    if(areAllSelected){
        selectedCustomers = customers;
    }
    else{
      _clearSelection();
    }
  }
  void _toggleSelection(Customer customer) {
    setState(() {
      if (selectedCustomers.contains(customer)) {
        selectedCustomers.remove(customer);
      } else {
        selectedCustomers.add(customer);
      }
      isSelectionMode = selectedCustomers.isNotEmpty;

    });
  }

  void _clearSelection() {
    setState(() {
      selectedCustomers = [];
      isSelectionMode = false;
    });
  }
  void reportOptions(String reportType){
      isSelectionMode = true;
      setState(() {
        widget.agenda = reportType;
      });
  }

  void deleteCustomers() async{
      generateCustomerCodeList();
    showDialog(
        context: context,
        builder: (context) => AlertDialog(
          titlePadding: EdgeInsets.all(15),
          contentPadding: EdgeInsets.symmetric(horizontal: 20),
          actionsPadding: EdgeInsets.only(bottom: 10, right: 10),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          title: Text("Confirmation", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          content: ConstrainedBox(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.6, // Limit height to 60% of screen
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('Do you really want to delete following customers:'),
                SizedBox(height: 10),
                Expanded( // Expanded is better inside Column to fill available space
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: selectedCustomers.length,
                    itemBuilder: (context, index) {
                      Customer c = selectedCustomers[index];
                      return ListTile(
                        dense: true,
                        title: Text(
                          "${c.code}-${c.name}",
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                        ),
                      );
                    },
                  ),
                ),

              ],
            ),
          ),
          actions: [
            TextButton(
              child: Text("Cancel", style: TextStyle(color: Colors.grey[700])),
              onPressed: () => Navigator.pop(context),
            ),
            CustomWidgets.customButton(text:  "Delete",onPressed:  () async {
              bool customerDeleted = await CustomerService.deleteCustomers(customerCodeList, admin.id!);
              if (customerDeleted) {
                for (Customer c in selectedCustomers) {
                  customers.remove(c);
                  selectedCustomers = [];
                }
                var customerBox = Hive.box<List<Customer>>('customerBox');
                customerBox.put('customers', customers);
              setState(() {
                store.clear();
                store.addAll(customers);
              });
                Fluttertoast.showToast(msg: "Deleted Successfully");
              } else {
                print("error in deleting customers");
                Fluttertoast.showToast(msg: "Error");
              }
              Navigator.pop(context);
            },buttonBackgroundColor:  Colors.red)
          ],
        ),
      );
  }

  AppBar buildAppBar()
  {
    if (isSelectionMode && (( widget.agenda == "Search Customer" && actions.length<3 ) ||( widget.agenda != "Search Customer" && actions.length<2 ) )) {
      actions.add( IconButton(
        icon: Icon(Icons.delete),
        onPressed: deleteCustomers
      ));
    }
    if(!isSelectionMode)
      {
        actions.clear();
        actions.addAll(initialActions);
      }
      return AppBar(
        actions: actions,
        leading: isSelectionMode
            ? IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            setState(() {
              actions = initialActions;
              selectedCustomers = [];
              areAllSelected = false;
              isSelectionMode = !isSelectionMode;
            });
          },
        )
            : null,
        iconTheme: const IconThemeData(color: Colors.white),
        title: Text(
          widget.agenda,
          style: const TextStyle(color: Colors.white),
        ),
        backgroundColor: const Color(0xFF24A1DE),
      );;
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue[50],
      drawer:(isSelectionMode)? null : NewCustomDrawer(),
      appBar: buildAppBar(),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              keyboardType: TextInputType.phone,
              controller: _searchController,
              decoration: InputDecoration(
                fillColor: Colors.white,
                filled: true,
                suffixIcon: (_searchController.text !="")?IconButton(onPressed: (){
                  _searchController.clear();
                }, icon: Icon(Icons.clear)):null,
                labelText: 'Enter Customer Code',
                border: const OutlineInputBorder(),

              ),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Text("${areAllSelected?"Deselect All":"Select All"}",),
              Checkbox(value: areAllSelected, onChanged:(value){
                setState(() {
                  areAllSelected = !areAllSelected;
                  selectAll();

                });
              }),
            ],
          ),
          Expanded(
            child: ListView.builder(
              itemCount: store.length,
              itemBuilder: (context, index) {
                final customer = store[index];
                final isSelected = selectedCustomers.contains(customer);
                final isExpanded = selectedCardIndex == index;

                return Card(

                  color: (selectedCardIndex == index) ? Colors.white54:null,
                  child: GestureDetector(
                    onLongPress: (){
                      _toggleSelection(customer);
                    },
                    child: AnimatedSize(
                      reverseDuration: Duration(milliseconds: 500),
                      duration: Duration(milliseconds: 500),
                      curve: Curves.easeInOut,
                      child: Column(
                        children: [
                          ListTile(
                            leading: isSelectionMode
                                ? Checkbox(
                              value: isSelected,
                              onChanged: (value) => _toggleSelection(customer),
                            )
                                : null,
                            title: Text('Code: ${customer.code}' ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Name: ${customer.name}'),
                                Text(
                                    '${customer.buffalo! ? 'Buffalo' : ''} ${customer.cow! ? 'Cow' : ''}'),
                                if (isExpanded)
                                  Padding(
                                    padding: const EdgeInsets.only(top: 10.0),
                                    child: SingleChildScrollView(
                                        child:  Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                                          children: [
                                            ElevatedButton(
                                              onPressed: () {
                                                Navigator.push(
                                                    context,
                                                    MaterialPageRoute(
                                                        builder: (context) =>
                                                            AddCustomerPage(
                                                                customer)));
                                              },
                                              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF24A1DE),),
                                              child: Text(
                                                'Edit' ,style: TextStyle(color: Colors.white),

                                              ),
                                            ),
                                            ElevatedButton(
                                              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF24A1DE),),
                                              onPressed: () async {
                                                var isDeviceConnected =
                                                await CustomWidgets
                                                    .internetConnection();
                                                if (!isDeviceConnected) {
                                                  CustomWidgets
                                                      .showDialogueBox(
                                                      context: context);
                                                  return;
                                                } else {

                                                  Navigator.push(
                                                      context,
                                                      MaterialPageRoute(
                                                          builder: (context) =>
                                                              CustomerMilkHistory(
                                                                customer:
                                                                customer,
                                                             )));

                                                }
                                              },
                                              child: Text('View History' , style: TextStyle(color: Colors.white),),
                                            ),
                                          ],
                                        )
                                    ),
                                  ),
                              ],
                            ),
                            onTap: isSelectionMode
                                ? () => _toggleSelection(customer)
                                : () {
                              setState(() {
                                selectedCardIndex =
                                selectedCardIndex == index ? null : index;
                              });
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
