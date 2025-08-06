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

  void setProfilePicture(String newUrl) {
    profilePicture = newUrl;
    _savePhotoUrl(newUrl); // Save to shared preferences
    notifyListeners();
  }

  void clearUser() {
    fullName = null;
    profilePicture = null;
    notifyListeners();
  }

  Future<void> loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    fullName = prefs.getString('name');
    profilePicture = prefs.getString('photoUrl');
    notifyListeners();
  }

  Future<void> _savePhotoUrl(String url) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('photoUrl', url);
  }
}
