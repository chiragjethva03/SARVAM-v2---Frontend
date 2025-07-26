import 'package:flutter/material.dart';
import 'package:sarvam/views/auth/signin_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Intro4Screen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    // Base width for scaling
    final baseWidth = 360.0; // Design baseline width
    final scaleFactor = screenWidth / baseWidth;

    return Scaffold(
      body: Stack(
        children: [
          // Oval shape decoration
          Positioned(
            top: -30 * scaleFactor,
            left: -50 * scaleFactor,
            child: Container(
              width: 200 * scaleFactor,
              height: 200 * scaleFactor,
              decoration: BoxDecoration(
                color: const Color(0xFF2196F3).withOpacity(0.11),
                shape: BoxShape.circle,
              ),
            ),
          ),
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(height: 60 * scaleFactor),
                Column(
                  children: [
                    Text(
                      "Explore India with Confidence",
                      style: TextStyle(
                        fontSize: 22 * scaleFactor,
                        fontWeight: FontWeight.w800,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    Text(
                      "Your Destination, Our Guidance.",
                      style: TextStyle(
                        fontSize: 19 * scaleFactor,
                        fontStyle: FontStyle.italic,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
                SizedBox(height: 10 * scaleFactor),
                Image.asset(
                  "assets/IntroScreen/intro4.png",
                  width: 350 * scaleFactor,
                  height: 350 * scaleFactor,
                  fit: BoxFit.contain,
                ),
                SizedBox(height: 5 * scaleFactor),
                Text(
                  "Ready to Explore?",
                  style: TextStyle(
                    fontSize: 24 * scaleFactor,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: 16.0 * scaleFactor,
                    vertical: 8.0 * scaleFactor,
                  ),
                  child: Text(
                    "Start your adventure and explore India with all services in one place.",
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 18 * scaleFactor),
                  ),
                ),
                SizedBox(height: 10 * scaleFactor),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20 * scaleFactor),
                  child: Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10 * scaleFactor),
                    ),
                    child: ElevatedButton(
                      onPressed: () async {
                        final prefs = await SharedPreferences.getInstance();
                        await prefs.setBool('seenIntro', true);

                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const SignInScreen(),
                          ),
                        );
                      },
                      child: Text("Let’s Go"),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
