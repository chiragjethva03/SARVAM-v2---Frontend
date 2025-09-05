import 'dart:io';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../config/api_config.dart';
import 'auth_service.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/user_provider.dart';

class AccountApi {
  static const String baseUrl = "${ApiConfig.baseUrl}";

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
      final data = jsonDecode(response.body);

      final user = (data is Map && data['user'] is Map)
          ? data['user'] as Map<String, dynamic>
          : (data as Map<String, dynamic>);

      // Keep local name/picture fresh
      final fullName = (user['fullName'] ?? '').toString();
      final profilePicture = (user['profilePicture'] ?? '').toString();
      await prefs.setString('fullName', fullName);
      await prefs.setString('profilePicture', profilePicture);

      // Only write mobile if backend has one; else keep local/cached
      final serverPhone = (user['phoneNumber'] ?? user['mobile'] ?? '').toString().trim();
      if (serverPhone.isNotEmpty) {
        await AuthService.setMobile(serverPhone);
      }

      return data;
    } else {
      // ignore: avoid_print
      print("Failed to load user: ${response.body}");
      return null;
    }
  }

  static Future<bool> updatePersonalDetails({
    required BuildContext context,
    required String fullName,
    String? phoneNumber,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    if (token == null) return false;

    final url = Uri.parse('${ApiConfig.baseUrl}/user/update-details');
    final body = {'fullName': fullName, 'phoneNumber': phoneNumber};

    final res = await http.put(
      url,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
        'Cache-Control': 'no-cache',
      },
      body: jsonEncode(body),
    );

    if (res.statusCode == 200) {
      await prefs.setString('fullName', fullName);

      final currentPic = prefs.getString('profilePicture') ?? '';
      Provider.of<UserProvider>(context, listen: false).setUser(fullName, currentPic);

      if (phoneNumber != null && phoneNumber.trim().isNotEmpty) {
        await AuthService.setMobile(phoneNumber.trim());
      }
      return true;
    }
    return false;
  }

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

      final data = jsonDecode(res.body);
      return {
        "success": data["success"] ?? res.statusCode == 200,
        "message": data["message"] ?? "Unexpected error",
      };
    } catch (e) {
      // ignore: avoid_print
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
      // clear session keys but keep cached per-user mobiles
      final mobileMapKeys = prefs.getKeys().where((k) => k.startsWith('mobile:')).toList();
      final cachedPairs = <String, String>{};
      for (final k in mobileMapKeys) {
        cachedPairs[k] = prefs.getString(k) ?? '';
      }
      await prefs.clear();
      // restore cached per-user mobiles after a full clear
      for (final e in cachedPairs.entries) {
        if (e.value.isNotEmpty) await prefs.setString(e.key, e.value);
      }
      return true;
    } else {
      // ignore: avoid_print
      print("Failed to delete account: ${response.body}");
      return false;
    }
  }

  static Future<List<dynamic>> fetchUserPosts() async {
    final token = await AuthService.getToken();
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

  static Future<String?> uploadProfilePicture(File imageFile) async {
    final token = await AuthService.getToken();
    final uri = Uri.parse('$baseUrl/user/upload-profile-picture');

    final request = http.MultipartRequest('POST', uri)
      ..headers['Authorization'] = 'Bearer $token'
      ..files.add(await http.MultipartFile.fromPath('profilePicture', imageFile.path));

    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);

    if (response.statusCode == 200) {
      final responseData = jsonDecode(response.body);
      final newUrl = (responseData['profilePicture'] ?? '').toString();

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('profilePicture', newUrl);
      return newUrl;
    } else {
      return null;
    }
  }
}
