import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';

import '../../model/cattleFeedSell.dart';
import '../../service/cattleFeedSellService.dart';
import '../../widgets/appbar.dart';
import '../../model/admin.dart';
import '../../model/Customer.dart';
import 'cattleFeedSellScreen.dart';

class CattleFeedSellHistory extends StatefulWidget {
  const CattleFeedSellHistory({super.key});

  @override
  State<CattleFeedSellHistory> createState() => _CattleFeedSellHistoryState();
}

class _CattleFeedSellHistoryState extends State<CattleFeedSellHistory> {
  final TextEditingController _searchController = TextEditingController();
  List<CattleFeedSell> _sellList = [];
  List<CattleFeedSell> _filteredList = [];
  Admin _admin = CustomWidgets.currentAdmin();
  bool _isLoading = false;

  // Sort function - newest first
  List<CattleFeedSell> _sortByRecent(List<CattleFeedSell> sells) {
    return sells..sort((a, b) {
      final dateA = DateTime.parse(a.date!);
      final dateB = DateTime.parse(b.date!);
      return dateB.compareTo(dateA); // Descending order
    });
  }

  @override
  void initState() {
    super.initState();
    _loadData();
    _searchController.addListener(_filterSells);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      final sells = await CattleFeedSellService.getAllCattleFeedSellForAdmin(_admin.id!);
      setState(() {
        _sellList = _sortByRecent(sells);
        _filteredList = _sellList;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      Fluttertoast.showToast(msg: "Failed to load data: ${e.toString()}");
    }
  }

  void _filterSells() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredList = _sellList.where((sell) {
        return sell.customerId!.toLowerCase().contains(query) ||
            (CustomWidgets.searchCustomerName(sell.customerId!)?.toLowerCase().contains(query) ?? false);
      }).toList();
      // Maintain sorting after filtering
      _filteredList = _sortByRecent(_filteredList);
    });
  }

  Future<void> _deleteSell(CattleFeedSell sell) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Confirm Delete"),
        content: Text("Delete sell record for ${CustomWidgets.searchCustomerName(sell.customerId!)}?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("Cancel"),
          ),
          CustomWidgets.customButton(
            text: "Delete",
            onPressed: () async {
              print('delete button pressed in purchase screen');
              bool? deleted = await CattleFeedSellService.deleteCattleFeedSell(sell);
              if (deleted!) {
                setState(() {
                  _filteredList.remove(sell);
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

    if (confirmed == true) {
      setState(() => _isLoading = true);
      try {
        final success = await CattleFeedSellService.deleteCattleFeedSell(sell);
        if (success!) {
          await _loadData(); // Reload data which will maintain sorting
          Fluttertoast.showToast(msg: "Record deleted");
        } else {
          Fluttertoast.showToast(msg: "Deletion failed");
        }
      } catch (e) {
        Fluttertoast.showToast(msg: "Error: ${e.toString()}");
      } finally {
        if (mounted) setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomWidgets.buildAppBar("Cattle Feed Sell history", [
        IconButton(
          icon : const Icon(Icons.add),
          onPressed: ()=> Navigator.push(
            context,
            MaterialPageRoute(builder: (context)=> CattleFeedSellScreen(),
            ),
          ),
        ),
      ]),

      backgroundColor: Colors.blue[50],
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.white,
                labelText: 'Enter Customer Code',
                border: const OutlineInputBorder(),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    _searchController.clear();
                    _filterSells();
                  },
                )
                    : null,
              ),
            ),
          ),
          Expanded(
            child: Stack(
              children:[ SingleChildScrollView(
                scrollDirection: Axis.vertical,
                    child: SingleChildScrollView(
                                  scrollDirection: Axis.horizontal,
                                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: DataTable(
                      columnSpacing: 8,
                      headingRowHeight: 45,
                      border: TableBorder.all(),
                      headingRowColor: WidgetStateProperty.all(const Color(0xFF24A1DE)),
                      columns: const [
                        DataColumn(label: Text("Date", style: TextStyle(color: Colors.white))),
                        DataColumn(label: Text("Code", style: TextStyle(color: Colors.white))),
                        DataColumn(label: Text("Feed", style: TextStyle(color: Colors.white))),
                        DataColumn(label: Text("Qty", style: TextStyle(color: Colors.white))),
                        DataColumn(label: Text("Amount", style: TextStyle(color: Colors.white))),
                        DataColumn(label: Text("Payment", style: TextStyle(color: Colors.white))),
                        DataColumn(label: Text("Delete", style: TextStyle(color: Colors.white))),
                      ],
                      rows: _filteredList.map((sell) {
                        return DataRow(
                          color: WidgetStateProperty.resolveWith<Color?>(
                                (Set<WidgetState> states) => Colors.white,
                          ),
                          cells: [
                            DataCell(Text(DateFormat('dd/MM/yy').format(DateTime.parse(sell.date!)))),
                            DataCell(
                              Text(sell.customerId ?? ""),
                            ),
                            DataCell(Text(sell.feedName ?? "")),
                            DataCell(Text(sell.quantity.toString())),
                            DataCell(Text(sell.totalAmount!.toStringAsFixed(2))),
                            DataCell(Text(sell.modeOfPayback ?? "")),
                            DataCell(
                              IconButton(
                                icon: const Icon(Icons.delete, color: Colors.blue),
                                onPressed: () => _deleteSell(sell),
                              ),
                            ),
                          ],
                        );
                      }).toList(),
                    ),
                                  ),
                                ),
                  ),
                if (_isLoading)
                  Positioned.fill(
                    child: Container(
                      color: Colors.black.withOpacity(0.3),
                      child: Center(child: CircularProgressIndicator()),
                    ),
                  ),
              ]
            ),
          ),
        ],
      ),
    );
  }
}