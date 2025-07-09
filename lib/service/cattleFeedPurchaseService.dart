import '../model/cattleFeedPurchase.dart';
import 'package:http/http.dart' as http;
import '../widgets/appbar.dart';
import 'dart:convert';
class CattleFeedPurchaseService{
  static Future<bool> addCattleFeedPurchase(CattleFeedPurchase cattleFeedPurchase)
 async {
      final url = Uri.parse("${CustomWidgets.getIp()}/cattleFeedPurchase/add");
      final response = await http.post(url,
      headers: {"Content-Type":"application/json"},
        body: json.encode(cattleFeedPurchase.toJson())
      );
    try{
      if(response.statusCode == 200){
        return true;
      }
      else
        return false;
    }
    catch(e){
      return false;
    }
  }
  static Future<List<CattleFeedPurchase>> getAllPurchasesForAdmin(
      String adminId) async {
    final url = Uri.parse("${CustomWidgets.getIp()}/cattleFeedPurchase/getAll/$adminId");
    try {
      final response = await http.get(url);
      if (response.statusCode ==200){
        List<dynamic> jsonResponse = json.decode(response.body);
        return jsonResponse.map((data)=> CattleFeedPurchase.fromJson(data)).toList();
      }
      else {
        print('response is ${response.body} ${response.statusCode}');
        return [];
      }
    }
    catch (e) {
      print('exception in cattlefeedpurchase list ');
      return [];
    }
  }
  static Future<bool?> deletePurchase(CattleFeedPurchase cattleFeedPurchase) async {
    final url = Uri.parse("${CustomWidgets.getIp()}/cattleFeedPurchase/delete");
    print('delete purchase called');
    try{
      final response = await http.post(url,headers:{'Content-Type' :'application/json'},
          body: json.encode(cattleFeedPurchase.toJson()));
      if(response.statusCode==200){
        return true;
      }
      else{
        print('response is ${response.statusCode} ${response.body}');
        return false;
      }
    }

    catch(e){
      print('in catch $e');
      return null;

    }
  }

  static Future<List<CattleFeedPurchase>> getAllCattleFeedPurchase(String adminId) async {
    final url = Uri.parse(
        "${CustomWidgets.getIp()}/cattleFeedPurchase/getAll/$adminId");
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        List<dynamic> jsonResponse = json.decode(response.body);
        return jsonResponse.map((data) => CattleFeedPurchase.fromJson(data))
            .toList();
      }
      else
        return [];
    }
    catch (e) {
      return [];
    }
  }
}