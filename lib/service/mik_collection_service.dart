import 'dart:convert';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:hive/hive.dart';
import 'package:http/http.dart' as http;
import '../model/Customer.dart';
import '../model/milk_collection.dart';
import '../widgets/appbar.dart';
import 'AdminAuthService.dart';



class MilkCollectionService {
  Future<String?> verifyAccessToken() async {
    String? accessToken = await adminAuthService.getAccessToken();
    accessToken ??= await _refreshAccessToken();
    return accessToken;
  }

  AdminAuthService adminAuthService = AdminAuthService();

  Future<String?> _refreshAccessToken() async {
    String? refreshToken = await adminAuthService.getRefreshToken();
    if (refreshToken == null) {
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
    } catch (e) {
      print("Error refreshing token: $e");
      return null; // Return error if refreshing fails
    }

    return null; // Return error if refresh token is invalid or expired
  }

  Future<http.Response> _getRequest(String accessToken, String url) {
    return http.get(
      Uri.parse(url),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $accessToken"
      },
    );
  }

  Future<http.Response> _postRequest(String accessToken, String url,
      Object body) {
    return http.post(
        Uri.parse(url),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $accessToken"
        },
        body: body
    );
  }

  Future<bool> saveInfo(MilkCollection milkCollection) async {
    final url = Uri.parse("${CustomWidgets.getIp()}/collection/add");
    try {
      final response = await http.post(url,
          headers: {"Content-Type": "application/json"},
          body: json.encode({
            "adminId": milkCollection.adminId,
            "customerId": milkCollection.customerId,
            "quantity": milkCollection.quantity,
            "fat": milkCollection.fat,
            "snf": milkCollection.snf,
            "rate": milkCollection.rate,
            "totalValue": milkCollection.totalValue,
            "milkType": milkCollection.milkType,
            "time": milkCollection.time,
            "date": milkCollection.date
          }));
      if (response.statusCode == 200) {
        return true;
      } else {
        false;
      }
    }
    catch (e) {
      rethrow;
    }
    return false;
  }

  Future<String?> saveInfoAuth(MilkCollection milkCollection) async {
    String? accessToken = await verifyAccessToken();
    if (accessToken == null) {
      return null;
    }

    final url = "${CustomWidgets.getIp()}/collection/add";
    try {
      var response = await _postRequest(
          accessToken, url, json.encode(milkCollection.toJson()));
      if (response.statusCode == 200) {
        return response.body;
      } else if (response.statusCode == 401) {
        accessToken = await _refreshAccessToken();
        if (accessToken == null) {
          return null;
        }
        response = await _postRequest(
            accessToken, url, json.encode(milkCollection.toJson()));
        if (response.statusCode == 200) {
          return response.body;
        }
      }
    }
    catch (e) {
      rethrow;
    }
    return "Unsuccessful";
  }

  Future<void> deleteMilkEntry(String id) async {
    final response = await http.delete(
      Uri.parse('http://your-ip-address:your-port/milkcollection/$id'),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to delete entry');
    }
  }


  static Future<List<MilkCollection>> getAllForCustomer(String customerId,
      String adminId) async {
    final url = Uri.parse('${CustomWidgets
        .getIp()}/collection/getAllForCustomer/$customerId/$adminId');
    final response = await http.get(url);
    List<dynamic> jsonResponse = [];
    if (response.statusCode == 200) {
      jsonResponse = json.decode(response.body);
      return jsonResponse.map((data) => MilkCollection.formJson(data)).toList();
    }
    else {
      return [];
    }
  }

  Future<List<MilkCollection>?> getAllForCustomerAuth(String customerId,
      String adminId) async {
    String? accessToken = await verifyAccessToken();
    if (accessToken == null) {
      return null;
    }
    final url = '${CustomWidgets
        .getIp()}/collection/getAllForCustomer/$customerId/$adminId';
    try {
      final response = await _getRequest(accessToken, url);
      List<dynamic> jsonResponse = [];
      if (response.statusCode == 200) {
        jsonResponse = json.decode(response.body);
        return jsonResponse
            .map((data) => MilkCollection.formJson(data))
            .toList();
      }
      else if (response.statusCode == 401) {
        accessToken = await _refreshAccessToken();
        if (accessToken == null) {
          return null;
        }
        final response = await _getRequest(accessToken, url);

        if (response.statusCode == 200) {
          jsonResponse = json.decode(response.body);
          return jsonResponse
              .map((data) => MilkCollection.formJson(data))
              .toList();
        }
      }
      else {
        return [];
      }
    } catch (e) {
      rethrow;
    }
    return null;
  }

  static Future<List<MilkCollection>> getAllForAdmin(String adminId) async {
    final url = Uri.parse(
        '${CustomWidgets.getIp()}/collection/getAllForAdmin/$adminId');
    final response = await http.get(url);
    List<dynamic> jsonResponse = [];
    if (response.statusCode == 200) {
      jsonResponse = json.decode(response.body);
      return jsonResponse.map((data) => MilkCollection.formJson(data)).toList();
    }
    else {
      return [];
    }
  }

  Future<List<MilkCollection>?> getAllForAdminAuth(String adminId) async {
    String? accessToken = await verifyAccessToken();
    if (accessToken == null) {
      return null;
    }
    final url = '${CustomWidgets.getIp()}/collection/getAllForAdmin/$adminId';
    try {
      final response = await _getRequest(accessToken, url);
      List<dynamic> jsonResponse = [];
      if (response.statusCode == 200) {
        jsonResponse = json.decode(response.body);
        return jsonResponse
            .map((data) => MilkCollection.formJson(data))
            .toList();
      }
      else if (response.statusCode == 401) {
        accessToken = await _refreshAccessToken();
        if (accessToken == null) {
          return null;
        }
        final response = await _getRequest(accessToken, url);

        if (response.statusCode == 200) {
          jsonResponse = json.decode(response.body);
          return jsonResponse
              .map((data) => MilkCollection.formJson(data))
              .toList();
        }
      }
      else {
        return [];
      }
    }
    catch (e) {
      rethrow;
    }
    return null;
  }

  static List<MilkCollection> sortForPdf(List<MilkCollection> milkCollections,
      String milkType, DateTime fromDate, DateTime toDate) {
    // Filter the list
    List<MilkCollection> filteredList = milkCollections.where((milkCollection) {
      DateTime milkDate = DateTime.parse(milkCollection.date!);
      return milkCollection.milkType == milkType &&
          milkDate.isAfter(fromDate) &&
          (milkDate.isBefore(toDate.add(Duration(days: 1))));
    }).toList();
    filteredList.sort((a, b) =>
        int.parse(a.customerId!).compareTo(int.parse(b.customerId!)));

    return filteredList;
  }

  static Future<List<MilkCollection>> getAllForAdminWithSpecification(
      String fromDate, String toDate, String adminId, String milkType) async {
    final url = Uri.parse('${CustomWidgets
        .getIp()}/collection/filter/$fromDate/$toDate/$milkType/$adminId');
    final response = await http.get(url);
    List<dynamic> jsonResponse = [];
    if (response.statusCode == 200) {
      print("object");
      jsonResponse = json.decode(response.body);
      return jsonResponse.map((data) => MilkCollection.formJson(data)).toList();
    }
    else {
      print("else object");
      return [];
    }
  }

  Future<List<MilkCollection>?> getAllForAdminWithSpecificationAuth(
      String fromDate, String toDate, String adminId, String milkType) async {
    String? accessToken = await verifyAccessToken();
    if (accessToken == null) {
      return null;
    }
    final url = '${CustomWidgets
        .getIp()}/collection/filter/$fromDate/$toDate/$milkType/$adminId';
    try {
      final response = await _getRequest(accessToken, url);
      List<dynamic> jsonResponse = [];
      if (response.statusCode == 200) {
        print("object");
        jsonResponse = json.decode(response.body);
        return jsonResponse
            .map((data) => MilkCollection.formJson(data))
            .toList();
      }
      else if (response.statusCode == 401) {
        accessToken = await _refreshAccessToken();
        if (accessToken == null) {
          return null;
        }
        final response = await _getRequest(accessToken, url);

        if (response.statusCode == 200) {
          jsonResponse = json.decode(response.body);
          return jsonResponse
              .map((data) => MilkCollection.formJson(data))
              .toList();
        }
      }
      else {
        print("else object");
        return [];
      }
    }
    catch (e) {
      rethrow;
    }
    return null;
  }

  static Future<List<MilkCollection>> getAllForAdminWithFromAndTo(
      String fromDate, String toDate, String adminId) async {
    final url = Uri.parse('${CustomWidgets
        .getIp()}/collection/getAllForAdmin/$adminId/$fromDate/$toDate');
    final response = await http.get(url);
    List<dynamic> jsonResponse = [];
    if (response.statusCode == 200) {
      print("object");
      jsonResponse = json.decode(response.body);
      return jsonResponse.map((data) => MilkCollection.formJson(data)).toList();
    }
    else {
      print("else object");
      return [];
    }
  }

  Future<List<MilkCollection>?> getAllForAdminWithFromAndToAuth(String fromDate,
      String toDate, String adminId) async {
    String? accessToken = await verifyAccessToken();
    if (accessToken == null) {
      return null;
    }
    final url = '${CustomWidgets
        .getIp()}/collection/getAllForAdmin/$adminId/$fromDate/$toDate';
    try {
      final response = await _getRequest(accessToken, url);
      List<dynamic> jsonResponse = [];
      if (response.statusCode == 200) {
        print("object");
        jsonResponse = json.decode(response.body);
        return jsonResponse
            .map((data) => MilkCollection.formJson(data))
            .toList();
      }
      else if (response.statusCode == 401) {
        accessToken = await _refreshAccessToken();
        if (accessToken == null) {
          return null;
        }
        final response = await _getRequest(accessToken, url);

        if (response.statusCode == 200) {
          jsonResponse = json.decode(response.body);
          return jsonResponse
              .map((data) => MilkCollection.formJson(data))
              .toList();
        }
      }
      else {
        print("else object");
        return [];
      }
    }
    catch (e) {
      rethrow;
    }
    return null;
  }

  static Future<List<MilkCollection>> getForCustomersWithSpecification(
      List<String> customerList, String fromDate, String toDate, String adminId,
      bool cow, bool buffalo) async {
    final url = Uri.parse('${CustomWidgets
        .getIp()}/collection/filterForCustomers/$fromDate/$toDate/$cow/$buffalo/$adminId');
    final response = await http.post(url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(customerList));
    List<dynamic> jsonResponse = [];
    if (response.statusCode == 200) {
      print(response.body);
      jsonResponse = json.decode(response.body);
      return jsonResponse.map((data) => MilkCollection.formJson(data)).toList();
    }
    else {
      Fluttertoast.showToast(msg: "status code is : ${response.statusCode}");
      return [];
    }
  }

  Future<List<MilkCollection>?> getForCustomersWithSpecificationAuth(
      List<String> customerList, String fromDate, String toDate, String adminId,
      bool cow, bool buffalo) async {
    String? accessToken = await verifyAccessToken();
    if (accessToken == null) {
      return null;
    }


    final url = '${CustomWidgets
        .getIp()}/collection/filterForCustomers/$fromDate/$toDate/$cow/$buffalo/$adminId';
    try {
      final response = await _postRequest(
          accessToken, url, jsonEncode(customerList));
      List<dynamic> jsonResponse = [];
      if (response.statusCode == 200) {
        print(response.body);
        jsonResponse = json.decode(response.body);
        return jsonResponse
            .map((data) => MilkCollection.formJson(data))
            .toList();
      }
      else if (response.statusCode == 401) {
        accessToken = await _refreshAccessToken();
        if (accessToken == null) {
          return null;
        }
        final response = await _postRequest(
            accessToken, url, jsonEncode(customerList));
        if (response.statusCode == 200) {
          jsonResponse = json.decode(response.body);
          return jsonResponse
              .map((data) => MilkCollection.formJson(data))
              .toList();
        }
      }
      else {
        Fluttertoast.showToast(msg: "status code is : ${response.statusCode}");
        return [];
      }
    }
    catch (e) {
      rethrow;
    }
    return null;
  }

  Future<String?> deleteCollection(String id) async {
    String? accessToken = await verifyAccessToken();
    if (accessToken == null) {
      accessToken = await _refreshAccessToken();
      if (accessToken == null) return null;
    }

    final url = '${CustomWidgets.getIp()}/collection/$id';

    Future<http.Response> _makeDeleteRequest(String token) {
      return http.delete(
        Uri.parse(url),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token"
        },
      );
    }

    try {
      http.Response response = await _makeDeleteRequest(accessToken);

      if (response.statusCode == 200 || response.statusCode == 204) {
        return "Success";
      }

      if (response.statusCode == 401) {
        // Token expired, try refresh
        accessToken = await _refreshAccessToken();
        if (accessToken == null) return null;

        response = await _makeDeleteRequest(accessToken);
        if (response.statusCode == 200 || response.statusCode == 204) {
          return "Success";
        }
      }

      return null; // failed after retry
    } catch (e) {
      print("Delete error: $e");
      return null;
    }
  }
}