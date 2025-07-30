import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserProvider extends ChangeNotifier {
  String? fullName;
  String? profilePicture;

  void setUser(String name, String pic) {
    fullName = name;
    profilePicture = pic;
    notifyListeners();
  }

  void clearUser() {
    fullName = null;
    profilePicture = null;
    notifyListeners();
  }

  Future<void> loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    fullName = prefs.getString('name');  // must match the key used in saveUserData
    profilePicture = prefs.getString('photoUrl');
    notifyListeners();
  }
}
