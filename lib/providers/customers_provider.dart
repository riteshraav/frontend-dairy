import 'package:flutter/cupertino.dart';
import 'package:take8/widgets/appbar.dart';
import '../model/Customer.dart';

class CustomerProvider with ChangeNotifier{

   List<Customer> _customerList = [];
   List<Customer> get customerList => _customerList;

   CustomerProvider(){
    _init();
   }
   void _init(){
     _customerList = CustomWidgets.allCustomers();
     notifyListeners();
   }
   void addCustomer(Customer customer) {
     _customerList.add(customer);
     notifyListeners();
   }

   void removeCustomer(Customer customer) {
     _customerList.remove(customer);
     notifyListeners();
   }

   void updateCustomerList() {
     _customerList = CustomWidgets.allCustomers();
    notifyListeners();
   }

}