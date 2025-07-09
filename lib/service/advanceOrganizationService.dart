import '../widgets/appbar.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../model/advanceorganizationinfo.dart';

class AdvanceOrganizationService{
  static Future<bool> addAdvanceOrganization(AdvanceOrganization advanceOrganization)
  async{
    final url = Uri.parse("${CustomWidgets.getIp()}/advanceOrganization/add");
    try{
      final response = await http.post(url,
          headers: {"Content-Type":'application/json'},
          body: json.encode(advanceOrganization.toJson()));
      if(response.statusCode == 200)
      {
        return true;
      }
      else {
        return  false;
      }
    }
    catch(e)
    {
      print(e);
      return false;
    }
  }
  static Future<List<AdvanceOrganization>> getAdvanceOrganization(String adminId)
  async{
    final url = Uri.parse("${CustomWidgets.getIp()}/advanceOrganization/get/$adminId");
    try{
      final response = await http.get(url);
      if(response.statusCode == 200)
      {
        final data = response.body;
        List<dynamic> list =  json.decode(data);
        return list.map((entry)=> AdvanceOrganization.fromJson(entry)).toList();

      }
      else {
        return  [];
      }
    }
    catch(e)
    {
      print(e);
      return [];
    }
  }
}