import 'package:flutter/material.dart';
import '../../services/auth_service.dart';
import 'signin_screen.dart';
import '../../widgets/auth_widgets.dart';
import '../../widgets/loading_overlay.dart'; // Add this import
import '../home_screen.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final fullNameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  String? fullNameError;
  String? emailError;
  String? passwordError;

  bool _isLoading = false; // Added state for loader

  bool validateForm() {
    bool isValid = true;

    // Full name validation
    if (fullNameController.text.isEmpty) {
      fullNameError = "Full name cannot be empty";
      isValid = false;
    } else {
      fullNameError = null;
    }

    // Email validation
    if (!emailController.text.endsWith("@gmail.com")) {
      emailError = "Email must end with @gmail.com";
      isValid = false;
    } else {
      emailError = null;
    }

    // Password validation: 1 uppercase, 1 lowercase, 1 digit, min 8 chars
    final password = passwordController.text;
    final passwordRegex = RegExp(r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d).{8,}$');
    if (!passwordRegex.hasMatch(password)) {
      passwordError =
          "Password must have 1 uppercase, 1 lowercase, 1 number, 8+ characters";
      isValid = false;
    } else {
      passwordError = null;
    }

    setState(() {});
    return isValid;
  }

  Future<void> handleSignUp() async {
    if (!validateForm()) return;

    setState(() => _isLoading = true);

    try {
      final data = {
        "fullName": fullNameController.text,
        "email": emailController.text,
        "password": passwordController.text,
      };

      final result = await AuthService.signUp(data);
      final status = result['status'];
      final body = result['body'];

      if (status == 200) {
        await AuthService.saveToken(body['token']);

        fullNameController.clear();
        emailController.clear();
        passwordController.clear();

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(body['message'] ?? "Signup successful")),
        );

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const HomePage()),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(body['message'] ?? "Signup failed")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Signup failed")));
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
            // Main content
            SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Top background and title
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
                              'Sign Up',
                              style: TextStyle(
                                fontSize: 35,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: 12),
                            Text(
                              'Signup and Discover your next Great Adventure !',
                              style: TextStyle(fontSize: 25),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 40),

                  // Input fields
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        FullNameField(
                          controller: fullNameController,
                          errorText: fullNameError,
                        ),
                        const SizedBox(height: 20),
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
                            onPressed: handleSignUp,
                            child: const Text('Create account'),
                          ),
                        ),
                        const SizedBox(height: 12),

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
                                "Already have an account ? ",
                                style: TextStyle(fontWeight: FontWeight.w500),
                              ),
                              GestureDetector(
                                onTap: () {
                                  Navigator.pushReplacement(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          const SignInScreen(),
                                    ),
                                  );
                                },
                                child: const Text(
                                  "Sign In",
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
