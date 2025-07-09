import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class AdminAuthService {
  final FlutterSecureStorage _secureStorage = FlutterSecureStorage();

  Future<void> saveTokens(String accessToken, String refreshToken) async {
    await _secureStorage.write(key: 'accessToken', value: accessToken);
    await _secureStorage.write(key: 'refreshToken', value: refreshToken);
  }

  Future<String?> getAccessToken() async {
    String? accesstoken = await _secureStorage.read(key: 'accessToken');
    print("access token $accesstoken");
    return accesstoken;
  }

  Future<String?> getRefreshToken() async {
    String? refreshtoken = await _secureStorage.read(key: 'refreshToken');
    print("refresh token is $refreshtoken");
    return refreshtoken;
  }

  Future<void> deleteTokens() async {
    await _secureStorage.delete(key: 'accessToken');
    await _secureStorage.delete(key: 'refreshToken');
  }
}
