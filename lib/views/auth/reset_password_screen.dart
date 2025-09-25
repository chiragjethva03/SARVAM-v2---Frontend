import 'package:flutter/material.dart';
import 'signin_screen.dart';
import '../../services/forgot_password.dart';

class ResetPasswordScreen extends StatefulWidget {
  final String email;
  const ResetPasswordScreen({super.key, required this.email});

  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmController = TextEditingController();

  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _obscureConfirm = true;

  void _resetPassword() async {
    final password = _passwordController.text.trim();
    final confirm = _confirmController.text.trim();

    // ✅ Check empty fields
    if (password.isEmpty || confirm.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Please enter all fields")));
      return;
    }

    // ✅ Check password match
    if (password != confirm) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            "Passwords do not match. Please retype the correct password",
          ),
        ),
      );
      return;
    }

    // ✅ Password validation
    final passwordRegEx = RegExp(
      r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[\W_]).{8,}$',
    );
    // at least 1 lowercase, 1 uppercase, 1 number, 1 special char, min 8

    if (!passwordRegEx.hasMatch(password)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            "Password must be at least 8 characters, include uppercase, lowercase, number and special character",
          ),
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final result = await EmailValidateService.resetPassword(
        email: widget.email,
        newPassword: password,
      );

      if (result["success"] == true) {
        // ✅ Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              "You have successfully completed the forgot password steps. You can now login with your new password.",
            ),
            duration: Duration(seconds: 3), // show for 3 seconds
          ),
        );

        // ✅ Navigate directly to SignInScreen
        Future.delayed(const Duration(seconds: 3), () {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => SignInScreen()),
          );
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(result["message"] ?? "Something went wrong")),
        );
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final screenWidth = constraints.maxWidth;
            final screenHeight = constraints.maxHeight;
            final textScale = MediaQuery.of(context).textScaleFactor;

            return SingleChildScrollView(
              padding: EdgeInsets.symmetric(
                horizontal: screenWidth * 0.06,
                vertical: screenHeight * 0.04,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(height: screenHeight * 0.05),

                  // Image
                  Center(
                    child: Image.asset(
                      'assets/auth/forgot.png',
                      width: screenWidth * 0.45,
                      height: screenHeight * 0.22,
                      fit: BoxFit.contain,
                    ),
                  ),

                  SizedBox(height: screenHeight * 0.02),

                  // Title
                  Text(
                    "Forgot Your Password?",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: (screenWidth * 0.055) * textScale,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  SizedBox(height: screenHeight * 0.01),

                  // Subtitle
                  Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: screenWidth * 0.05,
                    ),
                    child: Text(
                      "Don’t worry, we’ll help you reset it in a few steps.",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: (screenWidth * 0.035) * textScale,
                      ),
                    ),
                  ),

                  SizedBox(height: screenHeight * 0.01),

                  // Email
                  Text(
                    "Forgot password for: ${widget.email}",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: (screenWidth * 0.035) * textScale,
                      fontWeight: FontWeight.w500,
                    ),
                  ),

                  SizedBox(height: screenHeight * 0.05),

                  // New Password
                  TextField(
                    controller: _passwordController,
                    obscureText: _obscurePassword,
                    decoration: InputDecoration(
                      prefixIcon: const Icon(Icons.lock),
                      labelText: "New password",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscurePassword
                              ? Icons.visibility_off
                              : Icons.visibility,
                        ),
                        onPressed: () => setState(
                          () => _obscurePassword = !_obscurePassword,
                        ),
                      ),
                    ),
                  ),

                  SizedBox(height: screenHeight * 0.02),

                  // Confirm Password
                  TextField(
                    controller: _confirmController,
                    obscureText: _obscureConfirm,
                    decoration: InputDecoration(
                      prefixIcon: const Icon(Icons.lock),
                      labelText: "Retype new password",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),

                  SizedBox(height: screenHeight * 0.03),

                  // Button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _resetPassword,
                      child: _isLoading
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Text("Set a new password"),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
