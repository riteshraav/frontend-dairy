import '../widgets/appbar.dart';
import 'package:http/http.dart' as http;
import '../model/localsale.dart';
import 'dart:convert';

class LocalMilkSaleService{
  static Future<String> addLocalMilkSale(LocalMilkSale localSale)
  async{
      final url = Uri.parse("${CustomWidgets.getIp()}/localSale/add");

      final response = await http.post(url,
      headers: {'Content-Type':"application/json"},
      body: json.encode(localSale.toJson()));

     try{
       if(response.statusCode == 200)
       {
         print('add local milk statuscode 200');
         String id =LocalMilkSale.fromJson( jsonDecode( response.body)).id!;
         print('id of localmilk ${id}');
        return id;
       }
       else {
         print('add local milk statuscode ${response.statusCode} ${response.body}');
         return 'Unsuccessful';
       }
     }
     catch(e)
    {
      print('error $e');
      return 'Unsuccessful';
    }

  }
  static Future<bool> deleteMilkSale(LocalMilkSale localSale)
  async{
    final url = Uri.parse("${CustomWidgets.getIp()}/localSale/delete");

    final response = await http.post(url,
        headers: {'Content-Type':"application/json"},
        body: json.encode(localSale.toJson()));
    try{
      if(response.statusCode == 200)
      {
        print('delete local milk statuscode 200');
        return true;
      }
      else {
        print('add local milk statuscode ${response.statusCode} ${response.body}');
        return false;
      }
    }
    catch(e)
    {
      print('error $e');
      return false;
    }
  }

  static Future<List<LocalMilkSale>?> getDateEntries(String date,String adminId)
  async{
    final url = Uri.parse("${CustomWidgets.getIp()}/localSale/getAllLocalSaleEntry/$adminId/$date");
    try{
      final response = await http.get(url);
      if(response.statusCode == 200)
      {
        List<dynamic> jsonData = jsonDecode(response.body);
        print(jsonData);
        return jsonData.map((entry)=> LocalMilkSale.fromJson(entry)).toList();
      }
      else{
        print('status code for local sale ${response.statusCode} with message ${response.body}');
        return [];
      }
    }
    catch(e){
      print('local sale exception $e');
      return null;
    }
  }

  static Future<List<LocalMilkSale>?> getEntriesForReport(List<String>customerCodeList,String fromDate,String toDate,bool isBuffaloSelected,bool isCowSelected,String adminId)
  async{
    final url = Uri.parse("${CustomWidgets.getIp()}/localSale/getAllLocalSaleEntry/$adminId/$fromDate/$toDate/$isBuffaloSelected/$isCowSelected");
    try{
      final response = await http.get(url,
      headers: {"Content-Type":"application/json"},);
      if(response.statusCode == 200)
      {

        List<dynamic> jsonData = jsonDecode(response.body);
        print(jsonData);
        return jsonData.map((entry)=> LocalMilkSale.fromJson(entry)).toList();
      }
      else{
        print('status code for local sale ${response.statusCode} with message ${response.body}');
        return [];
      }
    }
    catch(e){
      print('local sale exception $e');
      return null;
    }
  }
}