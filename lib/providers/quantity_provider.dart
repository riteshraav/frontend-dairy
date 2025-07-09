import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class QuantityProvider extends ChangeNotifier {
  double _morningBuffaloQuantity = 0.0;
  double _morningCowQuantity = 0.0;
  double _eveningBuffaloQuantity = 0.0;
  double _eveningCowQuantity = 0.0;

  double get eveningBuffaloQuantity => _eveningBuffaloQuantity;
  double get morningBuffaloQuantity => _morningBuffaloQuantity;
  double get morningCowQuantity => _morningCowQuantity;
  double get eveningCowQuantity => _eveningCowQuantity;

  QuantityProvider() {
    _loadAndResetIfNeeded();
  }

  Future<void> _loadAndResetIfNeeded() async {
    final prefs = await SharedPreferences.getInstance();
    final now = DateTime.now();
    final todayString = "${now.year}-${now.month}-${now.day}";

    final lastResetDay = prefs.getString('lastResetDay');

    if (lastResetDay != todayString) {
      _morningBuffaloQuantity = 0.0; // Reset value
       _morningCowQuantity = 0.0;
       _eveningBuffaloQuantity = 0.0;
       _eveningCowQuantity = 0.0;
      await prefs.setString('lastResetDay', todayString);
    } else {
      _morningBuffaloQuantity = prefs.getDouble('morningBuffaloQuantity') ?? 0.0;
       _morningCowQuantity = prefs.getDouble('morningCowQuantity') ?? 0.0;
       _eveningBuffaloQuantity = prefs.getDouble('eveningBuffaloQuantity') ?? 0.0;
       _eveningCowQuantity = prefs.getDouble('eveningCowQuantity') ?? 0.0;
    }

    notifyListeners();
  }

  Future<void> updateMorningBuffaloQuantity(double newValue) async {
    _morningBuffaloQuantity += newValue;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('morningBuffaloQuantity', _morningBuffaloQuantity);
    notifyListeners();
  }
  Future<void> updateMorningCowQuantity(double newValue) async {
    _morningCowQuantity += newValue;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('morningCowQuantity', _morningCowQuantity);
    notifyListeners();
  }
  Future<void> updateEveningBuffaloQuantity(double newValue) async {
    _eveningBuffaloQuantity += newValue;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('eveningBuffaloQuantity', _eveningBuffaloQuantity);
    notifyListeners();
  }
  Future<void> updateEveningCowQuantity(double newValue) async {
    _eveningCowQuantity += newValue;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('eveningCowQuantity', _eveningCowQuantity);
    notifyListeners();
  }

}
