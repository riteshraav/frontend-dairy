import 'dart:convert';
import 'package:hive_flutter/adapters.dart';
import 'package:http/http.dart' as http;
import '../model/admin.dart';
import '../widgets/appbar.dart';
import 'AdminAuthService.dart';

class AdminService {
  var temp = '${CustomWidgets.getIp()}/admin';
  Future<Admin> loginUser(String username) async {
    final url = Uri.parse('$temp/search/$username');

    final response = await http.get(url);
    final data = json.decode(response.body);


    if(response.statusCode == 200)
    {
      if(data == null)
      {
        return Admin(name: "N/A", password: "N/A", id: "N/A");
      }
      else{
        return Admin.fromJson(data);
      }
    }
    else{
      return Admin(name: "N/A", password: "N/A", id: "N/A");
    }


  }
  Future<String> loginUserAuth(Admin admin) async {
    final url = Uri.parse('$temp/login');
    var response;
    try{
     response = await http.post(url,
        headers: {"Content-Type":"application/json"},
        body: json.encode(admin.toJson())
    );
      if(response.statusCode == 200)
      {
        print("in if statuscode is 200");
        final data = response.headers;
        print(data);
        String accessToken = response.headers['access-token']!;
        print("got refreshtoken");
        String refreshToken = response.headers['refresh-token']!;
        print("here is rssponse body ........................");
        print(response.body);
        print("response body ended");
        Admin admin = Admin.fromJson(json.decode(response.body));
        var adminBox = Hive.box<Admin>('adminBox');
        adminBox.put('admin', admin);
        print(refreshToken);
        print(accessToken);
        AdminAuthService().saveTokens(accessToken, refreshToken);
        return "Successful";
      }
      else{
        print("${response.statusCode}  ${response.body}");
        return response.body;
      }
    }
    catch(e){
      print(e);
      print("here in catch ${response.body} ${response.statusCode}");
     rethrow;
    }
  }
  Future<bool> searchAdmin (String phone)
  async  {
    final response = await http.get(Uri.parse('$temp/search/$phone'));
    if(response.statusCode == 200)
    {
      final data = json.decode(response.body);
      if(data != null)
      {
        return true;
      }
      else {
        return false;
      }
    }
    else{
      return false;
    }

  }
  Future<Admin?> searchAdminAuth() async {
    String? accessToken = await AdminAuthService().getAccessToken();
    final url = '$temp/search';
    // If no access token, return null
    if (accessToken == null) {
      String? refreshToken = await AdminAuthService().getRefreshToken();
      if (refreshToken == null) {
        print("access token is missing at line 99");
        return Admin(code: -1);  // Return error if no refresh token
      }

      // Try refreshing the access token using ;the refresh token
      print("called refreshaccwsstoken at 104");
      return await _refreshAccessTokenForAdmin(refreshToken,url);
    }
    else {
      print("access token is found now call search");
      var response;
      try {
         response = await _getRequest(accessToken, url);

        // If the response is successful, return the admin object
        if (response.statusCode == 200) {
          final jsonBody = json.decode(response.body);
          return Admin.fromJson(jsonBody);
        }
        // If access token is expired, try refreshing it
        else if (response.statusCode == 401) {
          String? refreshToken = await AdminAuthService().getRefreshToken();
          if (refreshToken == null) {
            return Admin(code: -1); // Return error if no refresh token
          }

          // Try refreshing the access token using the refresh token
          return await _refreshAccessTokenForAdmin(refreshToken, url);
        }
        // If any other status, return null (or handle as needed)
        else {
          return null;
        }
      } catch (e) {
        print("Error: $e");
        print("$response here is catch of search admin");
        return null; // Return null in case of failure
      }
    }
  }

  Future<http.Response> _getRequest(String accessToken,String url) {
    return http.get(
      Uri.parse(url),
      headers: {
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

  Future<Admin?> _refreshAccessTokenForAdmin(String refreshToken,String url) async {
    try {
      final response = await http.get(
        Uri.parse('$temp/refresh-token'),
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

        // Retry the original request with the new access token
        final retryResponse = await _getRequest(newAccessToken,url);
        if (retryResponse.statusCode == 200) {
          print("retry response 200 at line 180");
          final jsonBody = json.decode(retryResponse.body);
          return Admin.fromJson(jsonBody);
        }
      }
    } catch (e) {
      print("Error refreshing token: $e");
      return Admin(code: -1);  // Return error if refreshing fails
    }

    return Admin(code: -1);  // Return error if refresh token is invalid or expired
  }
  Future<bool> directLogin() async {
    String? refreshToken = await AdminAuthService().getRefreshToken();
    if(refreshToken == null) {
      return false;
    }
    try {
      final response = await http.get(
        Uri.parse('$temp/refresh-token'),
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
        return true;
      }
      else{
        print('response is ${response.statusCode} ${response.body}');
        return false;
      }
    } catch (e) {
      print("Error refreshing token: $e");
      return false;  // Return error if refreshing fails
    }
  }
  Future<String?> _refreshAccessToken(String refreshToken,String url) async {
    try {
      final response = await http.get(
        Uri.parse('$temp/refresh-token'),
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
    } catch (e) {
      print("Error refreshing token: $e");
      return null;  // Return error if refreshing fails
    }

    return null;  // Return error if refresh token is invalid or expired
  }

  Future<bool> signupUser(Admin admin)
  async {
    try
    {
      final response = await http.post(Uri.parse('$temp/add'),
          headers: {"Content-Type": "application/json"},
          body: json.encode(admin.toJson()));
      if (response.statusCode == 200) {
        return true;
      } else {
        return false;
      }
    }
    catch(e){
      throw Exception("Error while signing up ");
    }
  }
  Future<bool> updateAdmin(Admin admin)
  async{

    final url = Uri.parse("${CustomWidgets.getIp()}/admin/update");
    try{
      final response = await http.post(url,
          headers: {"Content-Type":"application/json"},
          body: json.encode(admin.toJson()));
      if(response.statusCode == 200)
      {
        return true;
      }
      else{
        return false;
      }
    }
    catch(e)
    {
        return false;
    }
  }

  Future<bool?> updateAdminAuth(Admin admin)
  async  {
    String? accessToken = await AdminAuthService().getAccessToken();
    final url = '$temp/update';
    // If no access token, return null
    if (accessToken == null) {
      String? refreshToken = await AdminAuthService().getRefreshToken();
      if (refreshToken == null) {
        return null;  // Return error if no refresh token
      }

      // Try refreshing the access token using the refresh token
      accessToken = await _refreshAccessToken(refreshToken,url);
    }
      try {
        final response = await _postRequest(accessToken!, url,json.encode(admin.toJson()));
        // If the response is successful, return the admin object
        if (response.statusCode == 200) {
          return true;
        }
        // If access token is expired, try refreshing it
        else if (response.statusCode == 401) {
          String? refreshToken = await AdminAuthService().getRefreshToken();
          if (refreshToken == null) {
            return null;  // Return error if no refresh token
          }
          // Try refreshing the access token using the refresh token
          accessToken = await _refreshAccessToken(refreshToken,url);
          final response = await _postRequest(accessToken!, url,json.encode(admin.toJson()));
          // If the response is successful, return the admin object
          if (response.statusCode == 200) {
            return true;
          }
        }
        // If any other status, return null (or handle as needed)
        else {
          return false;
        }
      } catch (e) {
        print("Error: $e");
        return null; // Return null in case of failure
      }
      return false;

  }
}

