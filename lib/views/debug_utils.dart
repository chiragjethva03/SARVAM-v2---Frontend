import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../providers/user_provider.dart';

/// Print all SharedPreferences keys used for authentication
Future<void> debugPrintSharedPrefs() async {
  final prefs = await SharedPreferences.getInstance();
  print('====== SharedPreferences Data ======');
  print('token: ${prefs.getString('token')}');
  print('userId: ${prefs.getString('userId')}');
  print('fullName: ${prefs.getString('fullName')}');
  print('profilePicture: ${prefs.getString('profilePicture')}');
  print('====================================');
}

/// Print the current Provider state (UserProvider)
void debugPrintProvider(BuildContext context) {
  final userProvider = Provider.of<UserProvider>(context, listen: false);
  print('====== Provider Data ======');
  print('fullName: ${userProvider.fullName}');
  print('profilePicture: ${userProvider.profilePicture}');
  print('============================');
}
