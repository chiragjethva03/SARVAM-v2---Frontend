import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserProvider extends ChangeNotifier {
  String? fullName;
  String? profilePicture;

  void setUser(String name, String pic) async {
    fullName = name;
    profilePicture = pic;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('fullName', name);
    await prefs.setString('profilePicture', pic);
    notifyListeners();
  }

  void setProfilePicture(String newUrl) async {
    profilePicture = newUrl;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('profilePicture', newUrl);
    notifyListeners();
  }

  void clearUser() {
    fullName = null;
    profilePicture = null;
    notifyListeners();
  }

  Future<void> loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    fullName = prefs.getString('fullName');
    profilePicture = prefs.getString('profilePicture');
    notifyListeners();
  }
}
