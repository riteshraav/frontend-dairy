import '../model/cattleFeedSell.dart';
import '../widgets/appbar.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import '../model/Customer.dart';
class CattleFeedSellService{
    static Future<CattleFeedSell?> addCattleFeedSell(CattleFeedSell cattleFeedSell)
   async {
      final url = Uri.parse("${CustomWidgets.getIp()}/cattleFeedSell/sell");
      final response = await http.post(url,
      headers: {'Content-Type':'application/json'},
      body: json.encode(cattleFeedSell.toJson()));

      try {
        if(response.statusCode == 200){
          final data = response.body;

          return CattleFeedSell.fromJson(jsonDecode(data));
        }
        else{
          print('response is ${response.statusCode} ${response.body}');
        return null;
        }
      }
      catch(e){
        print('in catch $e');
      return null;
      }
    }

    static Future<bool?> deleteCattleFeedSell(CattleFeedSell cattleFeedSell)
    async {
      final url = Uri.parse("${CustomWidgets.getIp()}/cattleFeedSell/delete");
      final response = await http.post(url,
          headers: {'Content-Type':'application/json'},
          body: json.encode(cattleFeedSell.toJson()));

      try {
        if(response.statusCode == 200){
          print('cattlefeed sell delete response 200');
        return true;
        }
        else{
          print('response is ${response.statusCode} ${response.body}');
          return null;
        }
      }
      catch(e){
        print('in catch $e');
        return null;
      }
    }
    static Future<List<CattleFeedSell>> getAllCattleFeedSell(String adminId,
        List<String> customer, String fromDate, String toData) async
    {
      final url = Uri.parse("${CustomWidgets
          .getIp()}/cattleFeedSell/getAllForCustomers/$adminId/$fromDate/$toData");
      try {
        final response = await http.post(url,
            headers: {
              "Content-Type": "application/json"
            },
            body: json.encode(customer)
        );
        if (response.statusCode == 200) {
          print("status code  200");
          List<dynamic> jsonResponse = json.decode(response.body);
          print("${jsonResponse}");
          return jsonResponse.map((s) => CattleFeedSell.fromJson(s)).toList();
        }
        else {
          print("cattle feed sell else ${response.statusCode} ${response.body}");
          return [];
        }
      }
      catch (e) {
        print("catch in cattlefeed sell");
        return [];
      }
    }
    static Future<List<CattleFeedSell>> getAllCattleFeedSellForAdmin(String adminId)
    async {
      final url = Uri.parse("${CustomWidgets.getIp()}/cattleFeedSell/getAllForAdmin/$adminId");
      try{
        final response = await http.get(url,
        headers: {
          "Content-Type":"application/json"
        });
        if(response.statusCode == 200){
          print("statsus code  200");
          List<dynamic> jsonResponse = json.decode(response.body);
          print("${jsonResponse}");
          return jsonResponse.map((s)=> CattleFeedSell.fromJson(s)).toList();
        }
        else {
          print("cattle feed sell else ${response.statusCode} ${response.body}");
          return [];
        }
      }
      catch(e){
        print("catch in cattlefeed sell");
        return [];
      }
    }

}
