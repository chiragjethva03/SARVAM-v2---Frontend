import 'package:flutter/material.dart';
import 'package:sarvam/views/OnbordingScreen.dart';
import 'views/OnbordingScreen.dart';
import 'theme/app_theme.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Sarvam',
      theme: AppTheme.lightTheme,
      home:  OnboardingScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}
