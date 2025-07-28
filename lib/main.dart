import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:sarvam/views/OnbordingScreen.dart';
import 'theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Sarvam',
      theme: AppTheme.lightTheme,
      home: OnboardingScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}
