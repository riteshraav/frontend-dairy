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
}