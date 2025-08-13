import 'package:flutter/material.dart';

class Intro3Screen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    // Base design size
    final baseWidth = 360;
    final baseHeight = 800;
    final scaleW = screenWidth / baseWidth;
    final scaleH = screenHeight / baseHeight;

    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            // Top curved background
            Positioned(
              top: -50 * scaleH,
              left: 0,
              right: 0,
              child: Container(
                width: screenWidth,
                height: 280 * scaleH,
                decoration: BoxDecoration(
                  color: const Color(0xFF2196F3).withOpacity(0.11),
                  borderRadius: BorderRadius.vertical(
                    bottom: Radius.circular(100 * scaleH),
                  ),
                ),
              ),
            ),

            Padding(
              padding: EdgeInsets.symmetric(horizontal: 18 * scaleW),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(height: 30 * scaleH),

                  // Title and Subtitle
                  Padding(
                    padding: EdgeInsets.all(18 * scaleW),
                    child: Column(
                      children: [
                        Text(
                          "Plan your stay with ease.",
                          style: TextStyle(
                            fontSize: 30 * scaleW,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(height: 12 * scaleH),
                        Text(
                          "Find top-rated hotels and restaurants around your destination with just a few steps.",
                          style: TextStyle(
                            fontSize: 18 * scaleW,
                            color: Colors.black87,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: 55 * scaleH),

                  // Option Cards
                  OptionCard(
                    image: "assets/IntroScreen/intro3-1.png",
                    text: "Find the perfect stay",
                    imageFirst: true,
                    scaleW: scaleW,
                    scaleH: scaleH,
                  ),
                  Divider(color: const Color(0xFF2196F3).withOpacity(0.11), thickness: 5),
                  OptionCard(
                    image: "assets/IntroScreen/intro3-2.png",
                    text: "Reserve a table",
                    imageFirst: false,
                    scaleW: scaleW,
                    scaleH: scaleH,
                  ),
                  Divider(color: const Color(0xFF2196F3).withOpacity(0.11), thickness: 5),
                  OptionCard(
                    image: "assets/IntroScreen/intro3-3.png",
                    text: "Manage your bookings",
                    imageFirst: true,
                    scaleW: scaleW,
                    scaleH: scaleH,
                  ),

                  Spacer(),
                  SizedBox(height: 40 * scaleH),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class OptionCard extends StatelessWidget {
  final String image;
  final String text;
  final bool imageFirst;
  final double scaleW;
  final double scaleH;

  const OptionCard({
    required this.image,
    required this.text,
    required this.imageFirst,
    required this.scaleW,
    required this.scaleH,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 14 * scaleH),
      padding: EdgeInsets.symmetric(
        vertical: 10 * scaleH,
        horizontal: 14 * scaleW,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: imageFirst
            ? [
                Image.asset(
                  image,
                  width: 72 * scaleW,
                  height: 72 * scaleW,
                ),
                SizedBox(width: 12 * scaleW),
                Expanded(
                  child: Text(
                    text,
                    style: TextStyle(
                      fontSize: 20 * scaleW,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ]
            : [
                Expanded(
                  child: Text(
                    text,
                    style: TextStyle(
                      fontSize: 20 * scaleW,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                ),
                SizedBox(width: 12 * scaleW),
                Image.asset(
                  image,
                  width: 72 * scaleW,
                  height: 72 * scaleW,
                ),
              ],
      ),
    );
  }
}
