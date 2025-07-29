import 'package:flutter/material.dart';
import '../../services/auth_service.dart';
import '../auth/signin_screen.dart';

class AccountScreen extends StatelessWidget {
  const AccountScreen({super.key});

  Future<void> _logout(BuildContext context) async {
    await AuthService.clearToken();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const SignInScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ElevatedButton(
        onPressed: () => _logout(context),
        child: const Text("Logout"),
      ),
    );
  }
}
