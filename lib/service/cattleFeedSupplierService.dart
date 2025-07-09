import '../widgets/appbar.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../model/cattleFeedSupplier.dart';

class CattleFeedSupplierService{
   static Future<bool> addCattleFeedSupplier(CattleFeedSupplier cattleFeedSupplier)
  async {
    final url = Uri.parse("${CustomWidgets.getIp()}/cattleFeedSupplier/add");
    try{
      final response = await http.post(url,
          headers:{'Content-Type':'application/json'},
          body: json.encode(cattleFeedSupplier.toJson()));

      if(response.statusCode == 200)
      {
        return true;
      }
      else  {
        return false;
      }
    }
    catch(e){
      print(e);
      return false;
    }

  }
  static Future<List<CattleFeedSupplier>> getAllCattleFeedSupplier(String adminId)
  async{
     final url = Uri.parse("${CustomWidgets.getIp()}/cattleFeedSupplier/getAll/$adminId");
     final response = await http.get(url);
     try{

       if(response.statusCode == 200)
       {
         List<dynamic> jsonResponse = json.decode(response.body);
         return jsonResponse.map((data)=>  CattleFeedSupplier.fromJson(data)).toList();

       }
       else{
         return [];
       }
     }
     catch(e)
    {
      print(e);
      return [];
    }
  }
}