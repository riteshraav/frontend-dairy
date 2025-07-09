import '../model/loancustomerinfo.dart';
import '../widgets/appbar.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
class LoanEntryService{
  static Future<bool> addLoanEntry(LoanEntry loanEntry)
  async{
    final url = Uri.parse("${CustomWidgets.getIp()}/loanEntry/add");
    final response = await http.post(url,
    headers: {"Content-Type":"application/json"},
    body: json.encode(loanEntry.toJson())
    );

    try{
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
  static Future<List<LoanEntry>> getAllLoanEntryForAdmin(String adminId)
  async{
    final url = Uri.parse("${CustomWidgets.getIp()}/loanEntry/getAllLoanEntryForAdmin/$adminId");
    final response = await http.get(url);
    if(response.statusCode == 200)
    {
      List<dynamic> jsonData = jsonDecode(response.body);
      print(jsonData);
      return jsonData.map((entry)=> LoanEntry.fromJson(entry)).toList();
    }

    else{
      return [];
    }
  }
  static Future<LoanEntry?> getLoanEntryForCustomer(String adminId,String customerId)
  async{
    final url = Uri.parse("${CustomWidgets.getIp()}/loanEntry/getForCustomer/$adminId/$customerId");
    final response = await http.get(url);
    if(response.statusCode == 200)
    {
      final jsonData = jsonDecode(response.body);
      print(jsonData);
      return LoanEntry.fromJson(jsonData);
    }

    else{
      return null;
    }
  }


  static Future<bool> deleteLoanEntry(LoanEntry loanEntry)
  async{
      final url = Uri.parse("${CustomWidgets.getIp()}/loanEntry/delete");
     try{
       final response = await http.delete(url,
       headers: {"Content-Type":"application/json"},
       body: json.encode(loanEntry.toJson()));
       if(response.statusCode == 200)
       {
         return true;
       }
       else{
         return false;
       }
     }
     catch (e)
    {
      print(e);
      return false;
    }
  }
}