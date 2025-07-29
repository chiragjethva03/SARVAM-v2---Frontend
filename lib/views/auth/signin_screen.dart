// File: lib/screens/auth/sign_in_screen.dart
import 'package:flutter/material.dart';
import 'signup_screen.dart';
import '../../widgets/auth_widgets.dart';
import '../../services/auth_service.dart';
import '../../widgets/loading_overlay.dart'; // Import your loading overlay
import '.././home_page.dart';

class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key});

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  String? emailError;
  String? passwordError;

  bool _isLoading = false; // Added loader state

  bool validateForm() {
    bool isValid = true;

    if (!emailController.text.endsWith("@gmail.com")) {
      emailError = "Enter valid Gmail";
      isValid = false;
    } else {
      emailError = null;
    }

    if (passwordController.text.isEmpty) {
      passwordError = "Password cannot be empty";
      isValid = false;
    } else {
      passwordError = null;
    }

    setState(() {});
    return isValid;
  }

  void handleLogin() async {
    if (!validateForm()) return;

    setState(() => _isLoading = true);

    final data = {
      "email": emailController.text,
      "password": passwordController.text,
    };

    try {
      final response = await AuthService.login(data);

      if (response["status"] == 200) {
        final body = response["body"];

        // Save token, name, and an empty photoUrl for manual login
        await AuthService.saveUserData(
          token: body['token'],
          userId: body['user']['id'], // add this
          name: body['user']['fullName'],
          photoUrl: "", // manual login has no image
        );

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Welcome ${body['user']['fullName']}")),
        );

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const HomePage()),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(response["body"]["message"] ?? "Login failed"),
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Something went wrong")));
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Stack(
                    children: [
                      Container(
                        height: size.height * 0.25,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: const Color(0xFF2196F3).withOpacity(0.11),
                          borderRadius: const BorderRadius.only(
                            bottomLeft: Radius.circular(50),
                            bottomRight: Radius.circular(50),
                          ),
                        ),
                      ),
                      const Padding(
                        padding: EdgeInsets.only(
                          top: 32,
                          left: 24,
                          right: 24,
                          bottom: 32,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Sign In',
                              style: TextStyle(
                                fontSize: 35,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: 12),
                            Text(
                              'Welcome back, your next\nAdventure awaits !',
                              style: TextStyle(fontSize: 25),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 40),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Email & Password fields
                        EmailPasswordFields(
                          emailController: emailController,
                          passwordController: passwordController,
                          emailError: emailError,
                          passwordError: passwordError,
                        ),
                        const SizedBox(height: 20),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: handleLogin,
                            child: const Text('Login'),
                          ),
                        ),
                        Align(
                          alignment: Alignment.centerRight,
                          child: TextButton(
                            onPressed: () {},
                            child: const Text(
                              'Forgot password ?',
                              style: TextStyle(
                                color: Colors.blue,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                        Row(
                          children: const [
                            Expanded(child: Divider()),
                            Padding(
                              padding: EdgeInsets.symmetric(horizontal: 8.0),
                              child: Text("or"),
                            ),
                            Expanded(child: Divider()),
                          ],
                        ),
                        const SizedBox(height: 20),
                        const GoogleButton(),
                        const SizedBox(height: 32),
                        Center(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Text(
                                "Don’t have an account yet ? ",
                                style: TextStyle(fontWeight: FontWeight.w500),
                              ),
                              GestureDetector(
                                onTap: () {
                                  Navigator.pushReplacement(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          const SignUpScreen(),
                                    ),
                                  );
                                },
                                child: const Text(
                                  "Sign Up",
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.blue,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            // Loader overlay
            LoadingOverlay(isLoading: _isLoading),
          ],
        ),
      ),
    );
  }
}
