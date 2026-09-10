import 'dart:convert';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthService extends GetxService {
  late SharedPreferences _prefs;

  final RxnString accessToken = RxnString();
  final RxnString refreshToken = RxnString();
  final RxnInt currentUserId = RxnInt();

  Future<AuthService> init() async {
    _prefs = await SharedPreferences.getInstance();
    final token = _prefs.getString('access_token');
    accessToken.value = token;
    refreshToken.value = _prefs.getString('refresh_token');
    if (token != null) _decodeJwtAndSetUser(token);
    return this;
  }

  Future<void> saveTokens({required String access, String? refresh}) async {
    accessToken.value = access;
    await _prefs.setString('access_token', access);
    _decodeJwtAndSetUser(access);
    
    if (refresh != null) {
      refreshToken.value = refresh;
      await _prefs.setString('refresh_token', refresh);
    }
  }

  void _decodeJwtAndSetUser(String token) {
    try {
      final parts = token.split('.');
      if (parts.length > 1) {
        String payloadBase64 = parts[1];
        while (payloadBase64.length % 4 != 0) {
          payloadBase64 += '=';
        }
        final normalized = base64Url.normalize(payloadBase64);
        final payloadString = utf8.decode(base64Url.decode(normalized));
        final payloadMap = jsonDecode(payloadString);
        final userIdStr = payloadMap['user_id'];
        currentUserId.value = int.tryParse(userIdStr.toString());
      }
    } catch (e) {
      print('Error decoding JWT: $e');
    }
  }

  Future<void> clearTokens() async {
    accessToken.value = null;
    refreshToken.value = null;
    currentUserId.value = null;
    await _prefs.remove('access_token');
    await _prefs.remove('refresh_token');
  }

  bool get isLoggedIn => accessToken.value != null;
}
