import 'package:flutter/material.dart';

class GoogleSignInInfoSheet extends StatelessWidget {
  const GoogleSignInInfoSheet({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: const [
          Icon(Icons.info_outline, size: 40, color: Colors.blue),
          SizedBox(height: 16),
          Text(
            "Password Change Not Available",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 12),
          Text(
            "Since you've signed in using your Google account, you cannot change your password from this app. To manage your password, please visit your Google Account settings.",
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 16),
          ),
          SizedBox(height: 20),
        ],
      ),
    );
  }
}
