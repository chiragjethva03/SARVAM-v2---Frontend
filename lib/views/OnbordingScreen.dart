import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:async';
import 'IntroScreens/onboarding_pages.dart';
import 'auth/signin_screen.dart';
import 'home_page.dart';
import 'package:jwt_decoder/jwt_decoder.dart';

class OnboardingScreen extends StatefulWidget {
  @override
  _OnboardingScreenState createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  @override
  void initState() {
    super.initState();
    _navigate();
  }

  Future<void> _navigate() async {
    await Future.delayed(const Duration(seconds: 3));

    final prefs = await SharedPreferences.getInstance();

    // 1. Check if token is stored
    final token = prefs.getString('token');

    if (token != null && token.isNotEmpty) {
      // ✅ Check expirya
      bool isExpired = JwtDecoder.isExpired(token);

      if (!isExpired) {
        // Token valid -> Directly go to HomePage
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const HomePage()),
        );
        return;
      } else {
        // Token expired -> clear token & go to Login
        await prefs.remove('token');
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const SignInScreen()),
        );
        return;
      }
    }

    // 2. If no token, check intro logic
    final seenIntro = prefs.getBool('seenIntro') ?? false;

    if (seenIntro) {
      // Already seen intro -> show Sign In screen
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const SignInScreen()),
      );
    } else {
      // First time -> show Onboarding/Intro pages
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const OnboardingPages()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final double imageSize = size.width * 0.25;
    final double fontSize = size.width * 0.11;

    return Scaffold(
      body: Center(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: size.width * 0.04),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(
                width: imageSize,
                height: imageSize,
                child: Image.asset("assets/AppIcons/Onbording.png"),
              ),
              SizedBox(width: size.width * 0.05),
              Text(
                "Sarvam",
                style: TextStyle(
                  fontSize: fontSize,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF2196F3),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
