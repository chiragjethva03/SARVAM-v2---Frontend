import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';

class EmailValidateService {
  static const String baseUrl = "${ApiConfig.baseUrl}"; // replace with real URL

  static Future<Map<String, dynamic>> validateEmail(String email) async {
    final url = Uri.parse("$baseUrl/validate-email");
    final response = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"email": email}),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      return {
        "success": false,
        "message": "Something went wrong. Try again later."
      };
    }
  }

  static Future<Map<String, dynamic>> verifyOtp(String email, String otp) async {
    try {
      final response = await http.post(
        Uri.parse("$baseUrl/verify-otp"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"email": email, "otp": otp}),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        return {"success": false, "message": "Server error. Try again."};
      }
    } catch (e) {
      return {"success": false, "message": e.toString()};
    }
  }

  static Future<Map<String, dynamic>> resetPassword(
      {required String email, required String newPassword}) async {
    try {
      final response = await http.post(
        Uri.parse("$baseUrl/reset-password"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"email": email, "newPassword": newPassword}),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        return {"success": false, "message": "Server error. Try again."};
      }
    } catch (e) {
      return {"success": false, "message": e.toString()};
    }
  }
}
