import 'package:flutter/material.dart';
import 'dart:math';
class FilterScreen extends StatefulWidget {
  @override
  State<FilterScreen> createState() => _FilterScreenState();
}

class _FilterScreenState extends State<FilterScreen> {
  final List<String> collectionsDate = ["Last 10 days", "Last 11 days"];
  final List<String> milkType = ["Cow", "Buffalo", "Cow & Buffalo"];
  final List<String> timings = ["Morning", "Evening"];


  Map<String, bool> selectedFilters = {};
  String? selectedDate;

  @override
  void initState() {
    super.initState();
    for (var filter in [...milkType, ...timings]) {
      selectedFilters[filter] = false;
    }
  }

  void clearFilters() {
    setState(() {
      selectedDate = null;
      selectedFilters.updateAll((key, value) => false);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue[50],
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {},
        ),
        title: Text("All Filters"),
        actions: [
          TextButton(
            onPressed: clearFilters,
            child: Text("Clear All", style: TextStyle(color: Colors.blue)),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 20),
              if (selectedDate != null || selectedFilters.containsValue(true)) ...[
                Text(
                  "Selected Filters:",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    if (selectedDate != null)
                      Chip(
                        label: Text(selectedDate!),
                        deleteIcon: Icon(Icons.close),
                        onDeleted: () {
                          setState(() {
                            selectedDate = null;
                          });
                        },
                      ),
                    ...selectedFilters.entries
                        .where((entry) => entry.value)
                        .map(
                          (entry) => Chip(
                        label: Text(entry.key),
                        deleteIcon: Icon(Icons.close),
                        onDeleted: () {
                          setState(() {
                            selectedFilters[entry.key] = false;
                          });
                        },
                      ),
                    )
                        .toList(),
                  ],
                ),
                SizedBox(height: 16),
              ],
              _buildDateSection("Date", collectionsDate),
              _buildFilterSection("Milk Type", milkType),
              _buildFilterSection("Time", timings),
              SizedBox(height: 20),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  minimumSize: Size(double.infinity, 50),
                  backgroundColor: Colors.black12,
                ),
                onPressed: () {},
                child: Text(
                  "VIEW COLLECTION",
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }




  // **Method to allow single selection for Date**
  Widget _buildDateSection(String title, List<String> options) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: options
                .map(
                  (option) => ChoiceChip(
                label: Text(option),
                selected: selectedDate == option,
                onSelected: (bool selected) {
                  setState(() {
                    selectedDate = selected ? option : null;
                  });
                },
              ),
            )
                .toList(),
          ),
        ],
      ),
    );
  }

  // **Method to allow multiple selections for Milk Type and Time**
  Widget _buildFilterSection(String title, List<String> options) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: options
                .map(
                  (option) => FilterChip(
                label: Text(option),
                selected: selectedFilters[option] ?? false,
                onSelected: (bool selected) {
                  setState(() {
                    selectedFilters[option] = selected;
                  });
                },
              ),
            )
                .toList(),
          ),
        ],
      ),
    );
  }
}
