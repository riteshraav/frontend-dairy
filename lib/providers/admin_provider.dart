import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/adapters.dart';
import '../model/admin.dart';

class AdminProvider with ChangeNotifier {
  late Box<Admin> _box;
  Admin _admin = Admin();

  Admin get admin => _admin;

  AdminProvider() {
    _init();
  }

  Future<void> _init() async {
    _box = Hive.box<Admin>('adminBox');
    _admin = _box.get('admin')!;

    // Listen for changes on 'currentAdmin'
    _box.listenable(keys: ['admin']).addListener(() {
      _admin = _box.get('admin')!;
      notifyListeners();
    });
  }

  Future<void> updateAdmin(Admin newAdmin) async {
    await _box.put('admin', newAdmin);
    // _admin will auto-update from the listener
  }
}
