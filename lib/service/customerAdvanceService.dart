import '../model/advancecustomerinfo.dart';
import '../widgets/appbar.dart';
import 'package:http/http.dart'as http;
import 'dart:convert';

class CustomerAdvanceService{
  static Future<bool> addCustomerAdvance(AdvanceEntry advanceEntry)
  async {
    final url = Uri.parse("${CustomWidgets.getIp()}/customerAdvance/add");
    try{
      final response = await http.post(url,
          headers: {"Content-Type":"application/json"},
          body: json.encode(advanceEntry.toJson()));
      if(response.statusCode == 200)
      {
        return true;
      }
      else{
        print("resonse ${response}");
        return false;
      }
    }
    catch(e){
      print(e);
      return false;

    }
  }
  static Future<List<AdvanceEntry>> getAllAdvanceForAdmin(String adminId)
  async{
    final url = Uri.parse("${CustomWidgets.getIp()}/customerAdvance/getAllAdvanceForAdmin/$adminId");
    final response = await http.get(url);
    if(response.statusCode == 200)
    {
      List<dynamic> jsonData = jsonDecode(response.body);
      print(jsonData);
      print("customer advance get is 200");
      return jsonData.map((entry)=> AdvanceEntry.fromJson(entry)).toList();
    }

    else{
      print("${response.statusCode} ${response.body} here is customer advance history get");
      return [];
    }
  }
  static Future<AdvanceEntry?> getForCustomer(String adminId,String customerId)
  async{
    final url = Uri.parse("${CustomWidgets.getIp()}/customerAdvance/getForCustomer/$adminId/$customerId");
    final response = await http.get(url);
    if(response.statusCode == 200)
    {
      final jsonData = jsonDecode(response.body);
      print(jsonData);
      return AdvanceEntry.fromJson(jsonData);
    }

    else{
      return null;
    }
  }
  static Future<bool> deleteAdvance(AdvanceEntry entry)
  async {
    final url = Uri.parse("${CustomWidgets.getIp()}/customerAdvance/delete");
   try{
     final response = await http.delete(url,
         headers: {"Content-Type":"application/json"},
         body: json.encode(entry.toJson()));
     if(response.statusCode == 200)
     {
       return true;
     }
     else {
       return false;
     }
   }
   catch(e)
    {
      print(e);
      return false;
    }
  }
}