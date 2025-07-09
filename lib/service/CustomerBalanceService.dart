import 'dart:async';

import '../model/CustomerBalance.dart';
import '../widgets/appbar.dart';
import 'package:http/http.dart'as http;
import 'dart:convert';

import 'AdminAuthService.dart';
class CustomerBalanceService{
  AdminAuthService adminAuthService = AdminAuthService();
  Future<String?> verifyAccessToken()async{
    String? accessToken = await adminAuthService.getAccessToken();
    accessToken ??= await _refreshAccessToken();
    return accessToken;
  }
  Future<String?> _refreshAccessToken() async {

    String? refreshToken = await adminAuthService.getRefreshToken();

    if(refreshToken == null) {
      print("refresh token is null at line 19");
      return null;
    }
    http.Response response;
    try {
       response = await http.get(
        Uri.parse('${CustomWidgets.getIp()}/admin/refresh-token'),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $refreshToken"
        },
      );
       print('refrsh token successul');
    }catch (e) {
      print("Error refreshing token at line 34: $e");
      return null;  // Return error if refreshing fails
    }
      // If refresh token is valid and the new tokens are returned
    print('going to check statuscode ');
    if (response.statusCode == 200) {
      print('statusode is 200 and checking data now');
        print('access token is storing at 40');
      String newAccessToken = response.headers['access-token']!;
        print('refresh token is storing');
      String newRefreshToken = response.headers['refresh-token']!;

        // Save the new tokens securely
        print('tokens  are saving at 46');
      await AdminAuthService().saveTokens(newAccessToken, newRefreshToken);

        return newAccessToken;
      }
      else{
        print("${response.statusCode} ${response.body}  retuuur nnull in line 44");
        return null;
      }
    // Return error if refresh token is invalid or expired
  }
  Future<http.Response> _getRequest(String accessToken,String url) {
    return http.get(
      Uri.parse(url),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $accessToken"
      },
    );
  }
  Future<http.Response> _postRequest(String accessToken,String url,Object body) {
    return http.post(
        Uri.parse(url),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $accessToken"
        },
        body: body
    );
  }

  static Future<bool> addCustomerBalance(CustomerBalance customerBalance)
  async{
    final url = Uri.parse("${CustomWidgets.getIp()}/customerBalance/add");
    final response = await http.post(url,
        headers: {"Content-Type":"application/json"},
        body: json.encode(customerBalance.toJson())
    );
    try {

      if(response.statusCode == 200)
      {
        return true;
      }
      else
        return false;
    }
    catch(e){
      print(e);
      return false;
    }
  }
   Future<bool?> addCustomerBalanceAuth(CustomerBalance customerBalance)
  async{
    final url = "${CustomWidgets.getIp()}/customerBalance/add";
    String? accessToken = await verifyAccessToken();
    if(accessToken == null) {
      return null;
    }

    try {
      var response = await _postRequest(accessToken, url, json.encode(customerBalance.toJson()));
      if(response.statusCode == 200)
      {
        return true;
      }
      else if(response.statusCode == 401) {
        accessToken = await _refreshAccessToken();
        if(accessToken == null) {
          return null;
        }
        response = await _postRequest(accessToken, url, json.encode(customerBalance.toJson()));
        if (response.statusCode == 200) {
          return true;
        }
        else if(response.statusCode == 401){
          return null;
        }
        else{
          return false;
        }
      }
      else
        return false;
    }
    catch(e){
      rethrow;
    }
  }
  static Future<CustomerBalance> getCustomerBalance(String adminId,String customerId)
  async {
    String id = "${adminId}_$customerId";
    final url = Uri.parse("${CustomWidgets.getIp()}/customerBalance/get/$id");
    final response = await http.get(url);
    if(response.statusCode == 200)
    {
      return CustomerBalance.formJson(json.decode(response.body));
    }
    else{
      return CustomerBalance( adminId: adminId, customerId: customerId);
    }
  }
   Future<CustomerBalance?> getCustomerBalanceAuth(String adminId,String customerId)
  async {
    String id = "${adminId}_$customerId";
    final url = "${CustomWidgets.getIp()}/customerBalance/get/$id";
    String? accessToken = await verifyAccessToken();
    if(accessToken == null) {
      return null;
    }
    try {
      var response = await _getRequest(accessToken, url);
      if (response.statusCode == 200) {
        return CustomerBalance.formJson(json.decode(response.body));
      }
      else if(response.statusCode == 401)
      {
        accessToken = await _refreshAccessToken();
        if(accessToken == null) {
          return null;
        }
        var newResponse = await  _getRequest(accessToken, url);

        if(newResponse.statusCode == 200)
        {
          return CustomerBalance.formJson(json.decode(response.body));}
        else if(newResponse.statusCode == 401){
          return null;
        }
        else{
          return CustomerBalance(adminId: "dummy", customerId: "dummy");
        }
      }
      else {
        return CustomerBalance(adminId: "dummy", customerId: customerId);
      }
    }
    catch(e)
    {
      rethrow;
    }
  }
  static Future<List<CustomerBalance>> getCustomerBalanceForCustomers(String adminId,List<String> customerCodeList)
  async {
    final url = Uri.parse("${CustomWidgets.getIp()}/customerBalance/getForCustomers/$adminId");
    print(url);
    final response = await http.post(url,
        headers: {"Content-Type":"application/json"},
        body: jsonEncode(customerCodeList)
    );

    List<dynamic> jsonResponse=[];
    if(response.statusCode == 200)
    {
      final data = response.body;
      jsonResponse = json.decode(response.body);
      return jsonResponse.map((data) => CustomerBalance.formJson(data)).toList();
    }
    else{
      return [];
    }
  }
   Future<List<CustomerBalance>?> getCustomerBalanceForCustomersAuth(String adminId,List<String> customerCodeList)
  async {
    final url = "${CustomWidgets.getIp()}/customerBalance/getForCustomers";
    print(url);
    String? accessToken = await verifyAccessToken();
    if(accessToken == null) {
      print("access token is null in initial");
      return null;
    }
    try{
      var response = await _postRequest(accessToken,url,jsonEncode(customerCodeList));

      if(response.statusCode == 200)
      {
        print('response is 200 at 222');
        final data = response.body;
        List<dynamic> jsonData = json.decode(data);
        return jsonData.map((c)=>CustomerBalance.formJson(c)).toList();
      }
      else if(response.statusCode == 401)
      {
        print('respone is 401 at 229');
        accessToken = await _refreshAccessToken();
        print('refrsh token execcuted successfully');
        if(accessToken == null) {
          print("access token is null in line 227");
          return null;
        }
        var newResponse = await  _postRequest(accessToken, url,jsonEncode(customerCodeList));

        if(newResponse.statusCode == 200)
        {
          print('new response is 200 at 239');
          final data = newResponse.body;
          List<dynamic> jsonData = json.decode(data);
          return jsonData.map((c)=>CustomerBalance.formJson(c)).toList();
        }
        else{
          print('status code is ${response.statusCode} at 245');
          return [];
        }
      }
      else{
        print("null in line 238");
        return null;
      }
    }
    catch(e)
    {
      print('catch at 256 $e');
      rethrow;
    }
  }
}