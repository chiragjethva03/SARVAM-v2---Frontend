import 'package:flutter/material.dart';

class Intro1Screen extends StatelessWidget {
  // No 'const' here, since we use dynamic scaleFactor
  @override
  Widget build(BuildContext context) {
    // Get screen dimensions
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    // Scale factors for consistent sizing
    final baseWidth = 360; // Assumed design width (baseline for scaling)
    final scaleFactor = screenWidth / baseWidth;

    return Scaffold(

      body: Stack(
        children: [
          // Top-left background circle
          Positioned(
            top: -50 * scaleFactor,
            left: -50 * scaleFactor,
            child: Container(
              width: 180 * scaleFactor,
              height: 180 * scaleFactor,
              decoration: BoxDecoration(
                color: const Color(0xFF2196F3).withOpacity(0.11),
                shape: BoxShape.circle,
              ),
            ),
          ),

          // Mid-right background circle
          Positioned(
            top: 150 * scaleFactor,
            left: screenWidth / 2 - (75 * scaleFactor) + (40 * scaleFactor),
            child: Container(
              width: 180 * scaleFactor,
              height: 180 * scaleFactor,
              decoration: BoxDecoration(
               color: const Color(0xFF2196F3).withOpacity(0.11),
                shape: BoxShape.circle,
              ),
            ),
          ),

          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Spacing from top
              SizedBox(height: 170 * scaleFactor),

              // Text block
              Container(
                margin: EdgeInsets.only(left: screenWidth * 0.2),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "LET’S",
                      style: TextStyle(
                        fontSize: 25 * scaleFactor,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      "EXPLORE",
                      style: TextStyle(
                        fontSize: 45 * scaleFactor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      "THE WORLD",
                      style: TextStyle(
                        fontSize: 25 * scaleFactor,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),

              // Image section
              Center(
                child: Container(
                  margin: EdgeInsets.only(top: 5 * scaleFactor),
                  child: Image.asset(
                    "assets/IntroScreen/intro1.png",
                    width: 470 * scaleFactor,
                    height: 470 * scaleFactor,
                    fit: BoxFit.contain,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
