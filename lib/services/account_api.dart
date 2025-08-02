import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../config/api_config.dart';
import 'auth_service.dart';

class AccountApi {
  static const String baseUrl = "${ApiConfig.baseUrl}"; // change as needed

  static Future<Map<String, dynamic>?> fetchUserDetails() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    if (token == null) return null;

    final url = Uri.parse('$baseUrl/user/me');
    final response = await http.get(
      url,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      print("Failed to load user: ${response.body}");
      return null;
    }
  }

  static Future<bool> updatePersonalDetails({
    required String fullName,
    String? mobileNumber,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');
      if (token == null) return false;

      final url = Uri.parse('$baseUrl/user/update-details');
      final response = await http.put(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({"fullName": fullName, "mobileNumber": mobileNumber}),
      );

      return response.statusCode == 200;
    } catch (e) {
      print("Error updating details: $e");
      return false;
    }
  }

  static Future<Map<String, String>> _authHeaders() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token') ?? '';
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  /// New: return success and backend message
  static Future<Map<String, dynamic>> changePasswordDetailed({
    required String currentPassword,
    required String newPassword,
  }) async {
    final url = Uri.parse("$baseUrl/user/change-password");
    final token = await AuthService.getToken();

    try {
      final res = await http.put(
        url,
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
        body: jsonEncode({
          "currentPassword": currentPassword,
          "newPassword": newPassword,
        }),
      );

      // Always decode body even for non-200
      final data = jsonDecode(res.body);

      return {
        "success": data["success"] ?? res.statusCode == 200,
        "message": data["message"] ?? "Unexpected error",
      };
    } catch (e) {
      print("Error in changePasswordDetailed: $e");
      return {"success": false, "message": "Something went wrong"};
    }
  }

  static Future<bool> deleteAccount() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    if (token == null) return false;

    final url = Uri.parse('$baseUrl/user/delete');
    final response = await http.delete(
      url,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      // Clear user data after account deletion
      await prefs.clear();
      return true;
    } else {
      print("Failed to delete account: ${response.body}");
      return false;
    }
  }

  static Future<List<dynamic>> fetchUserPosts() async {
    final token = await AuthService.getToken(); // if you store token
    final response = await http.get(
      Uri.parse('$baseUrl/posts/my'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['posts'] ?? [];
    } else {
      throw Exception('Failed to load posts');
    }
  }

  static Future<bool> deletePost(String postId) async {
    final token = await AuthService.getToken();
    final response = await http.delete(
      Uri.parse('$baseUrl/posts/$postId'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    return response.statusCode == 200;
  }
}
