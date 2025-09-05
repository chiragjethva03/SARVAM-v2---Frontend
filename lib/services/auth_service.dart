import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../config/api_config.dart';
import '../providers/user_provider.dart';

class AuthService {
  // API
  static Future<Map<String, dynamic>> signUp(Map<String, dynamic> data) async {
    final r = await http.post(
      Uri.parse('${ApiConfig.baseUrl}/signup'),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(data),
    );
    return {"status": r.statusCode, "body": jsonDecode(r.body)};
  }

  static Future<Map<String, dynamic>> login(Map<String, dynamic> data) async {
    final r = await http.post(
      Uri.parse('${ApiConfig.baseUrl}/login'),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(data),
    );
    return {"status": r.statusCode, "body": jsonDecode(r.body)};
  }

  static Future<Map<String, dynamic>> googleSignInToBackend(User user) async {
    final r = await http.post(
      Uri.parse('${ApiConfig.baseUrl}/google-signin'),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "fullName": user.displayName ?? "",
        "email": user.email,
        "googleId": user.uid,
        "profilePicture": user.photoURL ?? "",
        "authProvider": "google",
      }),
    );
    return {"status": r.statusCode, "body": jsonDecode(r.body)};
  }

  // utils
  static String _normalizeMobile(String? m) {
    if (m == null) return "";
    final d = m.replaceAll(RegExp(r'\D'), '');
    return d.length > 12 ? d.substring(d.length - 12) : d;
  }

  // per-user key helpers
  static String _userMobileKey(String userId) => 'mobile:$userId';

  // persistence
  static Future<void> saveUserData({
    required BuildContext context,
    required String token,
    required String userId,
    required String name,
    String? photoUrl,
    String? mobile, // may be null on login
  }) async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setString('token', token);
    await prefs.setString('userId', userId);
    await prefs.setString('fullName', name);
    await prefs.setString('profilePicture', photoUrl ?? '');

    // 1) if mobile arrives now, save and cache per user
    if (mobile != null && mobile.trim().isNotEmpty) {
      final nm = _normalizeMobile(mobile);
      await prefs.setString('mobile', nm);
      await prefs.setString(_userMobileKey(userId), nm);
      // print('[AuthService] saveUserData: payload mobile=$nm');
    } else {
      // 2) otherwise try to restore from per-user cache
      final cached = prefs.getString(_userMobileKey(userId));
      if (cached != null && cached.trim().isNotEmpty) {
        await prefs.setString('mobile', cached.trim());
        // print('[AuthService] saveUserData: restored mobile=$cached');
      } else {
        // keep whatever exists; do not remove
        // print('[AuthService] saveUserData: no mobile to set/restore');
      }
    }

    Provider.of<UserProvider>(context, listen: false).setUser(name, photoUrl ?? '');
  }

  static Future<void> setMobile(String mobile) async {
    final prefs = await SharedPreferences.getInstance();
    final nm = _normalizeMobile(mobile);
    await prefs.setString('mobile', nm);
    final uid = prefs.getString('userId');
    if (uid != null && uid.isNotEmpty) {
      await prefs.setString(_userMobileKey(uid), nm); // cache per-user
    }
  }

  static Future<String?> getMobile() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('mobile');
  }

  static Future<void> hydrateFromPrefs(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    final name = prefs.getString('fullName') ?? '';
    final pic = prefs.getString('profilePicture') ?? '';
    Provider.of<UserProvider>(context, listen: false).setUser(name, pic);
    // do not touch 'mobile'
  }

  static Future<void> clearToken(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    final uid = prefs.getString('userId'); // remember userId to keep cache
    await prefs.remove('token');
    await prefs.remove('userId');
    await prefs.remove('fullName');
    await prefs.remove('profilePicture');
    await prefs.remove('mobile'); // clear session copy only
    // DO NOT remove 'mobile:<userId>' cache
    Provider.of<UserProvider>(context, listen: false).clearUser();
  }

  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

}
