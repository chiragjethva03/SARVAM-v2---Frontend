import 'package:flutter/material.dart';

class Intro1Screen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    final baseWidth = 360; // Design reference width
    final baseHeight = 800; // Design reference height

    final scaleW = screenWidth / baseWidth;
    final scaleH = screenHeight / baseHeight;

    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            // Top-left background circle
            Positioned(
              top: -50 * scaleW,
              left: -50 * scaleW,
              child: Container(
                width: 180 * scaleW,
                height: 180 * scaleW,
                decoration: BoxDecoration(
                  color: const Color(0xFF2196F3).withOpacity(0.11),
                  shape: BoxShape.circle,
                ),
              ),
            ),

            // Mid-right background circle
            Positioned(
              top: 150 * scaleH,
              left: screenWidth / 2 - (75 * scaleW) + (40 * scaleW),
              child: Container(
                width: 180 * scaleW,
                height: 180 * scaleW,
                decoration: BoxDecoration(
                  color: const Color(0xFF2196F3).withOpacity(0.11),
                  shape: BoxShape.circle,
                ),
              ),
            ),

            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 170 * scaleH),

                // Text block
                Container(
                  margin: EdgeInsets.only(left: screenWidth * 0.2),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "LET’S",
                        style: TextStyle(
                          fontSize: 25 * scaleW,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      SizedBox(height: 4 * scaleH),
                      Text(
                        "EXPLORE",
                        style: TextStyle(
                          fontSize: 45 * scaleW,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 4 * scaleH),
                      Text(
                        "THE WORLD",
                        style: TextStyle(
                          fontSize: 25 * scaleW,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),

                // Image section
                Expanded(
                  child: Center(
                    child: Image.asset(
                      "assets/IntroScreen/intro1.png",
                      width: 450 * scaleW,
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
