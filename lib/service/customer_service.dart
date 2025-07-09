import 'dart:convert';
import '../widgets/appbar.dart';
import '../model/Customer.dart';
import 'package:http/http.dart' as http;
import 'AdminAuthService.dart';

class CustomerService {
  static Future<Customer> searchCustomer(String id) async {
    final url = Uri.parse('${CustomWidgets.getIp()}/customer/search/${id}');

    try {
      final response = await http.get(url);
      print("API Response: ${response.body}");
      print("Requesting: $url");


      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        print("Parsed Data: $data");

        return Customer.fromJson(data);
      } else {
        print("Error: Received status code ${response.statusCode}");
        return  Customer();
      }
    } catch (e) {
      print("Exception occurred: $e");
      rethrow; // Rethrows the exception to handle it in the calling code if necessary
    }
  }
  static Future<List<Customer>> findAllCustomers(String adminId)
  async {
    final url = Uri.parse('${CustomWidgets.getIp()}/customer/getAll/$adminId');
    final response = await http.get(url);
    if(response.statusCode == 200)
    {
      List<dynamic> jsonResponse = json.decode(response.body);
      return jsonResponse.map((data) => Customer.fromJson(data)).toList();
    }
    else {
      return [];
    }

  }
  static Future<List<Customer>?> findAllCustomersAuth() async {
    String? accessToken = await AdminAuthService().getAccessToken();

    // If no access token, return null
    if (accessToken == null) {
      print("access token is null in first//////////////////////////");
      return null;
    }

    try {
      final response = await _getRequest(accessToken);

      // If the response is successful, return the admin object
      if(response.statusCode == 200)
      {
        List<dynamic> jsonResponse = json.decode(response.body);
        print("status code is 200");
        List<Customer> customerList = jsonResponse.map((data) => Customer.fromJson(data)).toList();
        print('customer list size is ${customerList.length}');
        customerList.forEach((c)=> print(c.code));
        return customerList ;
      }  // If access token is expired, try refreshing it
      else if (response.statusCode == 401) {
        String? refreshToken = await AdminAuthService().getRefreshToken();
        if (refreshToken == null) {
          print("refrsh token is null/////////////////////////");
          return null;  // Return error if no refresh token
        }

        // Try refreshing the access token using the refresh token
        return await _refreshAccessToken(refreshToken);
      }
      else {
        print("uknown error null //////////////////////////////////");
        return null;
      }
    } catch (e) {
      print("Error in catch: $e /////////////////////////////");
      return null;  // Return null in case of failure
    }
  }

  static Future<http.Response> _getRequest(String accessToken) {
    return http.get(
      Uri.parse('${CustomWidgets.getIp()}/customer/getAll'),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $accessToken"
      },
    );
  }
  static Future<http.Response> _deleteRequest(String url,String accessToken) {
    return http.delete(
      Uri.parse(url),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $accessToken"
      },
    );
  }

  static Future<List<Customer>?> _refreshAccessToken(String refreshToken) async {
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

        // Retry the original request with the new access token
        final retryResponse = await _getRequest(newAccessToken);
        // If the response is successful, return the admin object
        if(retryResponse.statusCode == 200)
        {
          List<dynamic> jsonResponse = json.decode(retryResponse.body);
          return jsonResponse.map((data) => Customer.fromJson(data)).toList();
        }
        else{
          print("refresh token  error in request for customer/////////////////////////////");
          return null;
        }
      }
      else{

        print("refresh token unkown error/////////////////////////////${response.statusCode}   ${response.body}   refresh token is $refreshToken");
        return null;
      }
    } catch (e) {
      print("Error refreshing token: $e");
      return null;  // Return error if refreshing fails
    }
  // Return error if refresh token is invalid or expired
  }
  static Future<bool> addCustomer(Customer customer)
  async {
    final url = Uri.parse("${CustomWidgets.getIp()}/customer/add");
  try{
    final response = await http.post(url,
        headers:{"Content-Type":"application/json"},
        body:json.encode(customer.toJson()));
    if(response.statusCode == 200)
    {
      return true;
    }
    else{
      print("${response.body} ${response.statusCode} statuscode in add customer");
      return false;
    }
  }
  catch(e){
    print(e);
    print("here is catch while adding customer");
  }
  print("after try catch false in add customer");
  return false;

  }
  static Future<bool> updateCustomer(Customer customer)
  async {
    final url = Uri.parse('${CustomWidgets.getIp()}/customer/update');
    final response = await http.post(url,
        headers:{"Content-Type":"application/json"},
        body:json.encode(customer.toJson()));
    if(response.statusCode == 200)
    {
      return true;
    }
    else{
      return false;
    }

  }
  static Future<bool> deleteCustomers(List<String>customerCodeList,String adminId)
  async{


    final url = '${CustomWidgets.getIp()}/customer/delete/$adminId';
    try{
    final response = await http.delete(
      Uri.parse(url),
      headers: {
        "Content-Type": "application/json",
      },
      body: json.encode(customerCodeList)
    );
      if(response.statusCode == 200)
      {
        return true;
      }
      else
      {
        print("${response.statusCode} ${response.body} here is response");
        return false;
      }
    }
    catch(e)
    {
      print(e);
      print("catch in delete customer");
      return false;
    }
  }
}
