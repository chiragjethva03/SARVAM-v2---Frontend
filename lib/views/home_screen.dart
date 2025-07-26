import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Sarvam"),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              "Welcome to Sarvam",
              // This uses global text theme (text color from theme)
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {},
              child: const Text("Explore"),
            ),
            ElevatedButton(onPressed: () {}, child: Text("new button create by chirag")),
            Text("Hy chirag jethva", style: TextStyle(fontSize: 30,), ),
          ],
          
        ),
      ),
    );
  }
}
