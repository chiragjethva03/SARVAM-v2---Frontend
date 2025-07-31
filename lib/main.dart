import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sarvam/views/OnbordingScreen.dart';
import 'theme/app_theme.dart';
import 'providers/user_provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  // Load saved user data from SharedPreferences
  final prefs = await SharedPreferences.getInstance();
  final storedName = prefs.getString('fullName');
  final storedPic = prefs.getString('profilePicture');

  runApp(
    ChangeNotifierProvider(
      create: (_) => UserProvider()
        ..setUser(
          storedName ?? '',
          storedPic ?? '',
        ),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.translucent, // Detect taps on empty space
      onTap: () {
        FocusManager.instance.primaryFocus?.unfocus();
      },
      child: MaterialApp(
        title: 'Sarvam',
        theme: AppTheme.lightTheme,
        home: OnboardingScreen(),
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}
