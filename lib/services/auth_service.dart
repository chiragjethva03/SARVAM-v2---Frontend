import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../config/api_config.dart';

class AuthService {
  static Future<Map<String, dynamic>> signUp(Map<String, dynamic> data) async {
    final url = Uri.parse('${ApiConfig.baseUrl}/signup');
    final response = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(data),
    );

    final body = jsonDecode(response.body);
    return {"status": response.statusCode, "body": body};
  }

  static Future<Map<String, dynamic>> login(Map<String, dynamic> data) async {
    final url = Uri.parse('${ApiConfig.baseUrl}/login');
    final response = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(data),
    );

    final body = jsonDecode(response.body);
    return {"status": response.statusCode, "body": body};
  }

  /// Send Google sign-in data to backend
  static Future<Map<String, dynamic>> googleSignInToBackend(User user) async {
    final Map<String, dynamic> data = {
      "fullName": user.displayName ?? "",
      "email": user.email,
      "googleId": user.uid,
      "profilePicture": user.photoURL ?? "",
      "authProvider": "google",
    };

    final url = Uri.parse('${ApiConfig.baseUrl}/google-signin');
    final response = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(data),
    );

    final body = jsonDecode(response.body);
    return {"status": response.statusCode, "body": body};
  }

  static Future<void> saveUserData({
    required String token,
    required String userId,
    required String name,
    String? photoUrl,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('token', token);
    await prefs.setString('userId', userId); // Store userId
    await prefs.setString('name', name);
    await prefs.setString('photoUrl', photoUrl ?? '');
  }

  static Future<void> clearToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
  }
}
