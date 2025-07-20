import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:take8/model/cattleFeedPurchase.dart';
import 'package:take8/service/cattleFeedPurchaseService.dart';
import '../../model/admin.dart';
import '../../widgets/appbar.dart';
import 'cattleFeedPurchaseScreen.dart';


class CattleFeedPurchaseHistory extends StatefulWidget {
  const CattleFeedPurchaseHistory({super.key});

  @override
  State<CattleFeedPurchaseHistory> createState() => _CattleFeedPurchaseHistoryState();
}

class _CattleFeedPurchaseHistoryState extends State<CattleFeedPurchaseHistory> {
  final TextEditingController _searchController = TextEditingController();
  List<CattleFeedPurchase> purchaseList = [];
  List<CattleFeedPurchase> filteredList = [];
  Admin admin = CustomWidgets.currentAdmin();
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    loadData();
    _searchController.addListener(_searchPurchase);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _searchPurchase() {
    if (_searchController.text.isNotEmpty) {
      List<CattleFeedPurchase> foundEntries = purchaseList
          .where((entry) => entry.code.toString().contains(_searchController.text.trim()))
          .toList();
      if (foundEntries.isNotEmpty) {
        setState(() {
          filteredList = foundEntries;
        });
      } else {
        Fluttertoast.showToast(msg: "No purchase found with ${_searchController.text}");
      }
    } else {
      setState(() {
        filteredList = purchaseList;
      });
    }
  }

  void _deletePurchase(CattleFeedPurchase entry) async {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        titlePadding: const EdgeInsets.all(15),
        contentPadding: const EdgeInsets.symmetric(horizontal: 10),
        actionsPadding: const EdgeInsets.only(bottom: 10, right: 10),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        title: const Text("Delete Purchase", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'This purchase will be permanently deleted:',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              ListTile(
                dense: true,
                leading: Text(
                  "Code: ${entry.code}",
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                ),
              ),
              ListTile(
                dense: true,
                leading: Text(
                  "Supplier: ${entry.supplier}",
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                ),
              ),
              ListTile(
                dense: true,
                leading: Text(
                  "Amount: ${entry.totalAmount}",
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            child: const Text("Cancel", style: TextStyle(color: Colors.grey)),
            onPressed: () => Navigator.pop(context),
          ),
          CustomWidgets.customButton(
            text: "Delete",
            onPressed: () async {
              print('delete button pressed in purchase screen');
              setState(() {
                isLoading = true;
              });
              bool? deleted = await CattleFeedPurchaseService.deletePurchase(entry);
              setState(() {
                isLoading = false;
              });
               if (deleted!) {
                setState(() {
                  filteredList.remove(entry);
                  purchaseList.remove(entry);
                });
                Fluttertoast.showToast(msg: "Deleted Successfully");
              } else {
                Fluttertoast.showToast(msg: "Error");
              }
              Navigator.pop(context);
            },
            buttonBackgroundColor: Colors.red,
          ),
        ],
      ),
    );
  }

  void loadData() async {

    try {
      setState(() => isLoading = true);

      purchaseList = await CattleFeedPurchaseService.getAllPurchasesForAdmin(admin.id!);
      purchaseList.sort((a, b) => a.code!.compareTo(b.code!));

      setState(() {
        filteredList = purchaseList;
        isLoading = false;
      });
    } catch (e) {
      setState(() => isLoading = false);
      Fluttertoast.showToast(msg: "Failed to load data: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomWidgets.buildAppBar("Cattle Feed Purchase History", [
        IconButton(
          icon: const Icon(Icons.add),
          onPressed: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => CattleFeedPurchaseScreen(),
            ),
          ),
        ),
      ]),
      backgroundColor: Colors.blue[50],
      body: isLoading
          ? const Center(
        child: CircularProgressIndicator(
          strokeWidth: 5,
          valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
        ),
      )
          : SingleChildScrollView(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  fillColor: Colors.white,
                  filled: true,
                  suffixIcon: _searchController.text.isNotEmpty
                      ? IconButton(
                    icon: const Icon(Icons.clear),
                    onPressed: () {
                      _searchController.clear();
                      setState(() {
                        filteredList = purchaseList;
                      });
                    },
                  )
                      : null,
                  labelText: 'Enter Purchase Code',
                  border: const OutlineInputBorder(),
                ),
              ),
            ),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: DataTable(
                  columnSpacing: 8,
                  headingRowHeight: 45,
                  border: TableBorder.all(),
                  headingRowColor: WidgetStateProperty.all(const Color(0xFF24A1DE)),
                  columns: const [
                    DataColumn(label: Text("Voucher", style: TextStyle(color: Colors.white))),
                    DataColumn(label: Text("Supplier", style: TextStyle(color: Colors.white))),
                    DataColumn(label: Text("Feed", style: TextStyle(color: Colors.white))),
                    DataColumn(label: Text("Qty", style: TextStyle(color: Colors.white))),
                    DataColumn(label: Text("Amount", style: TextStyle(color: Colors.white))),
                    DataColumn(label: Text("Payment", style: TextStyle(color: Colors.white))),
                    DataColumn(label: Text("Delete", style: TextStyle(color: Colors.white))),
                  ],
                  rows: List.generate(
                    filteredList.length,
                        (index) {
                      final entry = filteredList[index];
                      return DataRow(
                        color: WidgetStateProperty.resolveWith<Color?>(
                              (Set<WidgetState> states) => Colors.white,
                        ),
                        cells: [
                          DataCell(
                            Text(entry.code ?? ""),
                          ),
                          DataCell(Text(entry.supplier ?? "")),
                          DataCell(Text(entry.feedName ?? "")),
                          DataCell(Text(entry.quantity.toString())),
                          DataCell(Text(entry.totalAmount!.toStringAsFixed(2))),
                          DataCell(Text(entry.paymentMethod ?? "")),
                          DataCell(
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.blue),
                              onPressed: () => _deletePurchase(entry),
                            ),
                          ),
                        ],
                      );
                    },
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