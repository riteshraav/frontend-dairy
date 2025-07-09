import '../model/deduction.dart';
import '../widgets/appbar.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'AdminAuthService.dart';
class DeductionService{
  Future<String?> verifyAccessToken()async{
    String? accessToken = await adminAuthService.getAccessToken();
    accessToken ??= await _refreshAccessToken();
    return accessToken;
  }
  AdminAuthService adminAuthService = AdminAuthService();
  Future<String?> _refreshAccessToken() async {
    String? refreshToken = await adminAuthService.getRefreshToken();
    if(refreshToken == null) {
      print("refresh token is null");
      return null;
    }
    try {
      final response = await http.get(
        Uri.parse('${CustomWidgets.getIp()}/admin/refresh-token'),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $refreshToken"
        },
      );
      // If refresh token is valid and the new tokens are returned
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
        print("access token is ${await AdminAuthService().getAccessToken()}");
        print("refresh token is ${refreshToken}");
        print("null in second response while refreshing ${response.statusCode}");
        return null;
      }
    } catch (e) {
      print("Error refreshing token: $e");
      return null;  // Return error if refreshing fails
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
  static Future<bool> addDeduction(Deduction deduction)
  async{
    final url = Uri.parse("${CustomWidgets.getIp()}/deduction/add");
    final response = await http.post(url,
        headers: {"Content-Type":"application/json"},
        body: json.encode(deduction.toJson())
    );
    try {
      if(response.statusCode == 200)
      {
        return true;
      }
      else{
        return false;
      }
    }
    catch(e){
      print(e);
      return false;
    }
  }
   Future<bool?> addDeductionAuth(Deduction deduction)
  async{
    String? accessToken = await verifyAccessToken();
    if(accessToken == null) {
      print("firstr access token is emtpy in add deduction");
      return null;
    }
    final url = "${CustomWidgets.getIp()}/deduction/add";
    try {
    var response = await _postRequest(accessToken, url, json.encode(deduction.toJson()));
      if(response.statusCode == 200)
      {
        return true;
      } else if(response.statusCode == 401) {
        accessToken = await _refreshAccessToken();
        if(accessToken == null) {
          print("access token in null after refreshing after invalid access token");
          return null;
        }
        response = await _postRequest(accessToken, url, json.encode(deduction.toJson()));
        if (response.statusCode == 200) {
          return true;
        }
        else{
          print("null after second  token is ${response.statusCode}");
          return null;
        }
      }
      else{
        print("null statuscode is ${response.statusCode}");
        return null;
      }
    }
    catch(e){
      rethrow;
    }


  }
 static Future<List<Deduction>> getDeduction(String adminId,String customerId)
 async {
   final url = Uri.parse("${CustomWidgets.getIp()}/deduction/get/adminId/customerId");
   final response = await http.get(url);

   try{
     if(response.statusCode == 200)
     {
       final data = response.body;
       List<dynamic> jsonData = json.decode(data);
       return jsonData.map((deduction)=>Deduction.fromJson(deduction)).toList();
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
   Future<List<Deduction>?> getDeductionAuth(String adminId,String customerId)
  async {
    String? accessToken = await verifyAccessToken();
    if(accessToken == null) {
      print("access token null ins starting");
      return null;
    }
    final url = "${CustomWidgets.getIp()}/deduction/get/customerId";
    try{
      var response = await _getRequest(accessToken, url);

      if(response.statusCode == 200)
      {
        final data = response.body;
        List<dynamic> jsonData = json.decode(data);
        return jsonData.map((deduction)=>Deduction.fromJson(deduction)).toList();
      }
      else if(response.statusCode == 401)
      {
        accessToken = await _refreshAccessToken();
        if(accessToken == null) {
          print("access token null in second attempt");
          return null;
        }
        var newResponse = await  _getRequest(accessToken, url);

        if(newResponse.statusCode == 200)
        {

          final data = newResponse.body;
          List<dynamic> jsonData = json.decode(data);
          return jsonData.map((deduction)=>Deduction.fromJson(deduction)).toList();
           }
        else{
          return [];
        }
      }
      else{
        print("null after the reponse first ${response.statusCode}");
        return null;
      }
    }
    catch(e)
    {
      rethrow;
    }
  }
 static Future<List<Deduction>> getDeductionForReport(String adminId,String customerId,String fromDate,String toDate)
 async {
   final url = Uri.parse("${CustomWidgets.getIp()}/deduction/get/$adminId/$customerId/$fromDate/$toDate");
   final response = await http.get(url);
   try{
     if(response.statusCode == 200)
     {
       final data = response.body;
       List<dynamic> jsonData = json.decode(data);
       return jsonData.map((deduction)=>Deduction.fromJson(deduction)).toList();
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
   Future<List<Deduction>?> getDeductionForReportAuth(String adminId,String customerId,String fromDate,String toDate)
  async {
    String? accessToken = await verifyAccessToken();
    if(accessToken == null) {
      print("access token null ins starting");

      return null;
    }
    final url = "${CustomWidgets.getIp()}/deduction/get/$customerId/$fromDate/$toDate";
    try{
      final response = await _getRequest(accessToken, url);
      if(response.statusCode == 200)
      {
        final data = response.body;
        List<dynamic> jsonData = json.decode(data);
        return jsonData.map((deduction)=>Deduction.fromJson(deduction)).toList();
      }
      else if(response.statusCode == 401)
      {
        accessToken = await _refreshAccessToken();
        if(accessToken == null) {
          print("access token null in second attempt");

          return null;
        }
        var newResponse = await  _getRequest(accessToken, url);

        if(newResponse.statusCode == 200)
        {
          final data = newResponse.body;
          List<dynamic> jsonData = json.decode(data);
          return jsonData.map((deduction)=>Deduction.fromJson(deduction)).toList();
        }
        else{
          return [];
        }
      }
      else{
        return [];
      }
    }
    catch(e)
    {
      rethrow;
    }
  }
  static Future<List<Deduction>> getDeductionForAdminBetweenPeriod(String adminId,String fromDate,String toDate)
  async{
    final url = Uri.parse("${CustomWidgets.getIp()}/deduction/get/$adminId/$fromDate/$toDate");
    final response = await http.get(url);

    if(response.statusCode == 200)
    {
      List<dynamic> jsonDate = json.decode(response.body);
      jsonDate.forEach((data)=>print(data));
      return jsonDate.map((deductionJson) =>  Deduction.fromJson(deductionJson)).toList();
    }
    else{
      return [];
    }
  }
  ////////////////////////////////////////////////////
   Future<List<Deduction>?> getDeductionForAdminBetweenPeriodAuth(String fromDate,String toDate)
  async{
    String? accessToken = await verifyAccessToken();
    if(accessToken == null) {
      print("access token null ins starting");

      return null;
    }
    final url = "${CustomWidgets.getIp()}/deduction/getForAdmin/$fromDate/$toDate";
    try{
      var response = await _postRequest(accessToken, url,jsonEncode(""));

      if(response.statusCode == 200)
      {
        print("statusocde is response was ${response.statusCode}");

        final data = response.body;
        List<dynamic> jsonData = json.decode(data);
        return jsonData.map((deduction)=>Deduction.fromJson(deduction)).toList();
      }
      else if(response.statusCode == 401)
      {
        accessToken = await _refreshAccessToken();
        if(accessToken == null) {
          print("access token null in second attempt");

          return null;
        }
        var newResponse = await  _getRequest(accessToken, url);

        if(newResponse.statusCode == 200)
        {
          final data = newResponse.body;
          List<dynamic> jsonData = json.decode(data);
          return jsonData.map((deduction)=>Deduction.fromJson(deduction)).toList();
        }
        else{
          print("error in new response with ${newResponse.statusCode} and response was ${response.statusCode}");
          return [];
        }
      }
      else{
        print("null after the reponse first ${response.statusCode}");

        return null;
      }
    }
    catch(e)
    {
      rethrow;
    }
  }
 static Future<List<Deduction>> getDeductionForCustomersBetweenPeriod(List<String>customerCodeList,String adminId,String fromDate,String toDate)
 async{
   final url = Uri.parse("${CustomWidgets.getIp()}/deduction/get/$adminId/$fromDate/$toDate");
   final response = await http.post(url,
   headers: {"Content-Type":"application/json"},
     body: jsonEncode(customerCodeList)
   );

   if(response.statusCode == 200)
   {
     List<dynamic> jsonDate = json.decode(response.body);
     jsonDate.forEach((data)=>print(data));
     return jsonDate.map((deductionJson) =>  Deduction.fromJson(deductionJson)).toList();
   }
   else{
     return [];
   }
 }
   Future<List<Deduction>?> getDeductionForCustomersBetweenPeriodAuth(List<String>customerCodeList,String adminId,String fromDate,String toDate)
  async{
    final url ="${CustomWidgets.getIp()}/deduction/get/$fromDate/$toDate";
    print(fromDate);
    print(toDate);
    String? accessToken = await verifyAccessToken();
    if(accessToken == null) {
      print("access token null ins starting");
      return null;
    }
    try{
      var response = await _postRequest(accessToken,url,jsonEncode(customerCodeList));

      if(response.statusCode == 200)
      {
        final data = response.body;
        List<dynamic> jsonData = json.decode(data);
        return jsonData.map((deduction)=>Deduction.fromJson(deduction)).toList();
      }
      else if(response.statusCode == 401)
      {
        accessToken = await _refreshAccessToken();
        if(accessToken == null) {
          print("access token null in second attempt");

          return null;
        }
        var newResponse = await  _postRequest(accessToken, url,jsonEncode(customerCodeList));

        if(newResponse.statusCode == 200)
        {

          final data = newResponse.body;
          List<dynamic> jsonData = json.decode(data);
          return jsonData.map((deduction)=>Deduction.fromJson(deduction)).toList();
        }
        else{
          return [];
        }
      }
      else{
        print("null after the reponse first ${response.statusCode}");

        return null;
      }
    }
    catch(e)
    {
      rethrow;
    }
  }
  static Future<bool> deleteDeduction(String adminId,String date)
  async {
    final url = Uri.parse("${CustomWidgets.getIp()}/deduction/delete/$adminId/$date");
    final response = await http.post(url,
        headers: {"Content-Type":"application/json"},
        body: jsonEncode(""));

    try {
      if(response.statusCode == 200)
      {
        return true;
      }
      else{
        print(response.statusCode);
        return false;
      }
    }
    catch(e){
      print(e);
      return false;
    }
  }
   Future<bool?> deleteDeductionAuth(String adminId,String date)
  async {
    final url = "${CustomWidgets.getIp()}/deduction/delete/$date";
    String? accessToken = await verifyAccessToken();
    if(accessToken == null) {
      print("access token null ins starting");

      return null;
    }
    try{
      var response = await _postRequest(accessToken,url,jsonEncode(""));

      if(response.statusCode == 200)
      {
        return true;
      }
      else if(response.statusCode == 401)
      {
        accessToken = await _refreshAccessToken();
        if(accessToken == null) {
          print("access token null in second attempt");

          return null;
        }
        var newResponse = await  _postRequest(accessToken, url,jsonEncode(""));

        if(newResponse.statusCode == 200)
        {

        return true;
        }
        else{
          return false;
        }
      }
      else{
        return false;
      }
    }
    catch(e)
    {
      rethrow;
    }

  }
}