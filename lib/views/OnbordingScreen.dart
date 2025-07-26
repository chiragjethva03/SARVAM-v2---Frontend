import 'package:flutter/material.dart';
import 'dart:async';
import 'onboarding_pages.dart'; // <-- import this instead of home_screen.dart

class OnboardingScreen extends StatefulWidget {
  @override
  _OnboardingScreenState createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  @override
  void initState() {
    super.initState();
    Timer(const Duration(seconds: 3), () {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const OnboardingPages()),
      );
    });
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
